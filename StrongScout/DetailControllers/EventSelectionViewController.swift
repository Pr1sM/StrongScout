//
//  EventSelectionViewController.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 3/17/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class EventSelectionViewController: UIViewController {
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var getScheduleButton:UIButton!
    @IBOutlet weak var buildListButton:UIButton!
    
    @IBOutlet var listSelectorButtons:[UIButton]!
    
    /** 
     * represents the list the user wants to build
     * the first 2 bits correspond to the number of the list
     * bit 3 corresponds to the color (0 == red, 1 == blue)
     * ex: 5 = Blue 1 ~> (5 & 4) == 1, (5 & 3) == 1
     * ex: 3 = Red  3 ~> (5 & 4) == 0, (5 & 3) == 3
     */
    var selectedList = 0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        getScheduleButton.enabled = EventStore.sharedStore.selectedEvent != nil
        buildListButton.enabled = false
        selectedList = 0
        for b in listSelectorButtons {
            b.selected = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if EventStore.sharedStore.selectedEvent != nil {
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        }
    }
    
    @IBAction func selectList(sender:UIButton) {
        selectedList = sender.selected ? 0 : sender.tag
        for b in listSelectorButtons {
            b.selected = b.tag == selectedList
        }
        buildListButton.enabled = selectedList > 0
    }
    
    @IBAction func getSchedule(sender:UIButton) {
        ScheduleStore.sharedStore.currentSchedule = EventStore.sharedStore.selectedEvent?.code
        ScheduleStore.sharedStore.getScheduleList(nil, completion: nil)
    }
    
    @IBAction func buildList(sender:UIButton) {
        
    }
}

extension EventSelectionViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return EventStore.sharedStore.eventsByType.count + 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return EventStore.sharedStore.selectedEvent == nil ? 0 : 1
        }
        return EventStore.sharedStore.eventsByType[section-1].count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Selected Event"
        }
        return EventStore.sharedStore.eventHeaderForSection(section-1)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell") as! EventCell
        let event = indexPath.section == 0 ? EventStore.sharedStore.selectedEvent! : EventStore.sharedStore.eventsByType[indexPath.section - 1][indexPath.row]
        cell.title.text = event.name
        cell.venue.text = event.venue
        cell.location.text = "\(event.city), \(event.stateProv), \(event.country)"
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM'/'dd'/'yyyy"
        cell.startDate.text = formatter.stringFromDate(event.dateStart!)

        return cell
    }
}

extension EventSelectionViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 { return }
        let event = EventStore.sharedStore.eventsByType[indexPath.section-1][indexPath.row]
        EventStore.sharedStore.selectedEvent = event
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Right)
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: true, scrollPosition: .Top)
    }
}
