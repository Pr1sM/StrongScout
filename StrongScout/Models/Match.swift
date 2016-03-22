//
//  Match.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 2/6/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias ScoreStat = (scored:Int, missed:Int)

class Match : NSObject, NSCoding {
    
    // Team Info
    
    var teamNumber:Int = -1
    var matchNumber:Int = -1
    var alliance:AllianceType = .unknown
    var isCompleted:Int = 32
    
    // Auto Scoring Info
    
    var autoHigh:ScoreStat      = (0, 0)
    var autoLow:ScoreStat       = (0, 0)
    var autoBatters:ScoreStat   = (0, 0)
    var autoCourtyard:ScoreStat = (0, 0)
    var autoDefenses:ScoreStat  = (0, 0)
    
    // Scoring Info
    
//    var scoreHigh:Int = 0
//    var scoreLow:Int = 0
//    var scoreMissedHigh:Int = 0
//    var scoreMissedLow:Int = 0
//    var scoredBatters:Int = 0
//    var scoredMiddle:Int = 0
//    var scoredDefenses:Int = 0
    
    var teleHigh:ScoreStat      = (0, 0)
    var teleLow:ScoreStat       = (0, 0)
    var teleBatters:ScoreStat   = (0, 0)
    var teleCourtyard:ScoreStat = (0, 0)
    var teleDefenses:ScoreStat  = (0, 0)
    
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
        self.teleHigh      = (0, 0)
        self.teleLow       = (0, 0)
        self.teleBatters   = (0, 0)
        self.teleCourtyard = (0, 0)
        self.teleDefenses  = (0, 0)
        
