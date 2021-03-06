//
//  MasterViewController.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 1/30/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import MBProgressHUD

class MasterViewController: UITableViewController {
    
    @IBOutlet var clearExportButton:UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

//        if let split = self.splitViewController {
//            let controllers = split.viewControllers
//            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
//        }
        
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMatchSummary" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let match = MatchStore.sharedStore.allMatches[indexPath.row]
                //match.aggregateActionsPerformed()
                let storyboard = UIStoryboard(name: "Results", bundle: nil)
                let sr = storyboard.instantiateViewControllerWithIdentifier("ResultsScoringViewController") as! ResultsScoringViewController
                let tr = storyboard.instantiateViewControllerWithIdentifier("ResultsTeleopViewController") as! ResultsTeleopViewController
                let mr = storyboard.instantiateViewControllerWithIdentifier("ResultsMatchInfoViewController") as! ResultsMatchInfoViewController
                sr.match = match
                tr.match = match
                mr.match = match
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! CustomContainerArrayView
                controller.views = [sr, tr, mr]
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
                controller.navigationItem.title = "Match: \(match.matchNumber) Team: \(match.teamNumber)"
            }
        } else if segue.identifier == "SegueToNewMatch" {
            MatchStore.sharedStore.createMatch()
        } else if segue.identifier == "segueToMatchQueue" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                MatchStore.sharedStore.createMatchFromQueueIndex(indexPath.row)
            }
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        clearExportButton.title = self.editing ? "Clear" : "Export";
    }
    
    // MARK: Unwind Segues
    
    @IBAction func unwindToMatchView(sender:UIStoryboardSegue) {
        self.tableView.reloadData()
    }
    
    @IBAction func handleExportOrClear(sender:UIBarButtonItem) {
        if self.editing {
            handleClear(sender)
        } else {
            handleExport(sender)
        }
    }
    
    func handleClear(sender:UIBarButtonItem) {
        let ac = UIAlertController(title: "Clear Matches", message: "", preferredStyle: .ActionSheet)
        
        let clearMatchQueue = UIAlertAction(title: "Clear Match Queue", style: .Destructive, handler: {(action) in
            self.clearMatchData(1)
        })
        let clearCompletedMatches = UIAlertAction(title: "Clear Completed Matches", style: .Destructive, handler: {(action) in
            self.clearMatchData(2)
        })
        let clearAllMatches = UIAlertAction(title: "Clear All Matches", style: .Destructive, handler: {(action) in
            self.clearMatchData(3)
        })
        
        ac.addAction(clearMatchQueue)
        ac.addAction(clearCompletedMatches)
        ac.addAction(clearAllMatches)
        
        ac.popoverPresentationController?.barButtonItem = sender
        ac.popoverPresentationController?.sourceView = self.view
        
        ac.view.layoutIfNeeded()
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    func clearMatchData(type:Int) {
        let clearMatchQueue = "Are you sure you want to clear Match Queue Data? You will have to rebuild a list from the Tools view to get a new queue of matches"
        let clearCompletedMatches = "Are you sure you want to clear completed matches? Doing so will permanently delete match data the next time you export all match data!"
        let clearAllMatches = "Are you sure you want to clear all Match Data? You will have to rebuild a list from the Tools view to get a new queue of matches.  Doing so will also permanently delete match data the next time you export all match data!"
        let ac = UIAlertController(title: "Clear Data", message: (type == 1) ? clearMatchQueue : (type == 2) ? clearCompletedMatches : clearAllMatches, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let continueAction = UIAlertAction(title: "Continue", style: .Destructive, handler: {(action) in
            let hud = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
            hud.mode = .Indeterminate
            hud.labelText = "Clearing Data..."
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
                MatchStore.sharedStore.clearMatchData(type)
                dispatch_async(dispatch_get_main_queue(), {
                    let hud = MBProgressHUD(forView: self.navigationController?.view)
                    let imageView = UIImageView(image: UIImage(named: "check"))
                    hud.customView = imageView
                    hud.mode = .CustomView
                    hud.labelText = "Completed"
                    self.tableView.reloadData()
                    hud.hide(true, afterDelay: 1)
                })
            })
        })
        ac.addAction(cancelAction)
        ac.addAction(continueAction)
        
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    func handleExport(sender:UIBarButtonItem) {
        let ac = UIAlertController(title: "Export Data", message: "", preferredStyle: .ActionSheet)
        //let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let exportAll = UIAlertAction(title: "Export All Data", style: .Default, handler: {(action) in
            // handle exporting all
            self.exportAllMatchData()
        })
        let exportNew = UIAlertAction(title: "Export New Data", style: .Destructive, handler: {(action) in
            // Handle exporting New Data
            self.exportNewMatchData()
        })
        //ac.addAction(cancelAction)
        ac.addAction(exportAll)
        ac.addAction(exportNew)

        ac.popoverPresentationController?.barButtonItem = sender
        ac.popoverPresentationController?.sourceView = self.view
        
        ac.view.layoutIfNeeded()
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    func exportNewMatchData() {
        var temp = 0
        for m in MatchStore.sharedStore.allMatches {
            if (m.isCompleted & 32) == 32 { temp += 1 }
        }
        if temp <= 0 {
            let ac = UIAlertController(title: "New Match Export Data", message: "There is no new match data, so no new data was written to the files", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            ac.addAction(okAction)
            self.presentViewController(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Export Data", message: "Are you sure you want to export data?  Doing so will overwrite previous data", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "No", style: .Cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let continueAction = UIAlertAction(title: "Yes", style: .Default, handler: {(action) in
                let hud = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
                hud.mode = .Indeterminate
                hud.labelText = "Exporting..."
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
                    MatchStore.sharedStore.exportNewMatchData()
                    dispatch_async(dispatch_get_main_queue(), {
                        let hud = MBProgressHUD(forView: self.navigationController?.view)
                        let imageView = UIImageView(image: UIImage(named: "check"))
                        hud.customView = imageView
                        hud.mode = .CustomView
                        hud.labelText = "Completed"
                        self.tableView.reloadData()
                        hud.hide(true, afterDelay: 1)
                    })
                })
            })
            ac.addAction(continueAction)
            self.presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    func exportAllMatchData() {
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        hud.mode = .Indeterminate
        hud.labelText = "Exporting..."
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
            MatchStore.sharedStore.writeCSVFile()
            dispatch_async(dispatch_get_main_queue(), {
                let hud = MBProgressHUD(forView: self.navigationController?.view)
                let imageView = UIImageView(image: UIImage(named: "check"))
                hud.customView = imageView
                hud.mode = .CustomView
                hud.labelText = "Completed"
                self.tableView.reloadData()
                hud.hide(true, afterDelay: 1)
            })
        })
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? MatchStore.sharedStore.matchesToScout.count > 0 ? "Matches Queued for Scouting" : nil :
                              MatchStore.sharedStore.allMatches.count     > 0 ? "Completed Matches"           : nil
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? MatchStore.sharedStore.matchesToScout.count : MatchStore.sharedStore.allMatches.count
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return section == 0 ? MatchStore.sharedStore.matchesToScout.count > 0 ? "\(MatchStore.sharedStore.matchesToScout.count) Match(es)" : nil :
                              MatchStore.sharedStore.allMatches.count     > 0 ? "\(MatchStore.sharedStore.allMatches.count) Match(es)"     : nil
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MatchCell", forIndexPath: indexPath) as! MatchCell

        if indexPath.section == 0 {
            let match = MatchStore.sharedStore.matchesToScout[indexPath.row]
            cell.matchNumber.text = "\(match.matchNumber)"
            cell.teamNumber.text = "\(match.teamNumber)"
            
            cell.accessoryType = .None;
        } else {
            let match = MatchStore.sharedStore.allMatches[indexPath.row]
            cell.matchNumber.text = "\(match.matchNumber)"
            cell.teamNumber.text = "\(match.teamNumber)"
            
            cell.accessoryType = ((match.isCompleted & 32) != 32) ? .Checkmark : .None
        }

        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if indexPath.section == 0 {
                MatchStore.sharedStore.removeMatchQueueAtIndex(indexPath.row)
            } else {
                MatchStore.sharedStore.removeMatchAtIndex(indexPath.row)
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            MatchStore.sharedStore.saveChanges()
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            performSegueWithIdentifier("segueToMatchQueue", sender: self)
        } else {
            performSegueWithIdentifier("showMatchSummary", sender: self)
        }
    }
}

