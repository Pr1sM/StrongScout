//
//  MasterViewController.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 1/30/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [String]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        objects = ["Match 1", "Match 2", "Match 3", "The Rest"]

        // let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        // self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
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
            }
        } else if segue.identifier == "SegueToNewMatch" {
            MatchStore.sharedStore.createMatch()
        } else if segue.identifier == "segueToMatchQueue" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                MatchStore.sharedStore.createMatchFromQueueIndex(indexPath.row)
            }
        }
    }
    
    // MARK: Unwind Segues
    
    @IBAction func unwindToMatchView(sender:UIStoryboardSegue) {
        self.tableView.reloadData()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        if indexPath.section == 0 {
            let match = MatchStore.sharedStore.matchesToScout[indexPath.row]
            cell.textLabel!.text = "\(match.matchNumber) - \(match.teamNumber)"
        } else {
            let match = MatchStore.sharedStore.allMatches[indexPath.row]
            cell.textLabel!.text = "\(match.matchNumber) - \(match.teamNumber)"
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

