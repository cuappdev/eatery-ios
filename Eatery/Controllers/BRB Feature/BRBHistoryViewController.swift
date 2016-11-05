//
//  BRBHistoryViewController.swift
//  Eatery
//
//  Created by Arman Esmaili on 11/1/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class BRBHistoryViewController: UITableViewController
{
    var entries : [BRBConnectionHandler.HistoryEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "HistoryCell")
        
        cell.textLabel?.text = entries[indexPath.row].description
        cell.detailTextLabel?.text = entries[indexPath.row].timestamp
        return cell
    }
}