        self.autoHigh      = (0, 0)
        self.autoLow       = (0, 0)
        self.autoBatters   = (0, 0)
        self.autoCourtyard = (0, 0)
        self.autoDefenses  = (0, 0)
        
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
                        self.teleHigh.scored       += (score.type == .High)          ? 1 : 0
                        self.teleHigh.missed       += (score.type == .MissedHigh)    ? 1 : 0
                        self.teleLow.scored        += (score.type == .Low)           ? 1 : 0
                        self.teleLow.missed        += (score.type == .MissedLow)     ? 1 : 0
                        self.teleBatters.scored   += (score.location == .Batter && !score.type.missed)    ? 1 : 0
                        self.teleBatters.missed   += (score.location == .Batter && score.type.missed)     ? 1 : 0
                        self.teleCourtyard.scored += (score.location == .Courtyard && !score.type.missed) ? 1 : 0
                        self.teleCourtyard.missed += (score.location == .Courtyard && score.type.missed)  ? 1 : 0
                        self.teleDefenses.scored  += (score.location == .Defenses && !score.type.missed)  ? 1 : 0
                        self.teleDefenses.missed  += (score.location == .Defenses && score.type.missed)   ? 1 : 0
                    } else {
                        self.autoHigh.scored      += (score.type == .High)          ? 1 : 0
                        self.autoHigh.missed      += (score.type == .MissedHigh)    ? 1 : 0
                        self.autoLow.scored       += (score.type == .Low)           ? 1 : 0
                        self.autoLow.missed       += (score.type == .MissedLow)     ? 1 : 0
                        self.autoBatters.scored   += (score.location == .Batter && !score.type.missed)    ? 1 : 0
                        self.autoBatters.missed   += (score.location == .Batter && score.type.missed)     ? 1 : 0
                        self.autoCourtyard.scored += (score.location == .Courtyard && !score.type.missed) ? 1 : 0
                        self.autoCourtyard.missed += (score.location == .Courtyard && score.type.missed)  ? 1 : 0
                        self.autoDefenses.scored  += (score.location == .Defenses && !score.type.missed)  ? 1 : 0
                        self.autoDefenses.missed  += (score.location == .Defenses && score.type.missed)   ? 1 : 0
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
        aCoder.encodeInteger(autoHigh.scored,      forKey: "autoScoreHigh")
        aCoder.encodeInteger(autoHigh.missed,      forKey: "autoMissedHigh")
        aCoder.encodeInteger(autoLow.scored,       forKey: "autoScoreLow")
        aCoder.encodeInteger(autoLow.missed,       forKey: "autoMissedLow")
        aCoder.encodeInteger(autoBatters.scored,   forKey: "autoScoredBatters")
        aCoder.encodeInteger(autoBatters.missed,   forKey: "autoMissedBatters")
        aCoder.encodeInteger(autoCourtyard.scored, forKey: "autoScoredCourtyard")
        aCoder.encodeInteger(autoCourtyard.missed, forKey: "autoMissedCourtyard")
        aCoder.encodeInteger(autoDefenses.scored,  forKey: "autoScoredDefenses")
        aCoder.encodeInteger(autoDefenses.missed,  forKey: "autoMissedDefenses")
        
        // Score Information
        aCoder.encodeInteger(teleHigh.scored,      forKey: "teleScoreHigh")
        aCoder.encodeInteger(teleHigh.missed,      forKey: "teleMissedHigh")
        aCoder.encodeInteger(teleLow.scored,       forKey: "teleScoreLow")
        aCoder.encodeInteger(teleLow.missed,       forKey: "teleMissedLow")
        aCoder.encodeInteger(teleBatters.scored,   forKey: "teleScoredBatters")
        aCoder.encodeInteger(teleBatters.missed,   forKey: "teleMissedBatters")
        aCoder.encodeInteger(teleCourtyard.scored, forKey: "teleScoredCourtyard")
        aCoder.encodeInteger(teleCourtyard.missed, forKey: "teleMissedCourtyard")
        aCoder.encodeInteger(teleDefenses.scored,  forKey: "teleScoredDefenses")
        aCoder.encodeInteger(teleDefenses.missed,  forKey: "teleMissedDefenses")
        
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
        var highScore       = aDecoder.decodeIntegerForKey("autoScoreHigh")
        var highMiss        = aDecoder.decodeIntegerForKey("autoMissedHigh")
        var lowScore        = aDecoder.decodeIntegerForKey("autoScoreLow")
        var lowMiss         = aDecoder.decodeIntegerForKey("autoMissedLow")
        var battersScore    = aDecoder.decodeIntegerForKey("autoScoredBatters")
        var battersMissed   = aDecoder.decodeIntegerForKey("autoScoredBatters")
        var courtyardScore  = aDecoder.decodeIntegerForKey("autoScoredCourtyard")
        var courtyardMissed = aDecoder.decodeIntegerForKey("autoMissedCourtyard")
        var defensesScore   = aDecoder.decodeIntegerForKey("autoScoredDefenses")
        var defensesMissed  = aDecoder.decodeIntegerForKey("autoMissedDefenses")
        
        self.autoHigh       = (highScore, highMiss)
        self.autoLow        = (lowScore, lowMiss)
        self.autoBatters    = (battersScore, battersMissed)
        self.autoCourtyard  = (courtyardScore, courtyardMissed)
        self.autoDefenses   = (defensesScore, defensesMissed)
        
        // Score Information
        highScore       = aDecoder.decodeIntegerForKey("teleScoreHigh")
        highMiss        = aDecoder.decodeIntegerForKey("teleMissedHigh")
        lowScore        = aDecoder.decodeIntegerForKey("teleScoreLow")
        lowMiss         = aDecoder.decodeIntegerForKey("teleMissedLow")
        battersScore    = aDecoder.decodeIntegerForKey("teleScoredBatters")
        battersMissed   = aDecoder.decodeIntegerForKey("teleScoredBatters")
        courtyardScore  = aDecoder.decodeIntegerForKey("teleScoredCourtyard")
        courtyardMissed = aDecoder.decodeIntegerForKey("teleMissedCourtyard")
        defensesScore   = aDecoder.decodeIntegerForKey("teleScoredDefenses")
        defensesMissed  = aDecoder.decodeIntegerForKey("teleMissedDefenses")
        
        self.autoHigh       = (highScore, highMiss)
        self.autoLow        = (lowScore, lowMiss)
        self.autoBatters    = (battersScore, battersMissed)
        self.autoCourtyard  = (courtyardScore, courtyardMissed)
        self.autoDefenses   = (defensesScore, defensesMissed)
        
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
        var tele:[String:AnyObject]   = [String:AnyObject]()
        var defense:[String:AnyObject] = [String:AnyObject]()
        var final:[String:AnyObject]   = [String:AnyObject]()
        
        // Team Info
        team["teamNumber"]  = teamNumber
        team["matchNumber"] = matchNumber
        team["alliance"]    = alliance.toString()
        
        // Auto
        auto["scoreHigh"]       = autoHigh.scored
        auto["missedHigh"]      = autoHigh.missed
        auto["scoreLow"]        = autoLow.scored
        auto["missedLow"]       = autoLow.missed
        auto["scoreBatters"]    = autoBatters.scored
        auto["missedBatters"]   = autoBatters.missed
        auto["scoreCourtyard"]  = autoCourtyard.scored
        auto["missedCourtyard"] = autoCourtyard.missed
        auto["scoreDefenses"]   = autoDefenses.scored
        auto["missedDefenses"]  = autoDefenses.missed
        
        // Score
        tele["scoreHigh"]       = teleHigh.scored
        tele["missedHigh"]      = teleHigh.missed
        tele["scoreLow"]        = teleLow.scored
        tele["missedLow"]       = teleLow.missed
        tele["scoreBatters"]    = teleBatters.scored
        tele["missedBatters"]   = teleBatters.missed
        tele["scoreCourtyard"]  = teleCourtyard.scored
        tele["missedCourtyard"] = teleCourtyard.missed
        tele["scoreDefenses"]   = teleDefenses.scored
        tele["missedDefenses"]  = teleDefenses.missed

        
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
        data["tele"]    = tele
        data["defense"] = defense
        data["final"]   = final
        
        return data;
    }
    
    static func writeMatchCSVHeader() -> String {
        var matchHeader = ""
        
        matchHeader += "Match Number, Team Number, Alliance, "
        
        matchHeader += "Auto Scored High, Auto Missed High, Auto Scored Low, Auto Missed Low, "
        matchHeader += "Auto Scored Batters, Auto Missed Batters, Auto Scored Courtyard, Auto Missed Courtyard, Auto Scored Defenses, Auto Missed Defenses, "
        
        matchHeader += "Tele Scored High, Tele Missed High, Tele Scored Low, Tele Missed Low, "
        matchHeader += "Tele Scored Batters, Tele Missed Batters, Tele Scored Courtyard, Tele Missed Courtyard, Tele Scored Defenses, Tele Missed Defenses, "
        
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
        
        matchHeader += "Final Score, Final Ranking Points, Penalty Points Received, Final Result, Fouls, Tech Fouls, Yellow Cards, Red Cards, Robot, Config, Comments \r\n"
        
        return matchHeader
    }
    
    func writeMatchCSV() -> String {
        var matchData = ""
        let match = JSON(messageDictionary())
        
        matchData += "\(match["team", "matchNumber"].intValue),"
        matchData += "\(match["team", "teamNumber"].intValue),"
        matchData += "\(match["team", "alliance"].stringValue),"
        
        let typeKeys = ["auto", "tele"]
        let scoreKeys = ["scoreHigh", "missedHigh", "scoreLow", "missedLow", "scoreBatters", "missedBatters", "scoreCourtyard", "missedCourtyard", "scoreDefenses", "missedDefenses"]
        for i in 0..<typeKeys.count {
            for j in 0..<scoreKeys.count {
                matchData += "\(match[typeKeys[i], scoreKeys[j]].intValue),"
            }
        }
        
        let defenseNames = ["defense1", "defense2", "defense3", "defense4", "defense5"]
        let defenseVals = ["type", "atcross", "afcross", "abcross", "aacross", "cross", "fcross", "bcross", "across"]
        for i in 0..<defenseNames.count {
            for j in 0..<defenseVals.count {
                matchData += "\(match["defense", defenseNames[i], defenseVals[j]].intValue),"
            }
        }
        
        let finalKeys = ["score", "rPoints", "pScore", "result", "fouls", "tFouls", "yCards", "rCards", "robot", "config"]
        for i in 0..<finalKeys.count {
            matchData += "\(match["final", finalKeys[i]].intValue),"
        }
        matchData += "\(match["final", "comments"].stringValue)"

        return matchData
    }
}
