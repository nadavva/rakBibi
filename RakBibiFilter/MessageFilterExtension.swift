//
//  MessageFilterExtension.swift
//  RakBibiFilter
//
//  Created by Nadav Vanunu on 26/12/2018.
//  Copyright © 2018 Nadav Vanunu. All rights reserved.
//

import IdentityLookup

final class MessageFilterExtension: ILMessageFilterExtension {}

extension MessageFilterExtension: ILMessageFilterQueryHandling {
    
    func handle(_ queryRequest: ILMessageFilterQueryRequest, context: ILMessageFilterExtensionContext, completion: @escaping (ILMessageFilterQueryResponse) -> Void) {
        
        // First, check whether to filter using offline data (if possible).
        let offlineAction = self.offlineAction(for: queryRequest)
        
        switch offlineAction {
        case .allow, .filter:
            // Based on offline data, we know this message should either be Allowed or Filtered. Send response immediately.
            let response = ILMessageFilterQueryResponse()
            response.action = offlineAction
            
            completion(response)
            
        case .none:
            // Based on offline data, we do not know whether this message should be Allowed or Filtered. Defer to network.
            // Note: Deferring requests to network requires the extension target's Info.plist to contain a key with a URL to use. See documentation for details.
            context.deferQueryRequestToNetwork() { (networkResponse, error) in
                let response = ILMessageFilterQueryResponse()
                response.action = .none
                
                if let networkResponse = networkResponse {
                    // If we received a network response, parse it to determine an action to return in our response.
                    response.action = self.action(for: networkResponse)
                } else {
                    NSLog("Error deferring query request to network: \(String(describing: error))")
                }
                
                completion(response)
            }
        }
    }
    
    private func offlineAction(for queryRequest: ILMessageFilterQueryRequest) -> ILMessageFilterAction {
        guard let messageBody = queryRequest.messageBody?.lowercased() else { return .none }
        
        let defaults = UserDefaults.init(suiteName: "group.rakBibi")
        let filters = defaults?.array(forKey: "myFilters") as? [[String: Any]] ?? []
        
        NSLog("Received SMS = \(messageBody)")
        NSLog("Filters = \(filters)")

        for filter in filters {
            let filterValue = filter["value"] as! String
            let isFullWord = filter["isFullWord"] as! NSInteger
            
            NSLog("Current filter = \(filterValue), filterType = \(isFullWord)")
            
            
            if (isFullWord == 0) {
                // contain
                if (messageBody.contains(filterValue)) {
                    NSLog("SMS contained bad word -- \(filterValue) -- Filttered!")
                    return .filter
                }
            } else if (isFullWord == 1){
                // search full word is SMS text
                let smsSprlitted = messageBody.split(separator: " ")
                for str in smsSprlitted {
                    if (str == filterValue) {
                        NSLog("SMS has full word bad word -- \(filterValue) -- Filttered!")
                        return .filter
                    }
                }
            } else if (isFullWord == 2){
                // sender
                guard let smsSender = queryRequest.sender?.lowercased() else { return .none }
                NSLog("Received SMS sender = \(smsSender)")
                if (smsSender.contains(filterValue)) {
                    NSLog("SMS sender contain filter value -- \(filterValue) -- Filttered!")
                    return .filter
                }
            }
            
        }
        NSLog("SMS passed the filter")
        return .allow
        
        // Replace with logic to perform offline check whether to filter first (if possible).
        
    }
    
    private func action(for networkResponse: ILNetworkResponse) -> ILMessageFilterAction {
        // Replace with logic to parse the HTTP response and data payload of `networkResponse` to return an action.
        return .none
    }
    
}
