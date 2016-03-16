//
//  Definitions.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 2/13/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import Foundation
import UIKit

// MARK: PropertyListReadable Protocol
protocol PropertyListReadable {
    func propertyListRepresentation() -> NSDictionary
    init?(propertyListRepresentation:NSDictionary?)
}

// MARK: DefenseType
enum DefenseType:Int {
    case unknown = 0, portcullis, chevaldefrise, moat, ramparts, drawbridge, sallyport, rockwall, roughterrain, lowbar
    
    func complementType() -> DefenseType {
        return (self == .portcullis) ? .chevaldefrise :
               (self == .chevaldefrise) ? .portcullis :
               (self == .moat) ? .ramparts :
               (self == .ramparts) ? .moat :
               (self == .drawbridge) ? .sallyport :
               (self == .sallyport) ? .drawbridge :
               (self == .rockwall) ? .roughterrain :
               (self == .roughterrain) ? .rockwall : .unknown
    }
    
    func toString() -> String! {
        return (self == .portcullis) ? "portcullis" :
               (self == .chevaldefrise) ? "chevaldefrise" :
               (self == .moat) ? "moat" :
               (self == .ramparts) ? "ramparts" :
               (self == .drawbridge) ? "drawbridge" :
               (self == .sallyport) ? "sallyport" :
               (self == .rockwall) ? "rockwall" :
               (self == .roughterrain) ? "roughterrain" :
               (self == .lowbar) ? "lowbar" : "unknown"
    }
    
    func toStringResults() -> String {
        return (self == .portcullis) ? "Portcullis" :
            (self == .chevaldefrise) ? "Cheval de Frise" :
            (self == .moat) ? "Moat" :
            (self == .ramparts) ? "Ramparts" :
            (self == .drawbridge) ? "Drawbridge" :
            (self == .sallyport) ? "Sallyport" :
            (self == .rockwall) ? "Rock Wall" :
            (self == .roughterrain) ? "Rough Terrain" :
            (self == .lowbar) ? "Low Bar" : "Unknown"
    }
}

// MARK: ScoreType
enum ScoreType: Int {
    case Unknown = 0, MissedHigh, High, MissedLow, Low
    
    func toString() -> String {
        return (self == .High)        ? "Scored High Goal" :
               (self == .Low)         ? "Scored Low Goal " :
               (self == .MissedHigh)  ? "Missed High Goal" :
               (self == .MissedLow)   ? "Missed Low Goal"  : "Unknown"
    }
}

// MARK: ScoreLocation
enum ScoreLocation: Int {
    case Unknown = 0, Batter, Courtyard, Defenses
    
    func toString() -> String {
        return (self == .Batter)    ? "Batter"    :
               (self == .Courtyard) ? "Courtyard" :
               (self == .Defenses)  ? "Defenses"  : "Unknown"
    }
}

// MARK: FieldLayoutType
enum FieldLayoutType: Int {
    case BlueRed = 0, RedBlue
    
    mutating func reverse() {
        self = self == .BlueRed ? .RedBlue : .BlueRed
    }
    
    func getImage() -> UIImage {
        return self == .BlueRed ? UIImage(named: "fieldLayoutBlueRed")! : UIImage(named: "fieldLayoutRedBlue")!
    }
}

// MARK: AllianceType
enum AllianceType : Int {
    case unknown = 0, blue, red
    
    func toString() -> String {
        return (self == .blue) ? "Blue" : "Red"
    }
}

// MARK: ActionType
enum ActionType : Int {
    case unknown = 0, score, defense, penalty
    
    func toString() -> String {
        return (self == .score)   ? "Score"   :
               (self == .defense) ? "Defense" :
               (self == .penalty) ? "Penalty" : "Unknown"
    }
}

// MARK: EditType
enum EditType : Int {
    case Delete = 0, Add
    
    mutating func reverse() {
        self = self == .Delete ? .Add : .Delete;
    }
}

// MARK: SectionType
enum SectionType : Int {
    case auto = 0, tele
    
    func toString() -> String {
        return (self == .auto) ? "Autonomous" : "Teleop"
    }
}

// MARK: DefenseAction
enum DefenseAction: Int {
    case None = 0, Crossed, AttemptedCross, CrossedWithBall, AssistedCross
    
