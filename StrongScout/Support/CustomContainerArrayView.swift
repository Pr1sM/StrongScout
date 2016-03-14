//
//  CustomContainerArrayView.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 3/1/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

enum CCAVViewPos {
    case Low, High, Moving
}

struct CCAVViewData {
    var id:Int = 0
    var nc:UINavigationController
    var lowCenter:CGPoint = CGPointZero
    var highCenter:CGPoint = CGPointZero
    var panStartCenter:CGPoint = CGPointZero
    var halfwayPoint:CGPoint {
        get {
            return CGPoint(x: highCenter.x, y: (lowCenter.y + highCenter.y) / 2)
        }
    }
    var isShowing:Bool = false
    var viewPos:CCAVViewPos = .High
    
    func centerForViewPos() -> CGPoint {
        return self.viewPos == .High ? self.highCenter : self.lowCenter
    }
    
    init(id:Int, nc:UINavigationController) {
        self.id = id
        self.nc = nc
        self.lowCenter = CGPointZero
        self.highCenter = CGPointZero
        self.panStartCenter = CGPointZero
        self.isShowing = false
        self.viewPos = .High
    }
}

class CustomContainerArrayView: UIViewController {
    var views:[UIViewController] = [UIViewController]()
    var viewData:[CCAVViewData] = [CCAVViewData]()
    
    var panViews:[CCAVViewData] = [CCAVViewData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let v1 = UIViewController()
//        let v2 = UIViewController()
//        let v3 = UIViewController()
//        let v4 = UIViewController()
//        let v5 = UIViewController()
//        
//        self.views = [v1, v2, v3, v4, v5]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if viewData.count <= 0 {
            setupViewDataArray()
        }
    }
    
    func setupViewDataArray() {
        if views.count <= 0 {
            return;
        }
        
        for (index, value) in views.enumerate() {
            let nc = UINavigationController(rootViewController: value)
            nc.navigationBar.tag = index
            let tapRecog = UITapGestureRecognizer(target: self, action: "handleTap:")
            nc.navigationBar.addGestureRecognizer(tapRecog)
            if index > 0 {
                let panRecog = UIPanGestureRecognizer(target: self, action: "handlePan:")
                nc.navigationBar.addGestureRecognizer(panRecog)
                let borderRect = CGRectMake(0, 0, CGRectGetWidth(nc.navigationBar.frame), 1)
                let border = UIView(frame: borderRect)
                border.backgroundColor = UIColor.lightGrayColor()
                nc.navigationBar.addSubview(border)
            }
            
            self.addChildViewController(nc)
            
            let y = nc.navigationBar.frame.height * CGFloat(index);
            let width = self.view.bounds.width
            let height = self.view.bounds.height - (nc.navigationBar.frame.height * CGFloat(self.views.count - 1))
            let frame = CGRectMake(0, y, width, height)
            nc.view.frame = frame

            self.view.addSubview(nc.view)
            nc.didMoveToParentViewController(self)
            
//            value.navigationItem.title = "View \(index+1)"
//            let hue:CGFloat = CGFloat(arc4random_uniform(257)) / 256.0
//            let saturation:CGFloat = CGFloat(arc4random_uniform(129)) / 256.0 + 0.5
//            let brightness:CGFloat = CGFloat(arc4random_uniform(129)) / 256.0 + 0.5
//            let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
//            value.view.backgroundColor = color
            var vd = CCAVViewData(id: index, nc: nc)
            
            vd.highCenter = nc.view.center
            vd.lowCenter = CGPoint(x: vd.highCenter.x, y: vd.highCenter.y + nc.view.frame.height - nc.navigationBar.frame.height)
            viewData.append(vd)
        }
        
        viewData[viewData.count - 1].isShowing = true
    }
    
    func handleTap(sender:UITapGestureRecognizer) {
        //print("Tapped NC at Index: \(sender.view?.tag)")
        let view = self.viewData[sender.view!.tag]
        if view.isShowing { return }

        UIView.animateWithDuration(0.2, animations: {
            for (index, value) in self.viewData.enumerate() {
                if index <= sender.view!.tag {
                    value.nc.view.center = value.highCenter
                    self.viewData[index].viewPos = .High
                } else {
                    value.nc.view.center = value.lowCenter
                    self.viewData[index].viewPos = .Low
                }
            }
        })
        for var i = 0; i < self.viewData.count; i++ {
            self.viewData[i].isShowing = (i == sender.view!.tag)
        }
    }
    
    func handlePan(sender:UIPanGestureRecognizer) {
        if sender.state == .Began {
            self.panViews.removeAll()
            let view = self.viewData[sender.view!.tag]
            for var i = 0; i < self.viewData.count; i++ {
                if(i <= sender.view!.tag && view.viewPos == .Low && self.viewData[i].viewPos == .Low) {
                    panViews.append(self.viewData[i])
                } else if i >= sender.view!.tag && view.viewPos == .High && self.viewData[i].viewPos == .High {
                    panViews.append(self.viewData[i])
                }
            }
            for var i = 0; i < self.panViews.count; i++ {
                self.panViews[i].panStartCenter = self.panViews[i].nc.view.center
            }
        } else if sender.state == .Changed {
            let translation = sender.translationInView(self.viewData[sender.view!.tag].nc.view)
            for var i = 0; i < self.panViews.count; i++ {
                let newCenter = CGPoint(x: self.panViews[i].panStartCenter.x, y: self.panViews[i].panStartCenter.y + translation.y)
                self.panViews[i].viewPos = self.panViews[i].halfwayPoint.y > newCenter.y ? .High : .Low
                self.panViews[i].nc.view.center = newCenter
            }
        } else if sender.state == .Ended {
            UIView.animateWithDuration(0.2, animations: {
                for view in self.panViews {
                    view.nc.view.center = view.centerForViewPos()
                    for var i = 0; i < self.viewData.count; i++ {
                        if self.viewData[i].id == view.id {
                            self.viewData[i].viewPos = view.viewPos
                        }
                    }
                }
            }, completion: {complete in
                self.viewData[self.viewData.count - 1].isShowing = true
                for var i = 0; i < self.viewData.count-1; i++ {
                    if self.viewData[i].viewPos == .High && self.viewData[i+1].viewPos == .Low {
                        self.viewData[self.viewData.count - 1].isShowing = false
                        self.viewData[i].isShowing = true
                    } else {
                        self.viewData[i].isShowing = false
                    }
                }
            })
        }
    }
}
