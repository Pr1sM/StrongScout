//
//  FieldActionTableViewController.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 2/16/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

// MARK: Main Class
class FieldActionTableViewController: UITableViewController {
    var match = MatchStore.sharedStore.currentMatch!
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        MatchStore.sharedStore.updateCurrentMatchForType(.actionsEdited, match: match)
    }
}

// MARK: UITableViewDataSource
extension FieldActionTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return match.actionsPerformed.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FieldActionListCell") as! FieldActionTableViewCell
        cell.selectionStyle = .None
        cell.delegate = self
        cell.indexPath = indexPath
        let action = match.actionsPerformed[match.actionsPerformed.count - 1 - indexPath.row]
        cell.textLabel?.text = action.type.toString()
        var description = ""
        if action.type == .score {
            description = "\(action.score.type.toString()) from the \(action.score.location.toString())"
        } else if action.type == .defense {
            description = "\(action.defense.actionPerformed.toString()) on \(action.defense.type.toString())"
        }
        cell.detailTextLabel?.text = description
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            match.actionsPerformed.removeAtIndex(match.actionsPerformed.count - 1 - indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}

// MARK: UITableViewDelegate
extension FieldActionTableViewController {
    
}

extension FieldActionTableViewController:FieldActionTableViewCellDelegate {
    func actionToDeleteAtIndexPath(indexPath: NSIndexPath) {
        match.actionsPerformed.removeAtIndex(match.actionsPerformed.count - 1 - indexPath.row)
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        tableView.endUpdates()
        tableView.reloadData()
    }
}

//extension FieldActionTableViewController : SwipeTableCellDelegate {
//    func swipeTableCell(cell:SwipeTableCell, canSwipe direction:SwipeDirection, fromPoint point:CGPoint) -> Bool {
//        return true
//    }
//    
//    func swipeTableCell(cell:SwipeTableCell, didChangeSwipeState state:SwipeState, gestureIsAction:Bool) {
//        print("did change swipe state: \(state)")
//    }
//    
//    func swipeTableCell(cell:SwipeTableCell, tappedButtonAtIndex index:Int, direction:SwipeDirection, fromExpansion:Bool) {
//        print("tapped button at index: \(index)")
//    }
//    
//    
//    func swipeTableCell(cell:SwipeTableCell, swipeButtonsforDirection direction:SwipeDirection, swipeSettings:SwipeSettings, expansionSettings:SwipeExpansionSettings) -> [UIView] {
//        swipeSettings.transition = SwipeTransition.Border
//        expansionSettings.buttonIndex = 0
//        if direction == .LeftToRight {
//            expansionSettings.fillOnTrigger = false
//            expansionSettings.threshold = 2
//            return [SwipeButton(buttonWithTitle: "Hello", backgroundColor: UIColor.blackColor(), padding: 5)]
//        } else {
//            expansionSettings.fillOnTrigger = true
//            expansionSettings.threshold = 1.1
//            let padding:CGFloat = 15.0
//            
//            let delete = SwipeButton(buttonWithTitle: "Delete", backgroundColor: UIColor.redColor(), padding: padding)
//            let other = SwipeButton(buttonWithTitle: "More", backgroundColor: UIColor.lightGrayColor(), padding: padding)
//            
//            return [delete, other]
//        }
//    }
//    
//    func swipeTableCell(cell:SwipeTableCell, shouldHideSwipeOnTap point:CGPoint) -> Bool {
//        print("shouldhighswipeontap: \(point)")
//        
//        return true
//    }
//    
//    func swipeTableCellWillBeginSwiping(cell:SwipeTableCell) {
//        print("SwipeTableCellWillBeginSwiping")
//    }
//    
//    func swipeTableCellWillEndSwiping(cell:SwipeTableCell) {
//        print("SwipeTableCellWillEndSwiping")
//    }
//}
