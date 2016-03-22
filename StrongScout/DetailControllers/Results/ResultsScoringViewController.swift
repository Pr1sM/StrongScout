//
//  ResultsScoringViewController.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 3/2/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class ResultsScoringViewController: UIViewController {

    @IBOutlet weak var highGoalsLabel: UILabel!
    @IBOutlet weak var lowGoalsLabel: UILabel!
    @IBOutlet weak var scoreBatters: UILabel!
    @IBOutlet weak var scoreCourtyard: UILabel!
    @IBOutlet weak var scoreDefenses: UILabel!
    
    @IBOutlet weak var autoHighGoalsLabel: UILabel!
    @IBOutlet weak var autoLowGoalsLabel: UILabel!
    @IBOutlet weak var autoScoreBatters: UILabel!
    @IBOutlet weak var autoScoreCourtyard: UILabel!
    @IBOutlet weak var autoScoreDefenses: UILabel!
    
    var match:Match!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "Score Results"
        
        highGoalsLabel.text = "\(match.teleHigh.scored)/\(match.teleHigh.scored + match.teleHigh.missed)"
        lowGoalsLabel.text = "\(match.teleLow.scored)/\(match.teleLow.scored + match.teleLow.missed)"
        scoreBatters.text = "\(match.teleBatters.scored)/\(match.teleBatters.scored + match.teleBatters.missed)"
        scoreCourtyard.text = "\(match.teleCourtyard.scored)/\(match.teleCourtyard.scored + match.teleCourtyard.missed)"
        scoreDefenses.text = "\(match.teleDefenses.scored)/\(match.teleDefenses.scored + match.teleDefenses.missed)"
        
        autoHighGoalsLabel.text = "\(match.autoHigh.scored)/\(match.autoHigh.scored + match.autoHigh.missed)"
        autoLowGoalsLabel.text = "\(match.autoLow.scored)/\(match.autoLow.scored + match.autoLow.missed)"
        autoScoreBatters.text = "\(match.autoBatters.scored)/\(match.autoBatters.scored + match.autoBatters.missed)"
        autoScoreCourtyard.text = "\(match.autoCourtyard.scored)/\(match.autoCourtyard.scored + match.autoCourtyard.missed)"
        autoScoreDefenses.text = "\(match.autoDefenses.scored)/\(match.autoDefenses.scored + match.autoDefenses.missed)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
