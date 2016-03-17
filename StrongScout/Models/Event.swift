//
//  Event.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 3/17/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

enum EventType: Int {
    case None = 0, Regional, DistrictEvent, DistrictChampionship, ChampionshipSubdivision, ChampionshipDivision, Championship, OffSeason
}

class Event: NSObject, NSCoding {
    
    var city:String         = ""
    var code:String         = ""
    var country:String      = ""
    var dateStart:String    = ""
    var dateEnd:String      = ""
    var districtCode:String = ""
    var divisionCode:String = ""
    var name:String         = ""
    var stateProv:String    = ""
    var timezone:String     = ""
    var type:EventType      = .None
    var venue:String        = ""

    init(json:[String:AnyObject]) {
        super.init()
        self.city         = json["city"]         as! String
        self.code         = json["code"]         as! String
        self.country      = json["country"]      as! String
        self.dateStart    = json["dateStart"]    as! String
        self.dateEnd      = json["dateEnd"]      as! String
        self.districtCode = json["districtCode"] as! String
        self.divisionCode = json["divisionCode"] as! String
        self.name         = json["name"]         as! String
        self.stateProv    = json["stateprov"]    as! String
        self.timezone     = json["timezone"]     as! String
        self.type         = EventType(rawValue: json["type"] as! Int)!
        self.venue        = json["venue"]        as! String
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.city         = aDecoder.decodeObjectForKey("city")         as! String
        self.code         = aDecoder.decodeObjectForKey("code")         as! String
        self.country      = aDecoder.decodeObjectForKey("country")      as! String
        self.dateStart    = aDecoder.decodeObjectForKey("dateStart")    as! String
        self.dateEnd      = aDecoder.decodeObjectForKey("dateEnd")      as! String
        self.districtCode = aDecoder.decodeObjectForKey("districtCode") as! String
        self.divisionCode = aDecoder.decodeObjectForKey("divisionCode") as! String
        self.name         = aDecoder.decodeObjectForKey("name")         as! String
        self.stateProv    = aDecoder.decodeObjectForKey("stateProv")    as! String
        self.timezone     = aDecoder.decodeObjectForKey("timezone")     as! String
        self.type         = EventType(rawValue: aDecoder.decodeIntegerForKey("type"))!
        self.venue        = aDecoder.decodeObjectForKey("venue")        as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(city,           forKey: "city")
        aCoder.encodeObject(code,           forKey: "code")
        aCoder.encodeObject(country,        forKey: "country")
        aCoder.encodeObject(dateStart,      forKey: "dateStart")
        aCoder.encodeObject(dateEnd,        forKey: "dateEnd")
        aCoder.encodeObject(districtCode,   forKey: "districtCode")
        aCoder.encodeObject(divisionCode,   forKey: "divisionCode")
        aCoder.encodeObject(name,           forKey: "name")
        aCoder.encodeObject(stateProv,      forKey: "stateProv")
        aCoder.encodeObject(timezone,       forKey: "timeZone")
        aCoder.encodeInteger(type.rawValue, forKey: "type")
        aCoder.encodeObject(venue,          forKey: "venue")
    }
    
}
