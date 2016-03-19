//
//  Match.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 2/6/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import SwiftyJSON

class Match : NSObject, NSCoding {
    
    // Team Info
    
    var teamNumber:Int = -1
    var matchNumber:Int = -1
    var alliance:AllianceType = .unknown
    var isCompleted:Int = 32
    
    // Auto Scoring Info
    
    var autoScoreHigh:Int = 0
    var autoScoreLow:Int = 0
    var autoMissedHigh:Int = 0
    var autoMissedLow:Int = 0
    var autoScoredBatters:Int = 0
    var autoScoredMiddle:Int = 0
    var autoScoredDefenses:Int = 0
    
    // Scoring Info
    
    var scoreHigh:Int = 0
    var scoreLow:Int = 0
    var scoreMissedHigh:Int = 0
    var scoreMissedLow:Int = 0
    var scoredBatters:Int = 0
    var scoredMiddle:Int = 0
    var scoredDefenses:Int = 0
    
    // Defense Info
    
    var defense1 = Defense(withDefenseType: .lowbar)
    var defense2 = Defense()
    var defense3 = Defense()
    var defense4 = Defense()
    var defense5 = Defense()
    lazy var defenses:[Defense] = [self.defense1, self.defense2, self.defense3, self.defense4, self.defense5]
    
    // Action Info
    
    var actionsPerformed:[Action] = []
    
    // Final Info
    
    var finalScore:Int = -1
    var finalRankingPoints:Int = -1
    var finalResult:ResultType = .none
    var finalPenaltyScore:Int = -1
    var finalFouls = 0
    var finalTechFouls = 0
    var finalYellowCards = 0
    var finalRedCards = 0
    var finalRobot:RobotState = .None
    var finalConfiguration:FinalConfigType = .none
    var finalComments = ""
    
