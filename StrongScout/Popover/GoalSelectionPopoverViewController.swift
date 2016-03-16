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
    
    // Missed    = 1
    // Completed = 2
    var goalState:Int = 0
    
    // Batter    = 1
    // Courtyard = 2
    // Defenses  = 3
    var locationState:Int = 0
    var lowGoal:Bool = true
    var section:SectionType = .tele
    
    @IBAction func goalTap(sender: UIButton) {
        goalState = sender.selected ? 0 : sender.tag
        for b in goalButtons {
            b.selected = goalState == b.tag
        }
    }
    
    @IBAction func locationTap(sender: UIButton) {
        locationState = sender.selected ? 0 : sender.tag
        for b in locationButtons {
            b.selected = locationState == b.tag
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
        score.type = ScoreType(rawValue: goalState + ((lowGoal) ? 2 : 0))!
        score.location = ScoreLocation(rawValue: locationState)!
        var action = Action()
        action.type = .score
        action.section = section
        action.data = .ScoreData(score)
        MatchStore.sharedStore.updateCurrentMatchWithAction(action)
    }
}
