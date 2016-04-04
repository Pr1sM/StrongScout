//
//  EventSelectionViewController.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 3/17/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import MBProgressHUD

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
            b.enabled = ScheduleStore.sharedStore.currentSchedule != nil
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
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        hud.mode = .Indeterminate
        hud.labelText = "Loading..."
        hud.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EventSelectionViewController.cancelRequest(_:))))
        self.navigationItem.leftBarButtonItem?.enabled = false
        self.getScheduleButton.enabled = false
        self.buildListButton.enabled = false
        ScheduleStore.sharedStore.getScheduleList({ (progress:Double) in
            dispatch_async(dispatch_get_main_queue(), {
                let hud = MBProgressHUD(forView: self.navigationController?.view)
                hud.mode = .Determinate
                hud.progress = Float(progress)
            })
        }, completion: { (error) in
            dispatch_async(dispatch_get_main_queue(), {
                let hud = MBProgressHUD(forView: self.navigationController?.view)
                let imageView = UIImageView(image: UIImage(named: error == nil ? "check" : "close"))
                self.navigationItem.leftBarButtonItem?.enabled = true
                self.getScheduleButton.enabled = true
                for b in self.listSelectorButtons {
                    b.enabled = ScheduleStore.sharedStore.currentSchedule != nil
                }
                self.buildListButton.enabled = self.selectedList > 0
                hud.customView = imageView
                hud.mode = .CustomView
                hud.labelText = error == nil ? "Completed" : "Error"
                hud.hide(true, afterDelay: 1)
            })
        })
    }
    
    @IBAction func buildList(sender:UIButton) {
        if ScheduleStore.sharedStore.currentSchedule != EventStore.sharedStore.selectedEvent?.code {
            let scheduleAC = UIAlertController(title: "Current Schedule is different from Selected Event", message: "You have a schedule from a different event! Would you like to continue with the build, or get the new schedule", preferredStyle: .Alert)
            let buildAction = UIAlertAction(title: "Continue With Build", style: .Default, handler: { (action) in
                self.confirmBuildList()
            })
            scheduleAC.addAction(buildAction)
            
            let getScheduleAction = UIAlertAction(title: "Get New Schedule", style: .Default, handler: { (action) in
                self.getSchedule(self.getScheduleButton)
            })
            scheduleAC.addAction(getScheduleAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            scheduleAC.addAction(cancelAction)
            
            self.presentViewController(scheduleAC, animated: true, completion: nil)
        } else {
            confirmBuildList()
        }
    }
    
    func confirmBuildList() {
        var list = (selectedList & 4) == 1 ? "Blue" : "Red"
        list += " \(selectedList & 3)"
        let ac = UIAlertController(title: "Build \(list) List for event \(ScheduleStore.sharedStore.currentSchedule!)", message: "Building this list will clear the previous queue of matches.  Do you want to continue?", preferredStyle: .Alert)
        let continueAction = UIAlertAction(title: "Continue", style: .Destructive, handler: {(action) in
            let hud = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
            hud.mode = .Indeterminate
            hud.labelText = "Building List"
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
                ScheduleStore.sharedStore.buildMatchListForGroup(self.selectedList)
                dispatch_async(dispatch_get_main_queue(), {
                    let hud = MBProgressHUD(forView: self.navigationController?.view)
                    let imageView = UIImageView(image: UIImage(named: "check"))
                    hud.customView = imageView
                    hud.mode = .CustomView
                    hud.labelText = "Completed"
                    hud.hide(true, afterDelay: 1)
                })
            })
        })
        ac.addAction(continueAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        ac.addAction(cancelAction)
        
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    func cancelRequest(sender:UITapGestureRecognizer) {
        ScheduleStore.sharedStore.cancelRequest({
            dispatch_async(dispatch_get_main_queue(), {
                let hud = MBProgressHUD(forView: self.navigationController?.view)
                let imageView = UIImageView(image: UIImage(named: "close"))
                self.navigationItem.leftBarButtonItem?.enabled = true
                self.getScheduleButton.enabled = true
                for b in self.listSelectorButtons {
                    b.enabled = ScheduleStore.sharedStore.currentSchedule != nil
                }
                self.buildListButton.enabled = self.selectedList > 0
                hud.customView = imageView
                hud.mode = .CustomView
                hud.labelText = "Canceled"
                hud.hide(true, afterDelay: 1)
            })
        })
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
        
        getScheduleButton.enabled = true
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
