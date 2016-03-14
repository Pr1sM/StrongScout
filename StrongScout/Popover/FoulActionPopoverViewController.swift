//
//  FoulActionPopoverViewController.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 3/14/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class FoulActionPopoverViewController: UIViewController {
    @IBOutlet var actionButtons: [UIButton]!
    
    // Foul   = bit 0 = 1 = 0b0001
    // T Foul = bit 1 = 2 = 0b0010
    // Y Card = bit 2 = 4 = 0b0100
    // R Card = bit 3 = 8 = 0b1000
    var buttonState:Int = 0
    var section:SectionType = .tele
    var penalty:PenaltyType = .None
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "Add Foul"
    }
    
    @IBAction func actionButtonTap(sender:UIButton) {
        if sender.selected {
            penalty = .None
        } else {
            penalty = PenaltyType(rawValue: sender.tag)!
        }
        
        for b in actionButtons {
            b.selected = penalty.rawValue == b.tag
        }
    }
}

extension FoulActionPopoverViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        if penalty == .None { return }
        
        var action = Action()
        action.section = section
        action.type = .penalty
        action.data = .PenaltyData(penalty)

        MatchStore.sharedStore.updateCurrentMatchWithAction(action)
    }
}
