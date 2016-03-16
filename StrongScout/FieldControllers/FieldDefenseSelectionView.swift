//
//  FieldDefenseSelectionView.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 2/6/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class FieldDefenseSelectionView: UIViewController, UIPopoverPresentationControllerDelegate {
//    @IBOutlet weak var secondDefense:UIImageView!
//    @IBOutlet weak var thirdDefense:UIImageView!
//    @IBOutlet weak var fourthDefense:UIImageView!
//    @IBOutlet weak var fifthDefense:UIImageView!
    
    @IBOutlet weak var defenseStack:UIStackView!
    
    var firstDefense:UIImageView!
    var secondDefense:UIImageView!
    var thirdDefense:UIImageView!
    var fourthDefense:UIImageView!
    var fifthDefense:UIImageView!
    
    var defenseImageViews:[UIImageView]!
    
    var m:Match = MatchStore.sharedStore.currentMatch!
    
    override func viewDidLoad() {
        
        firstDefense = UIImageView(frame: CGRectZero)
        secondDefense = UIImageView(frame: CGRectZero)
        thirdDefense = UIImageView(frame: CGRectZero)
        fourthDefense = UIImageView(frame: CGRectZero)
        fifthDefense = UIImageView(frame: CGRectZero)
        firstDefense.contentMode  = .ScaleAspectFit
        secondDefense.contentMode = .ScaleAspectFit
        thirdDefense.contentMode  = .ScaleAspectFit
        fourthDefense.contentMode = .ScaleAspectFit
        fifthDefense.contentMode  = .ScaleAspectFit
        
        let type1 = (m.alliance == .blue && MatchStore.sharedStore.fieldLayout == .BlueRed) ||
                    (m.alliance == .red && MatchStore.sharedStore.fieldLayout == .RedBlue)
        
        defenseImageViews = type1 ? [fifthDefense, fourthDefense, thirdDefense, secondDefense, firstDefense] : [firstDefense, secondDefense, thirdDefense, fourthDefense, fifthDefense]
        
        let secondDefenseTap = UITapGestureRecognizer(target: self, action: "secondDefenseTap:")
        secondDefense.addGestureRecognizer(secondDefenseTap)
        secondDefense.userInteractionEnabled = true
        
        let thirdDefenseTap = UITapGestureRecognizer(target: self, action: "thirdDefenseTap:")
        thirdDefense.addGestureRecognizer(thirdDefenseTap)
        thirdDefense.userInteractionEnabled = true
        
        let fourthDefenseTap = UITapGestureRecognizer(target: self, action: "fourthDefenseTap:")
        fourthDefense.addGestureRecognizer(fourthDefenseTap)
        fourthDefense.userInteractionEnabled = true
        
        let fifthDefenseTap = UITapGestureRecognizer(target: self, action: "fifthDefenseTap:")
        fifthDefense.addGestureRecognizer(fifthDefenseTap)
        fifthDefense.userInteractionEnabled = true
        
        defenseStack.axis = .Vertical
        defenseStack.alignment = .Fill
        defenseStack.distribution = .FillEqually
        
        for view in defenseImageViews {
            view.backgroundColor = themeDarkGray                                                                                                                                                                                                                                                                                                                                                                           
            view.layer.borderWidth = 1
            defenseStack.addArrangedSubview(view)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        m = MatchStore.sharedStore.currentMatch!
        
        firstDefense.image  = UIImage(named:m.defense1.type.toString())
        secondDefense.image = UIImage(named:m.defense2.type.toString())
        thirdDefense.image  = UIImage(named:m.defense3.type.toString())
        fourthDefense.image = UIImage(named:m.defense4.type.toString())
        fifthDefense.image  = UIImage(named:m.defense5.type.toString())
        
        readyToMoveOn()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        MatchStore.sharedStore.updateCurrentMatchForType(.fieldSetup, match: m)
    }
    
    func readyToMoveOn() {
        let disable = m.defense5.type == .unknown || m.defense2.type == .unknown || m.defense3.type == .unknown || m.defense4.type == .unknown || m.defense5.type == .unknown
        
        self.navigationItem.rightBarButtonItem?.enabled = !disable
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
    
    func fifthDefenseTap(sender:UIGestureRecognizer) {
        presentDefenseSelectionPopoverForImageView(fifthDefense, tag: 5)
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
        if tag == 2 {
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
        } else if tag == 5{
            fifthDefense.image = image
            m.defense5.type = type
            clearImagesForType(type, withTagNotEqualTo: 5)
        }
        MatchStore.sharedStore.updateCurrentMatchForType(.fieldSetup, match: m)
        m = MatchStore.sharedStore.currentMatch!
        readyToMoveOn()
    }
    
    func clearImagesForType(type:DefenseType, withTagNotEqualTo tag:Int) {
        for (index, value) in m.defenses.enumerate() {
            if index != tag - 1 && (value.type == type || value.type == type.complementType()) {
                if index == 0 {
                    continue
                } else if index == 1 {
                    m.defense2.type = .unknown
                    secondDefense.image = nil
                } else if index == 2 {
                    m.defense3.type = .unknown
                    thirdDefense.image = nil
                } else if index == 3 {
                    m.defense4.type = .unknown
                    fourthDefense.image = nil
                } else if index == 4 {
                    m.defense5.type = .unknown
                    fifthDefense.image = nil
                }
            }
        }
        
        
    }
}
