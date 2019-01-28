//
//  ViewController.swift
//  rakBibi
//
//  Created by Nadav Vanunu on 26/12/2018.
//  Copyright © 2018 Nadav Vanunu. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    

    
    private var dateCellExpanded: Bool = false
    private var expCellIndex: IndexPath = IndexPath(row: -1, section: -1)
    @IBOutlet weak var main: UILabel!
    
    // MARK: Table
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onFilterDataUpdate(_:)),
            name: Notification.Name("onFilterUpdate"),
            object: nil)
        main.alpha = 0
        self.main.frame.origin.y -= 50
        self.animateTitleLabelIn()        
    }
    
    func animateTitleLabelIn() {
        UIView.animate(withDuration: 1.5) {
            self.main.alpha = 1
            self.main.frame.origin.y += 50
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        }
        return filters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            // addFilterCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "addFilterCell", for: indexPath)
            return cell
        } else {
            //filterCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath) as! FilterCell
            let cellData = filters[indexPath.row]
            cell.value.text = cellData["value"] as? String
            cell.tableview = self.tableView
            cell.fullWordControl.selectedSegmentIndex = cellData["isFullWord"] as! NSInteger
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if (indexPath.section == 1) {
            return .delete
        }
        return .none
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            filters.remove(at: indexPath.row)
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }
    
    @IBAction func onAddFilterPressed(_ sender: Any) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "הוספת פילטר חדש", message: "ניתן להוסיף כמה פילטרים יחד ע״י הפרדתם בפסיק", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let newFilter = textField?.text
            self.addNewFilter(value: newFilter ?? "", isFullWord: false)
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (expCellIndex.section == indexPath.section &&
            expCellIndex.row == indexPath.row) {
            if dateCellExpanded {
                return 122
            } else {
                return 44
            }
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dateCellExpanded {
            dateCellExpanded = false
        } else {
            dateCellExpanded = true
            expCellIndex = indexPath
        }
        tableView.beginUpdates()
        tableView.endUpdates()
        
    }
 
    // MARK: Filters
    
    var filters: [[String: Any]] {
        get {
            let defaults = UserDefaults.init(suiteName: "group.rakBibi")
            return defaults?.array(forKey: "myFilters") as? [[String: Any]] ?? []
        }
        set {
            let defaults = UserDefaults.init(suiteName: "group.rakBibi")
            defaults?.set(newValue as [Any], forKey: "myFilters")
        }
    }
    
    func addNewFilter(value : String, isFullWord : Bool) -> Void {
        
        let splitted : [String] = value.components(separatedBy: ",")
        for str in splitted {
            if ((str == "") || filterExist(value: str)) {
                continue
            }
            self.filters.append(["value": str, "isFullWord": NSNumber(value:isFullWord)])
        }
        if (splitted.count > 0) {
            //self.saveFilters()
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
        
    }
    
    func filterExist(value: String) -> Bool {
        for filter in filters {
            let str : String = filter["value"] as! String
            if (str == value) {
                return true
            }
        }
        return false
    }
    
    @objc func onFilterDataUpdate(_ notification:Notification) {
        let indexPath = notification.object as! IndexPath
        let cur = filters[indexPath.row]["isFullWord"] as! NSNumber
        
        if (cur == 0) {
            filters[indexPath.row]["isFullWord"] = 1
        } else {
            filters[indexPath.row]["isFullWord"] = 0
        }
        
    }
}

class FilterCell: UITableViewCell {
    
    @IBOutlet weak var value: UILabel!
    @IBOutlet var tableview: UITableView!
    @IBOutlet weak var fullWordControl: UISegmentedControl!
    
    @IBAction func onTap(_ sender: UIButton) {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tableview)
        let indexPath = self.tableview.indexPathForRow(at: buttonPosition)
        
        NSLog("Received SMS = \(indexPath)")
        
    }
    
    @IBAction func onChange(_ sender: UISegmentedControl) {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tableview)
        let indexPath = self.tableview.indexPathForRow(at: buttonPosition)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "onFilterUpdate"), object: indexPath)
    }
    
}