    func aggregateActionsPerformed() {
        self.scoreHigh      = 0
        self.scoreLow       = 0
        self.scoredBatters  = 0
        self.scoredDefenses = 0
        self.scoredMiddle   = 0
        
        self.defense1.clearStats()
        self.defense2.clearStats()
        self.defense3.clearStats()
        self.defense4.clearStats()
        self.defense5.clearStats()
        
        self.defense1.location = 1
        self.defense2.location = 2
        self.defense3.location = 3
        self.defense4.location = 4
        self.defense5.location = 5
        
        self.finalFouls = 0
        self.finalTechFouls = 0
        self.finalYellowCards = 0
        self.finalRedCards = 0
        
        for action in self.actionsPerformed {
            if let a:Action = action {
                switch a.data {
                case let .ScoreData(score):
                    if a.section == .tele {
                        self.scoreHigh       += (score.type == .High)          ? 1 : 0
                        self.scoreLow        += (score.type == .Low)           ? 1 : 0
                        self.scoreMissedHigh += (score.type == .MissedHigh)    ? 1 : 0
                        self.scoreMissedLow  += (score.type == .MissedLow)     ? 1 : 0
                        self.scoredBatters   += (score.location == .Batter)    ? 1 : 0
                        self.scoredMiddle    += (score.location == .Courtyard) ? 1 : 0
                        self.scoredDefenses  += (score.location == .Defenses)  ? 1 : 0
                    } else {
                        self.autoScoreHigh      += (score.type == .High)          ? 1 : 0
                        self.autoScoreLow       += (score.type == .Low)           ? 1 : 0
                        self.autoMissedHigh     += (score.type == .MissedHigh)    ? 1 : 0
                        self.autoMissedLow      += (score.type == .MissedLow)     ? 1 : 0
                        self.autoScoredBatters  += (score.location == .Batter)    ? 1 : 0
                        self.autoScoredMiddle   += (score.location == .Courtyard) ? 1 : 0
                        self.autoScoredDefenses += (score.location == .Defenses)  ? 1 : 0
                    }
                    continue
                case let .DefenseData(defense):
                    if defense.type == self.defense1.type {
                        if a.section == .tele {
                            self.defense1.timesCrossed         += (defense.actionPerformed == .Crossed)         ? 1 : 0
                            self.defense1.failedTimesCrossed   += (defense.actionPerformed == .AttemptedCross)  ? 1 : 0
                            self.defense1.timesCrossedWithBall += (defense.actionPerformed == .CrossedWithBall) ? 1 : 0
                            self.defense1.timesAssistedCross   += (defense.actionPerformed == .AssistedCross)   ? 1 : 0
                        } else {
                            self.defense1.autoTimesCrossed         += (defense.actionPerformed == .Crossed)         ? 1 : 0
                            self.defense1.autoFailedTimesCrossed   += (defense.actionPerformed == .AttemptedCross)  ? 1 : 0
                            self.defense1.autoTimesCrossedWithBall += (defense.actionPerformed == .CrossedWithBall) ? 1 : 0
                            self.defense1.autoTimesAssistedCross   += (defense.actionPerformed == .AssistedCross)   ? 1 : 0
                        }
                    } else if defense.type == self.defense2.type {
                        if a.section == .tele {
                            self.defense2.timesCrossed         += (defense.actionPerformed == .Crossed)         ? 1 : 0
                            self.defense2.failedTimesCrossed   += (defense.actionPerformed == .AttemptedCross)  ? 1 : 0
                            self.defense2.timesCrossedWithBall += (defense.actionPerformed == .CrossedWithBall) ? 1 : 0
                            self.defense2.timesAssistedCross   += (defense.actionPerformed == .AssistedCross)   ? 1 : 0
                        } else {
                            self.defense2.autoTimesCrossed         += (defense.actionPerformed == .Crossed)         ? 1 : 0
                            self.defense2.autoFailedTimesCrossed   += (defense.actionPerformed == .AttemptedCross)  ? 1 : 0
                            self.defense2.autoTimesCrossedWithBall += (defense.actionPerformed == .CrossedWithBall) ? 1 : 0
                            self.defense2.autoTimesAssistedCross   += (defense.actionPerformed == .AssistedCross)   ? 1 : 0
                        }
                    } else if defense.type == self.defense3.type {
                        if a.section == .tele {
                            self.defense3.timesCrossed         += (defense.actionPerformed == .Crossed)         ? 1 : 0
                            self.defense3.failedTimesCrossed   += (defense.actionPerformed == .AttemptedCross)  ? 1 : 0
                            self.defense3.timesCrossedWithBall += (defense.actionPerformed == .CrossedWithBall) ? 1 : 0
                            self.defense3.timesAssistedCross   += (defense.actionPerformed == .AssistedCross)   ? 1 : 0
                        } else {
                            self.defense3.autoTimesCrossed         += (defense.actionPerformed == .Crossed)         ? 1 : 0
                            self.defense3.autoFailedTimesCrossed   += (defense.actionPerformed == .AttemptedCross)  ? 1 : 0
                            self.defense3.autoTimesCrossedWithBall += (defense.actionPerformed == .CrossedWithBall) ? 1 : 0
                            self.defense3.autoTimesAssistedCross   += (defense.actionPerformed == .AssistedCross)   ? 1 : 0
                        }
                    } else if defense.type == self.defense4.type {
                        if a.section == .tele {
                            self.defense4.timesCrossed         += (defense.actionPerformed == .Crossed)         ? 1 : 0
                            self.defense4.failedTimesCrossed   += (defense.actionPerformed == .AttemptedCross)  ? 1 : 0
                            self.defense4.timesCrossedWithBall += (defense.actionPerformed == .CrossedWithBall) ? 1 : 0
                            self.defense4.timesAssistedCross   += (defense.actionPerformed == .AssistedCross)   ? 1 : 0
                        } else {
                            self.defense4.autoTimesCrossed         += (defense.actionPerformed == .Crossed)         ? 1 : 0
                            self.defense4.autoFailedTimesCrossed   += (defense.actionPerformed == .AttemptedCross)  ? 1 : 0
                            self.defense4.autoTimesCrossedWithBall += (defense.actionPerformed == .CrossedWithBall) ? 1 : 0
                            self.defense4.autoTimesAssistedCross   += (defense.actionPerformed == .AssistedCross)   ? 1 : 0
                        }
                    } else if defense.type == self.defense5.type {
                        if a.section == .tele {
                            self.defense5.timesCrossed         += (defense.actionPerformed == .Crossed)         ? 1 : 0
                            self.defense5.failedTimesCrossed   += (defense.actionPerformed == .AttemptedCross)  ? 1 : 0
                            self.defense5.timesCrossedWithBall += (defense.actionPerformed == .CrossedWithBall) ? 1 : 0
                            self.defense5.timesAssistedCross   += (defense.actionPerformed == .AssistedCross)   ? 1 : 0
                        } else {
                            self.defense5.autoTimesCrossed         += (defense.actionPerformed == .Crossed)         ? 1 : 0
                            self.defense5.autoFailedTimesCrossed   += (defense.actionPerformed == .AttemptedCross)  ? 1 : 0
                            self.defense5.autoTimesCrossedWithBall += (defense.actionPerformed == .CrossedWithBall) ? 1 : 0
                            self.defense5.autoTimesAssistedCross   += (defense.actionPerformed == .AssistedCross)   ? 1 : 0
                        }
                    }
                    continue
                case let .PenaltyData(penalty):
                    self.finalFouls       += (penalty == .Foul)       ? 1 : 0
                    self.finalTechFouls   += (penalty == .TechFoul)   ? 1 : 0
                    self.finalYellowCards += (penalty == .YellowCard) ? 1 : 0
                    self.finalRedCards    += (penalty == .RedCard)    ? 1 : 0
                    continue
                default:
                    continue
                }
            }
        }
        self.defenses = [defense1, defense2, defense3, defense4, defense5]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        // Team Information
        aCoder.encodeInteger(teamNumber,        forKey: "teamNumber")
        aCoder.encodeInteger(matchNumber,       forKey: "matchNumber")
        aCoder.encodeInteger(alliance.rawValue, forKey: "alliance")
        aCoder.encodeInteger(isCompleted,       forKey: "isCompleted")
        
        // Auto Score Information
        aCoder.encodeInteger(autoScoreHigh,      forKey: "autoScoreHigh")
        aCoder.encodeInteger(autoScoreLow,       forKey: "autoScoreLow")
        aCoder.encodeInteger(autoMissedHigh,     forKey: "autoMissedHigh")
        aCoder.encodeInteger(autoMissedLow,      forKey: "autoMissedLow")
        aCoder.encodeInteger(autoScoredBatters,  forKey: "autoScoredBatters")
        aCoder.encodeInteger(autoScoredMiddle,   forKey: "autoScoredCourtyard")
        aCoder.encodeInteger(autoScoredDefenses, forKey: "autoScoredDefenses")
        
        // Score Information
        aCoder.encodeInteger(scoreHigh,       forKey: "scoreHigh")
        aCoder.encodeInteger(scoreLow,        forKey: "scoreLow")
        aCoder.encodeInteger(scoreMissedHigh, forKey: "scoreMissedHigh")
        aCoder.encodeInteger(scoreMissedLow,  forKey: "scoreMissedLow")
        aCoder.encodeInteger(scoredBatters,   forKey: "scoredBatters")
        aCoder.encodeInteger(scoredMiddle,    forKey: "scoredCourtyard")
        aCoder.encodeInteger(scoredDefenses,  forKey: "scoredDefenses")
        
        // Defense Information
        aCoder.encodeObject(defense1.propertyListRepresentation(), forKey: "defense1")
        aCoder.encodeObject(defense2.propertyListRepresentation(), forKey: "defense2")
        aCoder.encodeObject(defense3.propertyListRepresentation(), forKey: "defense3")
        aCoder.encodeObject(defense4.propertyListRepresentation(), forKey: "defense4")
        aCoder.encodeObject(defense5.propertyListRepresentation(), forKey: "defense5")
        
        // Actions Information
        var actionsPerformedPList:[NSDictionary] = []
        for a in actionsPerformed {
            actionsPerformedPList.append(a.propertyListRepresentation())
        }
        aCoder.encodeObject(actionsPerformedPList, forKey: "actionsPerformed")
        
        // Final Information
        aCoder.encodeInteger(finalScore,                  forKey: "finalScore")
        aCoder.encodeInteger(finalRankingPoints,          forKey: "finalRankingPoints")
        aCoder.encodeInteger(finalResult.rawValue,        forKey: "finalResult")
        aCoder.encodeInteger(finalPenaltyScore,           forKey: "finalPenaltyScore")
        aCoder.encodeInteger(finalFouls,                  forKey: "finalFouls")
        aCoder.encodeInteger(finalTechFouls,              forKey: "finalTechFouls")
        aCoder.encodeInteger(finalYellowCards,            forKey: "finalYellowCards")
        aCoder.encodeInteger(finalRedCards,               forKey: "finalRedCards")
        aCoder.encodeInteger(finalRobot.rawValue,         forKey: "finalRobot")
        aCoder.encodeInteger(finalConfiguration.rawValue, forKey: "finalConfiguration")
        aCoder.encodeObject(finalComments,                forKey: "finalComments")
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        // Team Information
        self.teamNumber  = aDecoder.decodeIntegerForKey("teamNumber")
        self.matchNumber = aDecoder.decodeIntegerForKey("matchNumber")
        self.alliance    = AllianceType(rawValue:aDecoder.decodeIntegerForKey("alliance"))!
        self.isCompleted = aDecoder.decodeIntegerForKey("isCompleted")
        
        // Auto Score Information
        self.autoScoreHigh       = aDecoder.decodeIntegerForKey("autoScoreHigh")
        self.autoScoreLow        = aDecoder.decodeIntegerForKey("autoScoreLow")
        self.autoMissedHigh      = aDecoder.decodeIntegerForKey("autoMissedHigh")
        self.autoMissedLow       = aDecoder.decodeIntegerForKey("autoMissedLow")
        self.autoScoredBatters   = aDecoder.decodeIntegerForKey("autoScoredBatters")
        self.autoScoredMiddle    = aDecoder.decodeIntegerForKey("autoScoredMiddle")
        self.autoScoredDefenses  = aDecoder.decodeIntegerForKey("autoScoredDefenses")
        
        // Score Information
        self.scoreHigh       = aDecoder.decodeIntegerForKey("scoreHigh")
        self.scoreLow        = aDecoder.decodeIntegerForKey("scoreLow")
        self.scoreMissedHigh = aDecoder.decodeIntegerForKey("scoreMissedHigh")
        self.scoreMissedLow  = aDecoder.decodeIntegerForKey("scoreMissedLow")
        self.scoredBatters   = aDecoder.decodeIntegerForKey("scoredBatters")
        self.scoredMiddle    = aDecoder.decodeIntegerForKey("scoredMiddle")
        self.scoredDefenses  = aDecoder.decodeIntegerForKey("scoredDefenses")
        
        // Defense Information
        self.defense1 = Defense(propertyListRepresentation: aDecoder.decodeObjectForKey("defense1") as? NSDictionary)!
        self.defense2 = Defense(propertyListRepresentation: aDecoder.decodeObjectForKey("defense2") as? NSDictionary)!
        self.defense3 = Defense(propertyListRepresentation: aDecoder.decodeObjectForKey("defense3") as? NSDictionary)!
        self.defense4 = Defense(propertyListRepresentation: aDecoder.decodeObjectForKey("defense4") as? NSDictionary)!
        self.defense5 = Defense(propertyListRepresentation: aDecoder.decodeObjectForKey("defense5") as? NSDictionary)!
        
        // Actions Information
        let actionsPerformedPList = aDecoder.decodeObjectForKey("actionsPerformed") as? [NSDictionary]
        self.actionsPerformed = []
        for pList in actionsPerformedPList! {
            guard let action = Action(propertyListRepresentation: pList) else { continue }
            self.actionsPerformed.append(action)
        }
        
        // Final Information
        self.finalScore         = aDecoder.decodeIntegerForKey("finalScore")
        self.finalRankingPoints = aDecoder.decodeIntegerForKey("finalRankingPoints")
        self.finalResult        = ResultType(rawValue: aDecoder.decodeIntegerForKey("finalResult"))!
        self.finalPenaltyScore  = aDecoder.decodeIntegerForKey("finalPenaltyScore")
        self.finalFouls         = aDecoder.decodeIntegerForKey("finalFouls")
        self.finalTechFouls     = aDecoder.decodeIntegerForKey("finalTechFouls")
        self.finalYellowCards   = aDecoder.decodeIntegerForKey("finalYellowCards")
        self.finalRedCards      = aDecoder.decodeIntegerForKey("finalRedCards")
        self.finalRobot         = RobotState(rawValue: aDecoder.decodeIntegerForKey("finalRobot"))
        self.finalConfiguration = FinalConfigType(rawValue: aDecoder.decodeIntegerForKey("finalConfiguration"))!
        self.finalComments      = (aDecoder.decodeObjectForKey("finalComments") as? String) ?? ""
    }
    
