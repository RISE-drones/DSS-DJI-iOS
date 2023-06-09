//
//  LogTableViewController.swift
//  DSS
//
//  Created by Andreas Gising on 2021-04-28.
//


import Foundation
import UIKit

class TableViewController: UITableViewController{
    
    var dataSource: [String] = []
    var logAllocator = Allocator(name: "log")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add observer that will fetch the log data
        NotificationCenter.default.addObserver(self, selector: #selector(onDidNewLogItem(_:)), name: .didNewLogItem, object: nil)
    }
    
    // *****************************************
    // Function to scroll to bottom of tableView
    func scrollToBottom(){
        DispatchQueue.main.async {
            // Allocator for scrollable list
            if self.logAllocator.allocate("scroll", maxTime: 0.1){
                self.tableView.scrollRectToVisible(CGRect(x: 0, y: self.tableView.contentSize.height - self.tableView.bounds.size.height, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height), animated: true)
                self.logAllocator.deallocate()
            }
        }
    }
    
    // *************************************************
    // Function called upon receiving a log notification
    @objc func onDidNewLogItem(_ notification: Notification){
        let logStr = String(describing: notification.userInfo!["logItem"]!)
        // Limit log to 100 instances
//        if dataSource.count > 100 {
//            dataSource.remove(at: 0)
//            // Remove one more to maintain the visible effect of scrolling when new entries appear
//            dataSource.remove(at: 0)
//        }
        // Append log str to datasource
        dataSource.append(logStr)
        // Reload and wait a bit to be sure scroll to bottom does not exceed any bounds
        Dispatch.main{
            // Allocator for scrollable list
            if self.logAllocator.allocate("reloadData", maxTime: 1){
                self.tableView.reloadData()
                self.logAllocator.deallocate()
                self.scrollToBottom()
            }
        }
    }
   
    
    // ********************************************
    // Dynamically set number of cells in tableView
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = dataSource.count
        return rows
    }
    
    // ***********************
    // Allocaiton of new cells
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let customCell = tableView.dequeueReusableCell(withIdentifier: "logCell") as! logTableViewCell  // logCell is the tableView Cell identifier
        
        // Put the log str in the cell label
        customCell.cellLabel.text = dataSource[indexPath.row]
        customCell.cellLabel.textColor = UIColor.black
        
        // Look for Error and set background to red if so
        if customCell.cellLabel.text!.contains("Error") || customCell.cellLabel.text!.contains("violation"){
            customCell.backgroundColor = UIColor.systemRed
        }
        else if customCell.cellLabel.text!.contains("Nack"){
            customCell.backgroundColor = UIColor.systemYellow
        }
        else if customCell.cellLabel.text!.contains("Warning"){
            customCell.backgroundColor = UIColor.systemYellow
        }
        else{
            customCell.backgroundColor = UIColor.systemGray
        }
        return customCell
    }
}


// Class for tableViewCell
class logTableViewCell: UITableViewCell{
    @IBOutlet weak var cellLabel: UILabel!
}
