//
//  ViewController.swift
//  rakBibi
//
//  Created by Nadav Vanunu on 26/12/2018.
//  Copyright © 2018 Nadav Vanunu. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var filters : [String]  = []
    
    func loadSavedFilters() -> Void {
        let defaults = UserDefaults.init(suiteName: "group.rakBibi")
        filters = defaults?.stringArray(forKey: "myFilters") ?? [String]()
    }
    
    func saveFilters() -> Void {
        let defaults = UserDefaults.init(suiteName: "group.rakBibi")
        defaults?.set(filters, forKey: "myFilters")
    }
    
    @IBOutlet weak var main: UILabel!
    
    func addNewFilter(newFilter : String) -> Void {

        let splitted : [String] = newFilter.components(separatedBy: ",")
        for str in splitted {
            if ((str == "") || (filters.contains(str))) {
                continue
            }
            self.filters.append(str)
        }
        if (splitted.count > 0) {
            self.saveFilters()
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
        
    }
    
    // MARK: Table
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadSavedFilters()
        tableView.allowsSelection = false;
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
        if (section == 1) {
            return 1
        }
        return filters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 1) {
            // addFilterCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "addFilterCell", for: indexPath)
            return cell
        } else {
            //filterCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)
            cell.textLabel?.text = filters[indexPath.row]
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if (indexPath.section == 0) {
            return .delete
        }
        
        return .none
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if (indexPath.section < 2) {
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            filters.remove(at: indexPath.row)
            saveFilters()
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
            self.addNewFilter(newFilter: newFilter ?? "")
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
}

