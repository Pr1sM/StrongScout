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
    
    @IBOutlet var undo:UIBarButtonItem!
    @IBOutlet var redo:UIBarButtonItem!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        undo.enabled = MatchStore.sharedStore.actionsUndo.size() > 0
        redo.enabled = MatchStore.sharedStore.actionsRedo.size() > 0
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        MatchStore.sharedStore.updateCurrentMatchForType(.actionsEdited, match: match)
    }
    
    @IBAction func undoAction(sender:UIBarButtonItem) {
        var editAction = MatchStore.sharedStore.actionsUndo.pop()
        editAction.edit.reverse()
        MatchStore.sharedStore.actionsRedo.push(editAction)
        print("undo count: \(MatchStore.sharedStore.actionsUndo.size()), redo count: \(MatchStore.sharedStore.actionsRedo.size())")
        if(editAction.edit == .Add) {
            match.actionsPerformed.insert(editAction.action, atIndex: editAction.index)
        } else {
            print("ERROR: undo delete action")
        }
        
        undo.enabled = MatchStore.sharedStore.actionsUndo.size() > 0
        redo.enabled = MatchStore.sharedStore.actionsRedo.size() > 0
        
        tableView.reloadData()
    }
    
    @IBAction func redoAction(sender:UIBarButtonItem) {
        var editAction = MatchStore.sharedStore.actionsRedo.pop()
        editAction.edit.reverse()
        MatchStore.sharedStore.actionsUndo.push(editAction)
        print("undo count: \(MatchStore.sharedStore.actionsUndo.size()), redo count: \(MatchStore.sharedStore.actionsRedo.size())")
        if(editAction.edit == .Delete) {
            match.actionsPerformed.removeAtIndex(editAction.index)
//            let indexPath = NSIndexPath(forRow: match.actionsPerformed.count - 1 - editAction.index, inSection: 0)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
//            tableView.reloadData()
        } else {
            print("ERROR: redo add action")
        }
        
        undo.enabled = MatchStore.sharedStore.actionsUndo.size() > 0
        redo.enabled = MatchStore.sharedStore.actionsRedo.size() > 0
        
        tableView.reloadData()
    }
    
    func removeActionAtIndex(index:Int) {
        let action = match.actionsPerformed.removeAtIndex(index)
        MatchStore.sharedStore.actionsUndo.push(ActionEdit(edit: .Delete, action: action, atIndex: index))
        undo.enabled = MatchStore.sharedStore.actionsUndo.size() > 0
        redo.enabled = MatchStore.sharedStore.actionsRedo.size() > 0
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
        switch action.data {
        case let .ScoreData(score):
            description = "\(score.type.toString()) from the \(score.location.toString())"
            break
        case let .DefenseData(defense):
            description = "\(defense.actionPerformed.toString()) on \(defense.type.toString())"
            break
        case let .PenaltyData(penalty):
            description = "\(penalty.toString()) awarded"
            break
        default:
            break
        }
        cell.detailTextLabel?.text = description
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            removeActionAtIndex(match.actionsPerformed.count - 1 - indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}

extension FieldActionTableViewController:FieldActionTableViewCellDelegate {
    func actionToDeleteAtIndexPath(indexPath: NSIndexPath) {
        removeActionAtIndex(match.actionsPerformed.count - 1 - indexPath.row)
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
