//
//  SelectionButton.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 3/5/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class SelectionButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    private var selectedColor = UIColor.orangeColor()
    
    override var selected : Bool {
        didSet {
            if selected {
                self.backgroundColor = UIColor.blackColor()
                //self.titleLabel?.font = UIFont.boldSystemFontOfSize(18.0)
                //self.setTitleColor(UIColor(red: 1.0, green: 0.35, blue: 0, alpha: 1.0), forState: .Normal)
                self.setTitleColor(selectedColor, forState: .Selected)
                self.setTitleColor(UIColor.darkGrayColor(), forState: .Disabled)
            } else {
                self.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
                //self.titleLabel?.font = UIFont.systemFontOfSize(18.0)
                self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                self.setTitleColor(UIColor.darkGrayColor(), forState: .Disabled)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initLayers()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initLayers()
    }
    
    override func awakeFromNib() {
        self.initLayers()
        self.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.setTitleColor(UIColor.darkGrayColor(), forState: .Disabled)
    }
    
    func initLayers() {
        self.tintColor = UIColor.clearColor()
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(white: 0.5, alpha: 0.2).CGColor
        self.selectedColor = self.titleColorForState(.Normal)!
    }
    
    

}