    override init() {
        // init
    }
    
    init(queueData:MatchQueueData) {
        self.matchNumber = queueData.matchNumber
        self.teamNumber  = queueData.teamNumber
        self.alliance    = queueData.alliance
    }
    
    func messageDictionary() -> NSDictionary {
        var data:[String:AnyObject]    = [String:AnyObject]()
        var team:[String:AnyObject]    = [String:AnyObject]()
        var auto:[String:AnyObject]    = [String:AnyObject]()
        var score:[String:AnyObject]   = [String:AnyObject]()
        var defense:[String:AnyObject] = [String:AnyObject]()
        var final:[String:AnyObject]   = [String:AnyObject]()
        
        // Team Info
        team["teamNumber"]  = teamNumber
        team["matchNumber"] = matchNumber
        team["alliance"]    = alliance.toString()
        
        // Auto
        auto["scoreHigh"]      = autoScoreHigh
        auto["scoreLow"]       = autoScoreLow
        auto["missedHigh"]     = autoMissedHigh
        auto["missedLow"]      = autoMissedLow
        auto["scoreBatters"]   = autoScoredBatters
        auto["scoreCourtyard"] = autoScoredMiddle
        auto["scoreDefenses"]  = autoScoredDefenses
        
        // Score
        score["scoreHigh"]      = scoreHigh
        score["scoreLow"]       = scoreLow
        score["missedHigh"]     = scoreMissedHigh
        score["missedLow"]      = scoreMissedLow
        score["scoreBatters"]   = scoredBatters
        score["scoreCourtyard"] = scoredMiddle
        score["scoreDefenses"]  = scoredDefenses
        
        // Defenses
        defense["defense1"] = defense1.propertyListRepresentation()
        defense["defense2"] = defense2.propertyListRepresentation()
        defense["defense3"] = defense3.propertyListRepresentation()
        defense["defense4"] = defense4.propertyListRepresentation()
        defense["defense5"] = defense5.propertyListRepresentation()
        
        // Final Info
        final["score"]    = finalScore
        final["rPoints"]  = finalRankingPoints
        final["result"]   = finalResult.rawValue
        final["pScore"]   = finalPenaltyScore
        final["fouls"]    = finalFouls
        final["tFouls"]   = finalTechFouls
        final["yCards"]   = finalYellowCards
        final["rCards"]   = finalRedCards
        final["robot"]    = finalRobot.rawValue
        final["config"]   = finalConfiguration.rawValue
        final["comments"] = finalComments
        
        // All Data
        data["team"]    = team
        data["auto"]    = auto
        data["score"]   = score
        data["defense"] = defense
        data["final"]   = final
        
        return data;
    }
    
