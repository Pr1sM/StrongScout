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
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(FinalViewController.backgroundTap(_:)))
        backgroundTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(backgroundTap)
        
        FinalCommentsTextView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        match = MatchStore.sharedStore.currentMatch!
        registerForKeyboardNotifications()
        readyToMoveOn()
        FinalPenaltyScoreTextField.text = "\(match.finalPenaltyScore)"
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FinalViewController.keyboardWasShown(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FinalViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
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
        let rState = RobotState(rawValue: sender.tag)
        if sender.selected {
            match.finalRobot.subtractInPlace(rState)
        } else {
            match.finalRobot.unionInPlace(rState)
        }
        for b in EndingRobotButtons {
            b.selected = (b.tag & match.finalRobot.rawValue) == b.tag
        }
        self.view.endEditing(true)
        print("Final Robot: \(match.finalRobot)")
    }
    
    @IBAction func ConfigTap(sender:UIButton) {
        match.finalConfiguration = FinalConfigType(rawValue: sender.selected ? 0 : sender.tag)!
        for b in EndingButtons {
            b.selected = (b.tag == match.finalConfiguration.rawValue)
        }
        self.view.endEditing(true)
    }
    
    @IBAction func ResultTap(sender:UIButton) {
        let result = ResultType(rawValue: sender.tag)!
        if match.finalResult == result { return }
        
        match.finalResult = result;
        for b in MatchOutcomeButtons {
            b.selected = b.tag == match.finalResult.rawValue
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
