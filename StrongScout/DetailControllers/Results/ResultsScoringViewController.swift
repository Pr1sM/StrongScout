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
        
        highGoalsLabel.text = "\(match.scoreHigh)/\(match.scoreHigh + match.scoreMissedHigh)"
        lowGoalsLabel.text = "\(match.scoreLow)/\(match.scoreLow + match.scoreMissedLow)"
        scoreBatters.text = "\(match.scoredBatters)"
        scoreCourtyard.text = "\(match.scoredMiddle)"
        scoreDefenses.text = "\(match.scoredDefenses)"
        
        autoHighGoalsLabel.text = "\(match.autoScoreHigh)/\(match.autoScoreHigh + match.autoMissedHigh)"
        autoLowGoalsLabel.text = "\(match.autoScoreLow)/\(match.autoScoreLow + match.autoMissedLow)"
        autoScoreBatters.text = "\(match.autoScoredBatters)"
        autoScoreCourtyard.text = "\(match.autoScoredMiddle)"
        autoScoreDefenses.text = "\(match.autoScoredDefenses)"
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
