//
//  FieldDefenseSelectionView.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 2/6/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class FieldDefenseSelectionView: UIViewController, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var firstDefense:UIImageView!
    @IBOutlet weak var secondDefense:UIImageView!
    @IBOutlet weak var thirdDefense:UIImageView!
    @IBOutlet weak var fourthDefense:UIImageView!
    @IBOutlet var defenseImageViews:[UIImageView]!
    
    var m:Match = MatchStore.sharedStore.currentMatch!
    
    override func viewDidLoad() {
        let firstDefenseTap = UITapGestureRecognizer(target: self, action: "firstDefenseTap:")
        firstDefense.addGestureRecognizer(firstDefenseTap)
        firstDefense.userInteractionEnabled = true
        
        let secondDefenseTap = UITapGestureRecognizer(target: self, action: "secondDefenseTap:")
        secondDefense.addGestureRecognizer(secondDefenseTap)
        secondDefense.userInteractionEnabled = true
        
        let thirdDefenseTap = UITapGestureRecognizer(target: self, action: "thirdDefenseTap:")
        thirdDefense.addGestureRecognizer(thirdDefenseTap)
        thirdDefense.userInteractionEnabled = true
        
        let fourthDefenseTap = UITapGestureRecognizer(target: self, action: "fourthDefenseTap:")
        fourthDefense.addGestureRecognizer(fourthDefenseTap)
        fourthDefense.userInteractionEnabled = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        m = MatchStore.sharedStore.currentMatch!
        
        firstDefense.image  = UIImage(named:m.defense1.type.toString())
        secondDefense.image = UIImage(named:m.defense2.type.toString())
        thirdDefense.image  = UIImage(named:m.defense3.type.toString())
        fourthDefense.image = UIImage(named:m.defense4.type.toString())
        
        readyToMoveOn()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        MatchStore.sharedStore.updateCurrentMatchForType(.fieldSetup, match: m)
    }
    
    func readyToMoveOn() {
        let disable = m.defense1.type == .unknown || m.defense2.type == .unknown || m.defense3.type == .unknown || m.defense4.type == .unknown || m.defense5.type == .unknown
        
        self.navigationItem.rightBarButtonItem?.enabled = !disable
    }
    
    func firstDefenseTap(sender:UIGestureRecognizer) {
        presentDefenseSelectionPopoverForImageView(firstDefense, tag: 1)
    }
    
    func secondDefenseTap(sender:UIGestureRecognizer) {
        presentDefenseSelectionPopoverForImageView(secondDefense, tag: 2)
    }
    
    func thirdDefenseTap(sender:UIGestureRecognizer) {
        presentDefenseSelectionPopoverForImageView(thirdDefense, tag: 3)
    }
    
    func fourthDefenseTap(sender:UIGestureRecognizer) {
        presentDefenseSelectionPopoverForImageView(fourthDefense, tag: 4)
    }
    
    func presentDefenseSelectionPopoverForImageView(imageView:UIImageView, tag:Int) {
        let dsel = storyboard?.instantiateViewControllerWithIdentifier("DefenseSelectionPopoverViewController") as! DefenseSelectionPopoverViewController
        dsel.selectedType = m.defenses[tag-1].type
        dsel.view.tag = tag
        dsel.delegate = self
        dsel.modalPresentationStyle = .Popover
        dsel.preferredContentSize = CGSize(width: 290, height: 550)
        
        let popover = dsel.popoverPresentationController
        popover?.permittedArrowDirections = .Right
        popover?.delegate = self
        popover?.sourceView = imageView
        popover?.sourceRect = imageView.bounds
        presentViewController(
            dsel,
            animated: true,
            completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PopoverToDefenseSelection" {
            let dsel = segue.destinationViewController as! DefenseSelectionPopoverViewController
            dsel.delegate = self
        }
    }
}

extension FieldDefenseSelectionView: DefenseSelectionPopoverDelegate {
    func defenseSelection(defenseSelection:DefenseSelectionPopoverViewController, didSelectDefense type:DefenseType, withImage image:UIImage?, withTag tag:Int) {
        if tag == 1 {
            firstDefense.image = image
            m.defense1.type = type
            clearImagesForType(type, withTagNotEqualTo: 1)
        } else if tag == 2 {
            secondDefense.image = image
            m.defense2.type = type
            clearImagesForType(type, withTagNotEqualTo: 2)
        } else if tag == 3 {
            thirdDefense.image = image
            m.defense3.type = type
            clearImagesForType(type, withTagNotEqualTo: 3)
        } else if tag == 4 {
            fourthDefense.image = image
            m.defense4.type = type
            clearImagesForType(type, withTagNotEqualTo: 4)
        }
        MatchStore.sharedStore.updateCurrentMatchForType(.fieldSetup, match: m)
        m = MatchStore.sharedStore.currentMatch!
        readyToMoveOn()
    }
    
    func clearImagesForType(type:DefenseType, withTagNotEqualTo tag:Int) {
        for (index, value) in m.defenses.enumerate() {
            if index != tag - 1 && (value.type == type || value.type == type.complementType()) {
                if index == 0 {
                    m.defense1.type = .unknown
                } else if index == 1 {
                    m.defense2.type = .unknown
                } else if index == 2 {
                    m.defense3.type = .unknown
                } else if index == 3 {
                    m.defense4.type = .unknown
                } else {
                    m.defense5.type = .unknown
                }
                defenseImageViews[index].image = nil
            }
        }
        
        
    }
}
