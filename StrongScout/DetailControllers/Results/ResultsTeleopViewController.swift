
//
//  ResultsTeleopViewController.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 3/2/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class ResultsTeleopViewController: UIViewController {

    @IBOutlet var defense1: [UILabel]!
    @IBOutlet var defense2: [UILabel]!
    @IBOutlet var defense3: [UILabel]!
    @IBOutlet var defense4: [UILabel]!
    @IBOutlet var defense5: [UILabel]!
    
    var match:Match!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "Defense Stats"
        let defenseData = match.defenses
        let defenses = [defense1, defense2, defense3, defense4, defense5]
        for i in 0 ..< 5 {
            let data = defenseData[i].toArray(match.finalResult)
            for j in 0 ..< 5 {
                defenses[i][j].text = data[j]
            }
        }
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