    static func writeMatchCSVHeader() -> String {
        var matchHeader = ""
        
        matchHeader += "Match Number, Team Number, Alliance, "
        
        matchHeader += "Auto Scored High, Auto Scored Low, Auto Missed High, Auto Missed Low, "
        matchHeader += "Auto Scored Batters, Auto Scored Courtyard, Auto Scored Defenses, "
        
        matchHeader += "Tele Scored High, Tele Scored Low, Tele Missed High, Tele Missed Low, "
        matchHeader += "Tele Scored Batters, Tele Scored Courtyard, Tele Scored Defenses, "
        
        matchHeader += "Defense 1 Type, "
        matchHeader += "D1 Auto Crossed, D1 Auto Attempted Cross, D1 Auto Crossed With Ball, D1 Auto Assisted Cross, "
        matchHeader += "D1 Tele Crossed, D1 Tele Attempted Cross, D1 Tele Crossed With Ball, D1 Tele Assisted Cross, "
        
        matchHeader += "Defense 2 Type, "
        matchHeader += "D2 Auto Crossed, D2 Auto Attempted Cross, D2 Auto Crossed With Ball, D2 Auto Assisted Cross, "
        matchHeader += "D2 Tele Crossed, D2 Tele Attempted Cross, D2 Tele Crossed With Ball, D2 Tele Assisted Cross, "
        
        matchHeader += "Defense 3 Type, "
        matchHeader += "D3 Auto Crossed, D3 Auto Attempted Cross, D3 Auto Crossed With Ball, D3 Auto Assisted Cross, "
        matchHeader += "D3 Tele Crossed, D3 Tele Attempted Cross, D3 Tele Crossed With Ball, D3 Tele Assisted Cross, "
        
        matchHeader += "Defense 4 Type, "
        matchHeader += "D4 Auto Crossed, D4 Auto Attempted Cross, D4 Auto Crossed With Ball, D4 Auto Assisted Cross, "
        matchHeader += "D4 Tele Crossed, D4 Tele Attempted Cross, D4 Tele Crossed With Ball, D4 Tele Assisted Cross, "
        
        matchHeader += "Defense 5 Type, "
        matchHeader += "D5 Auto Crossed, D5 Auto Attempted Cross, D5 Auto Crossed With Ball, D5 Auto Assisted Cross, "
        matchHeader += "D5 Tele Crossed, D5 Tele Attempted Cross, D5 Tele Crossed With Ball, D5 Tele Assisted Cross, "
        
        matchHeader += "Final Score, Final Ranking Points, Final Penalty Score, Final Result, Fouls, Tech Fouls, Yellow Cards, Red Cards, Robot, Config, Comments \r\n"
        
        return matchHeader
    }
    