    func toString() -> String {
        return (self == .Crossed)         ? "Crossed"             :
               (self == .AttemptedCross)  ? "Attempted Cross"     :
               (self == .CrossedWithBall) ? "Crossed With Ball"   :
               (self == .AssistedCross)   ? "Assisted With Cross" : "None"
    }
}

// MARK: FinalConfigType
enum FinalConfigType : Int {
    case none = 0, hang, challenge
    
    func toString() -> String {
        return (self == .hang) ? "Hang" :
               (self == .challenge) ? "Challenge" : "N/A"
    }
}

// MARK: ResultType
enum ResultType : Int {
    case none = 0, loss, win, tie, noShow
    
    func toString() -> String {
        return (self == .loss) ? "Loss" :
               (self == .win) ? "Win" :
               (self == .tie) ? "Tie" :
               (self == .noShow) ? "No Show" : "N/A"
    }
}

// MARK: UpdateType
enum UpdateType : Int {
    case none = 0, teamInfo, fieldSetup, finalStats, actionsEdited
}

// MARK: PenaltyType
enum PenaltyType : Int {
    case None = 0, Foul, TechFoul, YellowCard, RedCard
    
    func toString() -> String {
        return self == .Foul       ? "Foul"           :
               self == .TechFoul   ? "Technical Foul" :
               self == .YellowCard ? "Yellow Card"    :
               self == .RedCard    ? "Red Card"       : "None"
    }
}

// MARK: RobotState
struct RobotState:OptionSetType {
    let rawValue:Int
    
    static let None = RobotState(rawValue:0)
    static let Stalled = RobotState(rawValue: 1 << 0)
    static let Tipped = RobotState(rawValue: 1 << 1)
    
    func toString() -> String {
        switch self.rawValue {
        case RobotState.Stalled.rawValue:
            return "Stalled"
        case RobotState.Tipped.rawValue:
            return "Tipped"
        case RobotState.Tipped.union(.Stalled).rawValue:
            return "Stall+Tip"
        default:
            return "None"
        }
    }
}

// MARK: Defense
struct Defense: PropertyListReadable {
    var type:DefenseType = .unknown
    var location:Int = 0
    var timesCrossed:Int = 0
    var failedTimesCrossed:Int = 0
    var timesCrossedWithBall:Int = 0
    var timesAssistedCross:Int = 0
    var autoTimesCrossed:Int = 0
    var autoFailedTimesCrossed:Int = 0
    var autoTimesCrossedWithBall:Int = 0
    var autoTimesAssistedCross:Int = 0
    
    init() {
        
    }
    
    init(withDefenseType type:DefenseType) {
        self.type = type
    }
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let values = propertyListRepresentation else { return nil }
        if let t = values["type"]   as? Int,
           let l = values["loc"]    as? Int,
           let c = values["cross"]  as? Int,
           let f = values["fcross"] as? Int,
           let b = values["bcross"] as? Int,
           let a = values["across"] as? Int,
           let ac = values["atcross"] as? Int,
           let af = values["afcross"] as? Int,
           let ab = values["abcross"] as? Int,
           let aa = values["aacross"] as? Int {
            self.type = DefenseType(rawValue: t)!
            self.location = l
            self.timesCrossed = c
            self.failedTimesCrossed = f
            self.timesCrossedWithBall = b
            self.timesAssistedCross = a
            self.autoTimesCrossed = ac
            self.autoFailedTimesCrossed = af
            self.autoTimesCrossedWithBall = ab
            self.autoTimesAssistedCross = aa
        }
    }
    
    mutating func clearStats() {
        self.timesCrossed = 0
        self.failedTimesCrossed = 0
        self.timesCrossedWithBall = 0
        self.timesAssistedCross = 0
        self.autoTimesCrossed = 0
        self.autoFailedTimesCrossed = 0
        self.autoTimesCrossedWithBall = 0
        self.autoTimesAssistedCross = 0
    }
    
    func toArray() -> [String] {
        return ["Defense \(self.location): \(self.type.toStringResults())",
            "\(self.autoTimesCrossed) | \(self.timesCrossed)",
            "\(self.autoTimesCrossedWithBall) | \(self.timesCrossedWithBall)",
            "\(self.autoFailedTimesCrossed) | \(self.failedTimesCrossed)",
            "\(self.autoTimesAssistedCross) | \(self.timesAssistedCross)"]
    }
    
    func propertyListRepresentation() -> NSDictionary {
        let representation:[String:AnyObject] = ["type":type.rawValue, "loc":location, "cross":timesCrossed, "fcross":failedTimesCrossed, "bcross":timesCrossedWithBall, "across":timesAssistedCross, "atcross":autoTimesCrossed, "afcross":autoFailedTimesCrossed, "abcross":autoTimesCrossedWithBall, "aacross":autoTimesAssistedCross]
        
        return representation
    }
}

