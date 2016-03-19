//
//  ScheduleItem.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 3/18/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Team: PropertyListReadable {
    var teamNumber:Int = 0
    var station:String = ""
    var surrogate:Bool = false
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let vals = propertyListRepresentation else {return nil}
        if let tNum = vals["tNum"] as? Int,
               station = vals["station"] as? String,
               surrogate = vals["surr"] as? Bool {
                self.teamNumber = tNum
                self.station = station
                self.surrogate = surrogate
        } else {
            return nil
        }
    }
    
    init(json:JSON) {
        self.teamNumber = json["teamNumber"].intValue
        self.station = json["station"].stringValue
        self.surrogate = json["surrogate"].boolValue
    }
    
    func propertyListRepresentation() -> NSDictionary {
        return ["tNum":teamNumber, "station":station, "surr":surrogate]
    }
}

class ScheduleItem: NSObject, NSCoding {
    var desc:String = ""
    var field:String = ""
    var tournamentLevel:String = ""
    var matchNumber:Int = 0
    var startTime:NSDate? = nil
    var teams:[Team] = [Team]()
    
    init(json:JSON) {
        super.init()
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        self.desc            = json["description"].stringValue
        self.field           = json["field"].stringValue
        self.tournamentLevel = json["tournamentLevel"].stringValue
        self.matchNumber     = json["matchNumber"].intValue
        self.startTime       = formatter.dateFromString(json["startTime"].stringValue)
        self.teams           = [Team]()
        for (_,subJSON):(String,JSON) in json["Teams"] {
            let team = Team(json: subJSON)
            teams.append(team)
        }
        
        teams.sortInPlace({$0.station.compare($1.station) == .OrderedAscending})
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self.desc            = aDecoder.decodeObjectForKey("desc") as! String
        self.field           = aDecoder.decodeObjectForKey("field") as! String
        self.tournamentLevel = aDecoder.decodeObjectForKey("tLevel") as! String
        self.matchNumber     = aDecoder.decodeIntegerForKey("mNum")
        self.startTime       = aDecoder.decodeObjectForKey("sTime") as? NSDate
        
        let teamsPList = aDecoder.decodeObjectForKey("teams") as? [NSDictionary]
        self.teams = []
        for pList in teamsPList! {
            guard let team = Team(propertyListRepresentation: pList) else { continue }
            self.teams.append(team)
        }
        teams.sortInPlace({$0.station.compare($1.station) == .OrderedAscending})
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(desc,            forKey: "desc")
        aCoder.encodeObject(field,           forKey: "field")
        aCoder.encodeObject(tournamentLevel, forKey: "tLevel")
        aCoder.encodeInteger(matchNumber,    forKey: "mNum")
        aCoder.encodeObject(startTime,       forKey: "sTime")
        
        var teamsPList:[NSDictionary] = []
        for t in teams {
            teamsPList.append(t.propertyListRepresentation())
        }
        aCoder.encodeObject(teamsPList, forKey: "teams")
    }
}
