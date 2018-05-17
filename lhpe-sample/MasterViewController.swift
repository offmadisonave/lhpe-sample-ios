//
//  MasterViewController.swift
//  lhpe-sample
//
//  Created by Erik Madsen on 5/17/18.
//  Copyright © 2018 Erik Madsen. All rights reserved.
//

import UIKit
import LighthouseKit
import Permission

class MasterViewController: UITableViewController, PermissionSetDelegate {

    var detailViewController: DetailViewController? = nil
    var signals = [LHSignal]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Permissions", style: .plain, target: self, action: #selector(openPermissionsMenu(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: #selector(openProfile(_:)))
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(getData(_:)), for: UIControlEvents.valueChanged)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        getData(self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc
    func openPermissionsMenu(_ sender: Any) {
        let actionSheet:UIAlertController = UIAlertController(title: "Permissions", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Location", style: .default, handler: { (action:UIAlertAction) in
            let p:Permission = .locationAlways
            if(p.status == .authorized){
                let alert: UIAlertController = UIAlertController(title: "Permission", message: "The permission is already granted", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action:UIAlertAction) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }else if(p.status == .denied){
                let alert: UIAlertController = UIAlertController(title: "Permission", message: "The permission was previously denied", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action:UIAlertAction) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }else{
                p.request {
                    status in
                    if(status == .authorized){
                        Lighthouse.setAllowsLocation(true, resultBlock: nil)
                    }else if(status == .denied){
                        Lighthouse.setAllowsLocation(false, resultBlock: nil)
                    }
                }
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Notifications", style: .default, handler: { (action:UIAlertAction) in
            let p:Permission = .notifications
            if(p.status == .authorized){
                let alert: UIAlertController = UIAlertController(title: "Permission", message: "The permission is already granted", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action:UIAlertAction) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }else if(p.status == .denied){
                let alert: UIAlertController = UIAlertController(title: "Permission", message: "The permission was previously denied", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action:UIAlertAction) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }else{
                p.request {
                    status in
                    if(status == .authorized){
                        Lighthouse.setAllowsPush(true, resultBlock: nil)
                    }else if(status == .denied){
                        Lighthouse.setAllowsPush(false, resultBlock: nil)
                    }
                }
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action:UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(actionSheet, animated: true) {
            
        }
    }
    
    @objc
    func openProfile(_ sender: Any) {
        performSegue(withIdentifier: "showProfile", sender: self)
    }
    
    @objc
    func getData(_ sender: Any) {
        Lighthouse.signalHistory({
            (results: [LHSignal]?, error) in
            self.signals = results!
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        })
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object: LHSignal = signals[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.signalItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return signals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let signal:LHSignal = signals[indexPath.row]
        cell.textLabel!.text = signal.alert
        cell.detailTextLabel!.text = signal.createdAt.description
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let signal:LHSignal = signals[indexPath.row]
            Lighthouse.setSignalDeletedWithId(signal.id) { (Success, err: Error?) in
                self.signals.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

