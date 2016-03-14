//
//  FinalViewController.swift
//  StrongScout
//
//  Created by Team 525 Students on 2/6/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class FinalViewController: UIViewController {

    @IBOutlet var EndingRobotButtons: [UIButton]!
    @IBOutlet var EndingButtons: [UIButton]!
    @IBOutlet var MatchOutcomeButtons: [UIButton]!
    @IBOutlet weak var FinalPenaltyScoreTextField: UITextField!
    @IBOutlet weak var FinalRankingPointsTextField: UITextField!
    @IBOutlet weak var FinalScoreTextField: UITextField!
    @IBOutlet weak var FinalCommentsTextView: UITextView!
    @IBOutlet weak var scrollView:UIScrollView!
    
    private var match = MatchStore.sharedStore.currentMatch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundTap = UITapGestureRecognizer(target: self, action: "backgroundTap:")
        backgroundTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(backgroundTap)
        
        FinalCommentsTextView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        match = MatchStore.sharedStore.currentMatch!
        registerForKeyboardNotifications()
        readyToMoveOn()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        deregisterForKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func readyToMoveOn() {
        let disable =  match.finalScore < 0 || match.finalPenaltyScore < 0 || match.finalRankingPoints < 0 || match.finalResult == .none
        
        self.navigationItem.rightBarButtonItem?.enabled = !disable
    }
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func deregisterForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification:NSNotification) {
        let info = notification.userInfo
        let kbSize = info![UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size
        
        let edgeInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize!.height, 0.0)
        scrollView.contentInset = edgeInsets
        scrollView.scrollIndicatorInsets = edgeInsets
        
        if !FinalCommentsTextView.isFirstResponder() { return }

        self.scrollView.setContentOffset(CGPointMake(0.0, kbSize!.height-CGRectGetMaxY(FinalCommentsTextView.frame) + 150), animated: true)
    }
    
    func keyboardWillBeHidden(notification:NSNotification) {
        let insets = UIEdgeInsetsZero
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        self.scrollView.contentOffset = CGPointMake(0.0, 0.0)
    }
    
    @IBAction func RobotButtonTap(sender:UIButton) {
        if sender.tag == 1 {
            if match.finalRobot.contains(.Stalled) {
                match.finalRobot.remove(.Stalled)
                sender.selected = false
            }
            else {
                match.finalRobot.unionInPlace(.Stalled)
                sender.selected = true
            }
        }
        else if sender.tag == 2 {
            if match.finalRobot.contains(.Tipped) {
                match.finalRobot.remove(.Tipped)
                sender.selected = false
            }
            else {
                match.finalRobot.unionInPlace(.Tipped)
                sender.selected = true
            }
        }
        self.view.endEditing(true)
        //print("Final Robot: \(match.finalRobot)")
    }
    
    @IBAction func ConfigTap(sender:UIButton) {
        if sender.tag == 1 {
            if match.finalConfiguration == .challenge {
                match.finalConfiguration = .none
            }
            else {
                match.finalConfiguration = .challenge
            }
        }
        else if sender.tag == 2 {
            if match.finalConfiguration == .hang {
                match.finalConfiguration = .none
            }
            else {
                match.finalConfiguration = .hang
            }
        }
        for b in EndingButtons{
            if b.tag == 1 {
                b.selected = match.finalConfiguration == .challenge
            }
            else if b.tag == 2{
                b.selected = match.finalConfiguration == .hang
            }
        }
        self.view.endEditing(true)
    }
    
    @IBAction func ResultTap(sender:UIButton) {
        if sender.tag == 1 && match.finalResult != .loss {
            match.finalResult = .loss
        }
        else if sender.tag == 2 && match.finalResult != .win {
            match.finalResult = .win
        }
        else if sender.tag == 3 && match.finalResult != .tie {
            match.finalResult = .tie
        }
        for b in MatchOutcomeButtons{
            if b.tag == 1 {
                b.selected = match.finalResult == .loss
            }
            else if b.tag == 2{
                b.selected = match.finalResult == .win
            }
            else if b.tag == 3{
                b.selected = match.finalResult == .tie
            }
        }
        self.view.endEditing(true)
        readyToMoveOn()
    }

    @IBAction func FinalScoreEndEdit(sender: UITextField) {
        if sender.text?.characters.count > 0 {
            match.finalScore = (Int(sender.text!) ?? match.finalScore)!
            sender.text = "\(match.finalScore)"
        }
        self.view.endEditing(true)
        readyToMoveOn()
        //print("finalScore: \(match.finalScore)")
    }
    
    @IBAction func FinalRPEndEdit(sender: UITextField) {
        if sender.text?.characters.count > 0 {
            match.finalRankingPoints = (Int(sender.text!) ?? match.finalRankingPoints)!
            sender.text = "\(match.finalRankingPoints)"
        }
        self.view.endEditing(true)
        readyToMoveOn()
        //print("finalScore: \(match.finalRankingPoints)")
    }
    
    @IBAction func FinalPenaltyEndEdit(sender: UITextField) {
        if sender.text?.characters.count > 0 {
            match.finalPenaltyScore = (Int(sender.text!) ?? match.finalPenaltyScore)!
            sender.text = "\(match.finalPenaltyScore)"
        }
        self.view.endEditing(true)
        readyToMoveOn()
        //print("finalScore: \(match.finalPenaltyScore)")
    }
    
    func backgroundTap(sender:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "unwindToMatchView" {
            MatchStore.sharedStore.updateCurrentMatchForType(.finalStats, match: match)
            MatchStore.sharedStore.finishCurrentMatch()
        }
    }
}

extension FinalViewController: UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        match.finalComments = textView.text
        readyToMoveOn()
    }
}
