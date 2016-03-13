//
//  DefenseActionPopoverViewController.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 2/13/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class DefenseActionPopoverViewController: UIViewController {
    @IBOutlet var actionButtons: [UIButton]!
    
    // Crossed         = bit 0 = 1 = 0b0001
    // Attempted Cross = bit 1 = 2 = 0b0010
    // Crossed w/ Ball = bit 2 = 4 = 0b0100
    // Assisted        = bit 3 = 8 = 0b1000
    var buttonState:Int = 0
    var defense:DefenseType = .unknown
    var section:SectionType = .tele
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = defense.toStringResults() + " - " + ((section == .auto) ? "AUTONOMOUS" : "TELEOP")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @IBAction func actionButtonTap(sender: UIButton) {
        let bit = sender.tag
        if sender.selected {
            buttonState = 0
        } else {
            buttonState = 1 << bit
        }
        
        for b in actionButtons {
            if buttonState == 1 << b.tag {
                b.selected = true
            } else {
                b.selected = false
            }
        }
    }
}

extension DefenseActionPopoverViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        if buttonState == 0 {
            return
        }
        
        var defenseInfo = DefenseInfo()
        defenseInfo.type = defense
        defenseInfo.actionPerformed = DefenseAction(rawValue: buttonState)
        var action = Action()
        action.section = section
        action.type = .defense
        action.defense = defenseInfo
        
        MatchStore.sharedStore.updateCurrentMatchWithAction(action)
    }
}

