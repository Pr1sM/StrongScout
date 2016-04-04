//
//  TeamInfoViewController.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 2/7/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class TeamInfoViewController: UIViewController {
    
    @IBOutlet weak var teamNumberTextField: UITextField!
    @IBOutlet weak var matchNumberTextField: UITextField!
    @IBOutlet var allianceButtons: [UIButton]!
    @IBOutlet weak var noShowButton: UIButton!
    
    var m:Match = MatchStore.sharedStore.currentMatch!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(TeamInfoViewController.backgroundTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        m = MatchStore.sharedStore.currentMatch!
        
        m.isCompleted |= 1;
        //if let m:Match = MatchStore.sharedStore.currentMatch {
            teamNumberTextField.text = m.teamNumber > 0 ? "\(m.teamNumber)" : ""
            matchNumberTextField.text = m.matchNumber > 0 ? "\(m.matchNumber)" : ""
            allianceButtons[0].selected = m.alliance == .blue
            allianceButtons[1].selected = m.alliance == .red
            noShowButton.selected = m.finalResult == .noShow
        //}
        
        readyToMoveOn()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        teamNumberTextField.resignFirstResponder()
        matchNumberTextField.resignFirstResponder()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToEndMatchNoShow" {
            MatchStore.sharedStore.updateCurrentMatchForType(.teamInfo, match: m)
            MatchStore.sharedStore.finishCurrentMatch()
        } else if segue.identifier == "segueToFieldSetup" {
            MatchStore.sharedStore.updateCurrentMatchForType(.teamInfo, match: m)
        }
    }
    
    func readyToMoveOn() {
        let disable = m.teamNumber <= 0 || m.matchNumber <= 0 || m.alliance == .unknown
        self.navigationItem.rightBarButtonItem?.enabled = !disable
    }
    
    @IBAction func textFieldEditDidEnd(sender: UITextField) {
        if sender.text?.characters.count <= 0 { return }
        if sender === teamNumberTextField {
            m.teamNumber = (Int(sender.text!) ?? m.teamNumber)!
            sender.text = m.teamNumber > 0 ? "\(m.teamNumber)" : ""
        } else if sender === matchNumberTextField {
            m.matchNumber = (Int(sender.text!) ?? m.matchNumber)!
            sender.text = m.matchNumber > 0 ? "\(m.matchNumber)" : ""
        }
        
        readyToMoveOn()
    }
    
    @IBAction func allianceTap(sender: UIButton) {
        if sender.tag == 0 {
            m.alliance = .blue
        } else if sender.tag == 1 {
            m.alliance = .red
        } else {
            m.alliance = .unknown
        }
        allianceButtons[0].selected = m.alliance == .blue
        allianceButtons[1].selected = m.alliance == .red
        self.view.endEditing(true)
        readyToMoveOn()
    }
    
    @IBAction func noShowTap(sender: UIButton) {
        sender.selected = !sender.selected
        if(sender.selected) {
            m.finalResult = .noShow
            self.navigationItem.rightBarButtonItem?.title = "End Match"
        } else {
            m.finalResult = .none
            self.navigationItem.rightBarButtonItem?.title = "Next"
        }
        self.view.endEditing(true)
    }
    
    @IBAction func nextButtonTap(sender:UIBarButtonItem) {
        if m.finalResult == .noShow {
            let noShowAC = UIAlertController(title: "No Show Match", message: "You've indicated that this team is a no show.  The match will now end.  Are you sure you want to continue?", preferredStyle: .Alert)
            let continueAction = UIAlertAction(title: "Continue", style: .Default, handler: { (action) in
                self.performSegueWithIdentifier("segueToEndMatchNoShow", sender: nil)
            })
            noShowAC.addAction(continueAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            noShowAC.addAction(cancelAction)
            
            self.presentViewController(noShowAC, animated: true, completion: nil)
        } else {
            self.performSegueWithIdentifier("segueToFieldSetup", sender: nil)
        }
    }
    
    func backgroundTap(sender:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