// MARK: Score
struct Score: PropertyListReadable {
    var type:ScoreType = .Unknown
    var location:ScoreLocation = .Unknown
    
    init() {
        
    }
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let values = propertyListRepresentation else { return nil }
        if let t = values["type"] as? Int, let l = values["loc"] as? Int {
            self.type = ScoreType(rawValue: t)!
            self.location = ScoreLocation(rawValue: l)!
        }
    }
    
    func propertyListRepresentation() -> NSDictionary {
        let representation:[String:AnyObject] = ["type":type.rawValue, "loc":location.rawValue]
        return representation
    }
}

// MARK: DefenseInfo
struct DefenseInfo: PropertyListReadable {
    var type:DefenseType = .unknown
    var actionPerformed:DefenseAction = .None
    
    init() {
    
    }
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let values = propertyListRepresentation else { return nil }
        if let t = values["type"] as? Int, let a = values["action"] as? Int {
            self.type = DefenseType(rawValue: t)!
            self.actionPerformed = DefenseAction(rawValue: a)!
        }
    }
    
    func propertyListRepresentation() -> NSDictionary {
        let representation:[String:AnyObject] = ["type":type.rawValue, "action":actionPerformed.rawValue]
        return representation
    }
}

// MARK: ActionData
enum ActionData: PropertyListReadable {
    case None
    case ScoreData(Score)
    case DefenseData(DefenseInfo)
    case PenaltyData(PenaltyType)
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let values = propertyListRepresentation else { return nil }
        if let s = values["score"] as? NSDictionary {
            self = ActionData.ScoreData(Score(propertyListRepresentation: s)!)
        } else if let d = values["defense"] as? NSDictionary {
            self = .DefenseData(DefenseInfo(propertyListRepresentation: d)!)
        } else if let p = values["penalty"] as? Int {
            self = .PenaltyData(PenaltyType(rawValue: p)!)
        } else {
            self = .None
        }
    }
    
    func propertyListRepresentation() -> NSDictionary {
        switch self {
        case let .ScoreData(score):
            return ["score":score.propertyListRepresentation()]
        case let .DefenseData(defense):
            return ["defense":defense.propertyListRepresentation()]
        case let .PenaltyData(penalty):
            return ["penalty":penalty.rawValue]
        default:
            return ["none":0]
        }
    }
}

// MARK: Action
struct Action: PropertyListReadable {
    var section:SectionType = .tele
    var type:ActionType = .unknown
    var data:ActionData = .None
    
    init() {}
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let values = propertyListRepresentation else { return nil }
        if let t = values["type"] as? Int,
           let s = values["section"] as? Int,
           let d = values["data"] as? NSDictionary {
            self.type = ActionType(rawValue: t)!
            self.section = SectionType(rawValue: s)!
            self.data = ActionData(propertyListRepresentation: d)!
        }
    }
    
    func propertyListRepresentation() -> NSDictionary {
        return ["type":type.rawValue, "section":section.rawValue, "data":data.propertyListRepresentation()]
    }
}

// MARK: ActionEdit
struct ActionEdit {
    var action:Action
    var index:Int
    var edit:EditType
    
    init(edit:EditType, action:Action, atIndex index:Int) {
        self.edit = edit
        self.action = action
        self.index = index
    }
}

// MARK: Stack
struct Stack<Element> {
    private var items = [Element]()
    private var limit:Int
    
    init(limit:Int) {
        self.limit = limit
    }
    
    mutating func push(item:Element) {
        if items.count == limit {
            items.removeFirst()
        }
        items.append(item)
    }
    
    mutating func pop() -> Element {
        return items.removeLast()
    }
    
    func peek() -> Element? {
        return items.last
    }
    
    func size() -> Int {
        return items.count
    }
    
    mutating func clearAll() {
        items.removeAll()
    }
}
