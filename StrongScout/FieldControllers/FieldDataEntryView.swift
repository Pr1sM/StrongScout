//
//  FieldDataEntryView.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 1/30/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class FieldDataEntryView: UIViewController {
    var firstDefense:UIImageView!
    var secondDefense:UIImageView!
    var thirdDefense:UIImageView!
    var fourthDefense:UIImageView!
    var fifthDefense:UIImageView!
    var goal:UIImageView!
    
    var sectionSelection:UISegmentedControl!
    
    @IBOutlet weak var leftStack:UIStackView!
    @IBOutlet weak var rightStack:UIStackView!
    
    var type1:Bool = true
    
    var match:Match!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstDefense = UIImageView(frame: CGRectZero)
        secondDefense = UIImageView(frame: CGRectZero)
        thirdDefense = UIImageView(frame: CGRectZero)
        fourthDefense = UIImageView(frame: CGRectZero)
        fifthDefense = UIImageView(frame: CGRectZero)
        firstDefense.contentMode = .ScaleAspectFit
        secondDefense.contentMode = .ScaleAspectFit
        thirdDefense.contentMode = .ScaleAspectFit
        fourthDefense.contentMode = .ScaleAspectFit
        fifthDefense.contentMode = .ScaleAspectFit
        
        let goalImage = UIImage(named: "goal")!
        goal = UIImageView(image: goalImage)
        goal.contentMode = .ScaleAspectFit

        let firstDefenseTap = UITapGestureRecognizer(target: self, action: #selector(FieldDataEntryView.firstDefenseTap(_:)))
        firstDefense.addGestureRecognizer(firstDefenseTap)
        firstDefense.userInteractionEnabled = true
        
        let secondDefenseTap = UITapGestureRecognizer(target: self, action: #selector(FieldDataEntryView.secondDefenseTap(_:)))
        secondDefense.addGestureRecognizer(secondDefenseTap)
        secondDefense.userInteractionEnabled = true
        
        let thirdDefenseTap = UITapGestureRecognizer(target: self, action: #selector(FieldDataEntryView.thirdDefenseTap(_:)))
        thirdDefense.addGestureRecognizer(thirdDefenseTap)
        thirdDefense.userInteractionEnabled = true
        
        let fourthDefenseTap = UITapGestureRecognizer(target: self, action: #selector(FieldDataEntryView.fourthDefenseTap(_:)))
        fourthDefense.addGestureRecognizer(fourthDefenseTap)
        fourthDefense.userInteractionEnabled = true
        
        let fifthDefenseTap = UITapGestureRecognizer(target: self, action: #selector(FieldDataEntryView.fifthDefenseTap(_:)))
        fifthDefense.addGestureRecognizer(fifthDefenseTap)
        fifthDefense.userInteractionEnabled = true
        
        let goalTap = UITapGestureRecognizer(target: self, action: #selector(FieldDataEntryView.goalTap(_:)))
        goal.addGestureRecognizer(goalTap)
        goal.userInteractionEnabled = true
    
        match = MatchStore.sharedStore.currentMatch
        
        leftStack.axis = .Vertical
        leftStack.distribution = .FillEqually
        leftStack.alignment = .Fill
        leftStack.spacing = 20
        
        rightStack.axis = .Vertical
        rightStack.distribution = .FillEqually
        rightStack.alignment = .Fill
        rightStack.spacing = 20
        
        sectionSelection = UISegmentedControl(items: ["Autonomous", "Teleop"])
        sectionSelection.selectedSegmentIndex = 0
        sectionSelection.tintColor = UIColor(red: 1.0, green: 0.40, blue: 0, alpha: 1.0)
        sectionSelection.setContentHuggingPriority(750, forAxis: .Vertical)
        sectionSelection.addTarget(self, action: #selector(FieldDataEntryView.sectionChange(_:)), forControlEvents: .ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = themeGray
        
        if(match.isCompleted & 1 == 0) {
            self.performSegueWithIdentifier("SegueToMatchSetup", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sectionChange(sender:UISegmentedControl) {
        let auto = sender.selectedSegmentIndex == 0
        self.view.backgroundColor = auto ? themeGray : themeDarkGray
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
        popover?.permittedArrowDirections = type1 ? .Right : .Left
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
        popover?.permittedArrowDirections = type1 ? .Left : .Right
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
        
        let goalStack = type1 ? leftStack : rightStack
        let defenseStack = type1 ? rightStack : leftStack
        
        if defenseStack.subviews.count > 0 { return }
        let dViews = (type1) ? [fifthDefense, fourthDefense, thirdDefense, secondDefense, firstDefense] : [firstDefense, secondDefense, thirdDefense, fourthDefense, fifthDefense]
        for view in dViews {
            defenseStack.addArrangedSubview(view)
        }
        
        goalStack.distribution = .FillProportionally
        goalStack.addArrangedSubview(sectionSelection)
        goalStack.addArrangedSubview(goal)
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
    
    @IBAction func cancelMatchEdit(sender:UIBarButtonItem) {
        let ac = UIAlertController(title: "Cancel Match Edits", message: "Canceling match edits will discard all unsaved data.  Are you sure you want to continue?", preferredStyle: .Alert)
        let discard = UIAlertAction(title: "Continue", style: .Destructive, handler: {(action) in
            self.performSegueWithIdentifier("segueCancelMatch", sender: self)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        ac.addAction(discard)
        ac.addAction(cancel)
        
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    @IBAction func unwindToFieldDataEntryView(sender:UIStoryboardSegue) {
        match = MatchStore.sharedStore.currentMatch!
        
        type1 = (match.alliance == .blue && MatchStore.sharedStore.fieldLayout == .BlueRed) ||
                (match.alliance == .red  && MatchStore.sharedStore.fieldLayout == .RedBlue)
        
        setupImageViews()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueCancelMatch" {
            MatchStore.sharedStore.cancelCurrentMatchEdit()
        }
    }
}












