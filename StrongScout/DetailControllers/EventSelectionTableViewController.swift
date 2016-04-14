//
//  EventSelectionTableViewController.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 4/13/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class EventSelectionTableViewController: UITableViewController {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if EventStore.sharedStore.selectedEvent != nil {
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        }
    }
    
    @IBAction func dismissView(sender:AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: UITableViewDataSource
extension EventSelectionTableViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return EventStore.sharedStore.eventsByType.count + 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return EventStore.sharedStore.selectedEvent == nil ? 0 : 1
        }
        return EventStore.sharedStore.eventsByType[section-1].count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0;
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Selected Event"
        }
        return EventStore.sharedStore.eventHeaderForSection(section-1)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return ["R", "DE", "DC", "CS", "CD", "C", "O"];
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return index + 1;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell") as! EventCell
        let event = indexPath.section == 0 ? EventStore.sharedStore.selectedEvent! : EventStore.sharedStore.eventsByType[indexPath.section - 1][indexPath.row]
        cell.selectionStyle = .None
        cell.title.text = event.name
        cell.venue.text = event.venue
        cell.location.text = "\(event.city), \(event.stateProv), \(event.country)"
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM'/'dd'/'yyyy"
        cell.startDate.text = formatter.stringFromDate(event.dateStart!)
        
        return cell
    }
}

// MARK: UITableViewDelegate
extension EventSelectionTableViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 { return }
        let event = EventStore.sharedStore.eventsByType[indexPath.section-1][indexPath.row]
        
        tableView.beginUpdates()
        if EventStore.sharedStore.selectedEvent != nil { // selected event is there, we need to remove the cell
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Right)
        }
        EventStore.sharedStore.selectedEvent = event
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Left)
        tableView.endUpdates()
        
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: true, scrollPosition: .Top)
    }
}
