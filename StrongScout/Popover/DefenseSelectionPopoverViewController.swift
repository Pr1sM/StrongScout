//
//  DefenseSelectionPopoverViewController.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 2/6/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

protocol DefenseSelectionPopoverDelegate {
    func defenseSelection(defenseSelection:DefenseSelectionPopoverViewController, didSelectDefense type:DefenseType, withImage image:UIImage?, withTag tag:Int)
}

struct defenseImage {
    var largeImage = UIImage()
    var thumbnail = UIImage()
    var defenseType = DefenseType.unknown
    
    init (largeImageName:String, thumbnailName:String, type:DefenseType) {
        largeImage = UIImage(named: largeImageName)!
        thumbnail = UIImage(named: thumbnailName)!
        defenseType = type
    }
}

class DefenseSelectionPopoverViewController: UICollectionViewController {
    
    var m:Match = MatchStore.sharedStore.currentMatch!
    
    private let reuseIdentifier = "DefenseSelectionPopoverCollectionViewCell"
    private let sectionInsets = UIEdgeInsets(top: 30.0, left: 10.0, bottom: 30.0, right: 10.0)
    
    private let defenseImages = [defenseImage(largeImageName: "portcullis",
                                               thumbnailName: "portcullisThumbnail",
                                                        type: .portcullis),
                                 defenseImage(largeImageName: "chevaldefrise",
                                               thumbnailName: "chevaldefriseThumbnail",
                                                        type: .chevaldefrise),
                                 defenseImage(largeImageName: "moat",
                                               thumbnailName: "moatThumbnail",
                                                        type: .moat),
                                 defenseImage(largeImageName: "ramparts",
                                               thumbnailName: "rampartsThumbnail",
                                                        type: .ramparts),
                                 defenseImage(largeImageName: "drawbridge",
                                               thumbnailName: "drawbridgeThumbnail",
                                                        type: .drawbridge),
                                 defenseImage(largeImageName: "sallyport",
                                               thumbnailName: "sallyportThumbnail",
                                                        type: .sallyport),
                                 defenseImage(largeImageName: "rockwall",
                                               thumbnailName: "rockwallThumbnail",
                                                        type: .rockwall),
                                 defenseImage(largeImageName: "roughterrain",
                                               thumbnailName: "roughterrainThumbnail",
                                                        type: .roughterrain)]
    
    var selectedType : DefenseType = .unknown
    
    var delegate:DefenseSelectionPopoverDelegate?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        m = MatchStore.sharedStore.currentMatch!
    }
}

extension DefenseSelectionPopoverViewController {
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return defenseImages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DefenseSelectionCollectionViewCell
        
        cell.backgroundColor = UIColor.blackColor()
        let defenseImage = defenseImages[indexPath.row]
        cell.imageView.image = defenseImage.thumbnail
        
        for d in m.defenses {
            if d.type == defenseImage.defenseType || d.type.complementType() == defenseImage.defenseType {
                cell.backgroundColor = UIColor.redColor()
                break
            }
        }
        
        if(defenseImage.defenseType == selectedType || defenseImage.defenseType == selectedType.complementType()) {
            cell.backgroundColor = UIColor.blackColor()
        }
        
        if(defenseImage.defenseType == selectedType) {
            cell.selected = true
        } else {
            cell.selected = false
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "DefenseSelectionHeaderView", forIndexPath: indexPath) as! DefenseSelectionHeaderView
            headerView.label.text = "Select Defense"
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
}

extension DefenseSelectionPopoverViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let defense = defenseImages[indexPath.row].thumbnail
            var size = defense.size
            size.width += 10
            size.height += 10
            return size
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return sectionInsets
    }
}

extension DefenseSelectionPopoverViewController {
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let defenseImage = defenseImages[indexPath.row]
        if defenseImage.defenseType == selectedType {
            selectedType = .unknown
            delegate?.defenseSelection(self, didSelectDefense: selectedType, withImage: nil, withTag: self.view.tag)
            //m = MatchStore.sharedStore.currentMatch!
        } else {
            selectedType = defenseImage.defenseType
            delegate?.defenseSelection(self, didSelectDefense: defenseImages[indexPath.row].defenseType, withImage: defenseImages[indexPath.row].largeImage, withTag: self.view.tag)
            
        }
        m = MatchStore.sharedStore.currentMatch!
        self.collectionView?.reloadData()
        
        return false
    }
}