    func writeMatchCSV() -> String {
        var matchData = ""
        let match = JSON(messageDictionary())
        
        // This will be done in a loop...eventually
        
        matchData += "\(match["team", "matchNumber"].intValue), "
        matchData += "\(match["team", "teamNumber"].intValue), "
        matchData += "\(match["team", "alliance"].stringValue), "
        
        matchData += "\(match["auto", "scoreHigh"].intValue), "
        matchData += "\(match["auto", "scoreLow"].intValue), "
        matchData += "\(match["auto", "missedHigh"].intValue), "
        matchData += "\(match["auto", "missedLow"].intValue), "
        matchData += "\(match["auto", "scoredBatters"].intValue), "
        matchData += "\(match["auto", "scoredCourtyard"].intValue), "
        matchData += "\(match["auto", "scoredDefenses"].intValue), "
        
        matchData += "\(match["score", "scoreHigh"].intValue), "
        matchData += "\(match["score", "scoreLow"].intValue), "
        matchData += "\(match["score", "missedHigh"].intValue), "
        matchData += "\(match["score", "missedLow"].intValue), "
        matchData += "\(match["score", "scoredBatters"].intValue), "
        matchData += "\(match["score", "scoredCourtyard"].intValue), "
        matchData += "\(match["score", "scoredDefenses"].intValue), "
        
        matchData += "\(match["defense", "defense1", "type"].intValue), "
        matchData += "\(match["defense", "defense1", "atcross"].intValue), "
        matchData += "\(match["defense", "defense1", "afcross"].intValue), "
        matchData += "\(match["defense", "defense1", "abcross"].intValue), "
        matchData += "\(match["defense", "defense1", "aacross"].intValue), "
        matchData += "\(match["defense", "defense1", "cross"].intValue), "
        matchData += "\(match["defense", "defense1", "fcross"].intValue), "
        matchData += "\(match["defense", "defense1", "bcross"].intValue), "
        matchData += "\(match["defense", "defense1", "across"].intValue), "
        
        matchData += "\(match["defense", "defense2", "type"].intValue), "
        matchData += "\(match["defense", "defense2", "atcross"].intValue), "
        matchData += "\(match["defense", "defense2", "afcross"].intValue), "
        matchData += "\(match["defense", "defense2", "abcross"].intValue), "
        matchData += "\(match["defense", "defense2", "aacross"].intValue), "
        matchData += "\(match["defense", "defense2", "cross"].intValue), "
        matchData += "\(match["defense", "defense2", "fcross"].intValue), "
        matchData += "\(match["defense", "defense2", "bcross"].intValue), "
        matchData += "\(match["defense", "defense2", "across"].intValue), "
        
        matchData += "\(match["defense", "defense3", "type"].intValue), "
        matchData += "\(match["defense", "defense3", "atcross"].intValue), "
        matchData += "\(match["defense", "defense3", "afcross"].intValue), "
        matchData += "\(match["defense", "defense3", "abcross"].intValue), "
        matchData += "\(match["defense", "defense3", "aacross"].intValue), "
        matchData += "\(match["defense", "defense3", "cross"].intValue), "
        matchData += "\(match["defense", "defense3", "fcross"].intValue), "
        matchData += "\(match["defense", "defense3", "bcross"].intValue), "
        matchData += "\(match["defense", "defense3", "across"].intValue), "
        
        matchData += "\(match["defense", "defense4", "type"].intValue), "
        matchData += "\(match["defense", "defense4", "atcross"].intValue), "
        matchData += "\(match["defense", "defense4", "afcross"].intValue), "
        matchData += "\(match["defense", "defense4", "abcross"].intValue), "
        matchData += "\(match["defense", "defense4", "aacross"].intValue), "
        matchData += "\(match["defense", "defense4", "cross"].intValue), "
        matchData += "\(match["defense", "defense4", "fcross"].intValue), "
        matchData += "\(match["defense", "defense4", "bcross"].intValue), "
        matchData += "\(match["defense", "defense4", "across"].intValue), "
        
        matchData += "\(match["defense", "defense5", "type"].intValue), "
        matchData += "\(match["defense", "defense5", "atcross"].intValue), "
        matchData += "\(match["defense", "defense5", "afcross"].intValue), "
        matchData += "\(match["defense", "defense5", "abcross"].intValue), "
        matchData += "\(match["defense", "defense5", "aacross"].intValue), "
        matchData += "\(match["defense", "defense5", "cross"].intValue), "
        matchData += "\(match["defense", "defense5", "fcross"].intValue), "
        matchData += "\(match["defense", "defense5", "bcross"].intValue), "
        matchData += "\(match["defense", "defense5", "across"].intValue), "
        
        matchData += "\(match["final", "score"].intValue), "
        matchData += "\(match["final", "rPoints"].intValue), "
        matchData += "\(match["final", "pScore"].intValue), "
        matchData += "\(match["final", "result"].intValue), "
        matchData += "\(match["final", "fouls"].intValue), "
        matchData += "\(match["final", "tFouls"].intValue), "
        matchData += "\(match["final", "yCards"].intValue), "
        matchData += "\(match["final", "rCards"].intValue), "
        matchData += "\(match["final", "robot"].intValue), "
        matchData += "\(match["final", "config"].intValue), "
        matchData += "\(match["final", "comments"].stringValue) "

        return matchData
    }
}
