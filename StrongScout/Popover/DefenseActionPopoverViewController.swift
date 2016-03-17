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
    
    // Crossed         = 1
    // Attempted Cross = 2
    // Crossed w/ Ball = 3
    // Assisted        = 4
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
        buttonState = sender.selected ? 0 : sender.tag
        for b in actionButtons {
            b.selected = buttonState == b.tag
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
        defenseInfo.actionPerformed = DefenseAction(rawValue: buttonState)!
        var action = Action()
        action.section = section
        action.type = .defense
        action.data = .DefenseData(defenseInfo)
        
        MatchStore.sharedStore.updateCurrentMatchWithAction(action)
    }
}

