//
//  FieldDataEntryView.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 1/30/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class FieldDataEntryView: UIViewController {
    @IBOutlet weak var firstDefense:UIImageView!
    @IBOutlet weak var secondDefense:UIImageView!
    @IBOutlet weak var thirdDefense:UIImageView!
    @IBOutlet weak var fourthDefense:UIImageView!
    @IBOutlet weak var fifthDefense:UIImageView!
    @IBOutlet weak var sectionSelection:UISegmentedControl!
    @IBOutlet weak var goal:UIImageView!
    
    var match:Match!

    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        let fifthDefenseTap = UITapGestureRecognizer(target: self, action: "fifthDefenseTap:")
        fifthDefense.addGestureRecognizer(fifthDefenseTap)
        fifthDefense.userInteractionEnabled = true
        
        let goalTap = UITapGestureRecognizer(target: self, action: "goalTap:")
        goal.addGestureRecognizer(goalTap)
        goal.userInteractionEnabled = true
        
        match = MatchStore.sharedStore.currentMatch
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setupImageViews()
        
        if(match.isCompleted & 1 == 0) {
            self.performSegueWithIdentifier("SegueToMatchSetup", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func firstDefenseTap(sender:UIGestureRecognizer) {
        if match?.defense1.type == .unknown { return }
        presentDefenseActionPopoverForImageView(firstDefense, tag: 1)
    }
    
    func secondDefenseTap(sender:UIGestureRecognizer) {
        if match?.defense2.type == .unknown { return }
        presentDefenseActionPopoverForImageView(secondDefense, tag: 2)
    }
    
    func thirdDefenseTap(sender:UIGestureRecognizer) {
        if match?.defense3.type == .unknown { return }
        presentDefenseActionPopoverForImageView(thirdDefense, tag: 3)
    }
    
    func fourthDefenseTap(sender:UIGestureRecognizer) {
        if match?.defense4.type == .unknown { return }
        presentDefenseActionPopoverForImageView(fourthDefense, tag: 4)
    }
    
    func fifthDefenseTap(sender:UIGestureRecognizer) {
        if match?.defense5.type == .unknown { return }
        presentDefenseActionPopoverForImageView(fifthDefense, tag: 5)
    }
    
    func presentDefenseActionPopoverForImageView(imageView:UIImageView, tag:Int) {
        let dact = storyboard?.instantiateViewControllerWithIdentifier("DefenseActionPopoverViewController") as! DefenseActionPopoverViewController
        let navControl = UINavigationController(rootViewController: dact)
        let section = SectionType(rawValue: sectionSelection.selectedSegmentIndex)
        dact.section = section!
        dact.view.tag = tag
        dact.defense = match!.defenses[tag-1].type
        navControl.modalPresentationStyle = .Popover
        dact.preferredContentSize = CGSize(width: 372, height: 198)
        navControl.preferredContentSize = CGSize(width: 372, height: 198)
        
        let popover = navControl.popoverPresentationController
        popover?.permittedArrowDirections = .Right
        popover?.delegate = dact
        popover?.sourceView = imageView
        popover?.sourceRect = imageView.bounds
        self.presentViewController(navControl, animated: true, completion: nil)
    }
    
    func goalTap(sender:UIGestureRecognizer) {
        let location = sender.locationInView(self.goal)
        
        var sourceRect = CGRectZero
        var title = ""
        var lowGoal = true
        let section = SectionType(rawValue: sectionSelection.selectedSegmentIndex)
        if (location.y < self.goal.frame.height / 3) {
            title = "High Goal"
            lowGoal = false
            sourceRect = CGRectMake(0, 0, self.goal.frame.width, self.goal.frame.height / 3)
        } else if (location.y > 2 * self.goal.frame.height / 3) {
            title = "Low Goal"
            sourceRect = CGRectMake(0, 2 * self.goal.frame.height / 3, self.goal.frame.width, self.goal.frame.height / 3)
        } else {
            return
        }
        
        title += (section == .auto) ? " - AUTONOMOUS" : " - TELEOP"
        
        let goal = storyboard?.instantiateViewControllerWithIdentifier("GoalSelectionPopoverViewController") as! GoalSelectionPopoverViewController
        goal.lowGoal = lowGoal
        goal.section = section!
        let navControl = UINavigationController(rootViewController: goal)
        navControl.modalPresentationStyle = .Popover
        goal.preferredContentSize = CGSize(width: 372, height: 198)
        navControl.preferredContentSize = CGSize(width: 372, height: 198)
        goal.navigationItem.title = title
        
        let popover = navControl.popoverPresentationController
        popover?.permittedArrowDirections = .Left
        popover?.delegate = goal
        popover?.sourceView = self.goal
        popover?.sourceRect = sourceRect
        self.presentViewController(navControl, animated: true, completion: nil)
    }
    
    func setupImageViews() {
        firstDefense.image  = UIImage(named: (match?.defense1.type.toString())!)
        secondDefense.image = UIImage(named: (match?.defense2.type.toString())!)
        thirdDefense.image  = UIImage(named: (match?.defense3.type.toString())!)
        fourthDefense.image = UIImage(named: (match?.defense4.type.toString())!)
        fifthDefense.image  = UIImage(named: (match?.defense5.type.toString())!)
    }
    
    @IBAction func addFoulTap(sender:UIBarButtonItem) {
        let foul = storyboard?.instantiateViewControllerWithIdentifier("FoulActionPopoverViewController") as! FoulActionPopoverViewController
        foul.section = SectionType(rawValue: sectionSelection.selectedSegmentIndex)!
        let navControl = UINavigationController(rootViewController: foul)
        navControl.modalPresentationStyle = .Popover
        foul.preferredContentSize = CGSize(width: 372, height: 198)
        navControl.preferredContentSize = CGSize(width: 372, height: 198)
        
        let popover = navControl.popoverPresentationController
        popover?.permittedArrowDirections = .Down
        popover?.barButtonItem = sender
        popover?.delegate = foul
        self.presentViewController(navControl, animated: true, completion: nil)
    }
    
    @IBAction func unwindToFieldDataEntryView(sender:UIStoryboardSegue) {
        match = MatchStore.sharedStore.currentMatch!
        setupImageViews()
    }
}












