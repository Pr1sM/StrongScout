//
//  GoalSelectionPopoverViewController.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 2/13/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class GoalSelectionPopoverViewController: UIViewController {

    @IBOutlet var goalButtons: [UIButton]!
    @IBOutlet var locationButtons: [UIButton]!
    
    // Missed    = bit 0 = 1 = 0b0001
    // Completed = bit 1 = 2 = 0b0010
    var goalState:Int = 0
    
    // Batter    = bit 0 = 1 = 0b0001
    // Courtyard = bit 1 = 2 = 0b0010
    // Defenses  = bit 2 = 4 = 0b0100
    var locationState:Int = 0
    var lowGoal:Bool = true
    var section:SectionType = .tele
    
    @IBAction func goalTap(sender: UIButton) {
        let bit = sender.tag
        if sender.selected {
            goalState = 0
        } else {
            goalState = 1 << bit
        }
        
        for b in goalButtons {
            if goalState == 1 << b.tag {
                b.selected = true
            } else {
                b.selected = false
            }
        }
    }
    
    @IBAction func locationTap(sender: UIButton) {
        let bit = sender.tag
        if sender.selected {
            locationState = 0
        } else {
            locationState = 1 << bit
        }
        
        for b in locationButtons {
            if locationState == 1 << b.tag {
                b.selected = true
            } else {
                b.selected = false
            }
        }
    }
}

extension GoalSelectionPopoverViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return (locationState > 0 && goalState > 0) || (locationState == 0 && goalState == 0)
    }
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        if locationState == 0 && goalState == 0 { return }
        var score = Score()
        score.type = ScoreType(rawValue: goalState << ((lowGoal) ? 2 : 0))
        score.location = ScoreLocation(rawValue: locationState)
        var action = Action()
        action.type = .score
        action.section = section
        action.data = .ScoreData(score)
        MatchStore.sharedStore.updateCurrentMatchWithAction(action)
    }
}
