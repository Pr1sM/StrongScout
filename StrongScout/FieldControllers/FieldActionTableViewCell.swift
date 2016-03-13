//
//  FieldActionTableViewCell.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 2/17/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

protocol FieldActionTableViewCellDelegate {
    func actionToDeleteAtIndexPath(indexPath:NSIndexPath)
}

class FieldActionTableViewCell: UITableViewCell {
    
    var originalCenter = CGPoint()
    var originalDeleteCenter = CGPoint()
    var deleteOnDragRelease = false
    
    var delegate:FieldActionTableViewCellDelegate?
    var indexPath:NSIndexPath?
    
    let kUICuesMargin: CGFloat = 10.0, kUICuesWidth: CGFloat = 50.0
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let recognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        recognizer.delegate = self
        self.addGestureRecognizer(recognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        func createCueLabel() -> UILabel {
            let label = UILabel(frame: CGRectZero)
            label.textColor = UIColor.whiteColor()
            label.font = UIFont.boldSystemFontOfSize(32.0)
            label.backgroundColor = UIColor.redColor()
            return label
        }
        
        super.init(coder: aDecoder)
        
        let recognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        recognizer.delegate = self
        self.addGestureRecognizer(recognizer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func handlePan(sender:UIPanGestureRecognizer) {
        if sender.state == .Began {
            originalCenter = center
        } else if sender.state == .Changed {
            let translation = sender.translationInView(self)
            center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
            deleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0
        } else if sender.state == .Ended {
            let originalFrame = CGRectMake(0, frame.origin.y, bounds.size.width, bounds.size.height)
            if !deleteOnDragRelease {
                UIView.animateWithDuration(0.2, animations: { [weak self] in
                    self?.frame = originalFrame
                })
            } else {
                if delegate != nil && indexPath != nil {
                    delegate!.actionToDeleteAtIndexPath(indexPath!)
                }
            }
        }
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translationInView(superview)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
        }
        return false
    }
}



