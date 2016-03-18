//
//  Event.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 3/17/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import SwiftyJSON

class Event: NSObject, NSCoding {
    
    var city:String         = ""
    var code:String         = ""
    var country:String      = ""
    var dateStart:NSDate?   = nil
    var dateEnd:NSDate?     = nil
    var districtCode:String = ""
    var divisionCode:String = ""
    var name:String         = ""
    var stateProv:String    = ""
    var timezone:String     = ""
    var type:String         = ""
    var venue:String        = ""

    init(json:JSON) {
        super.init()
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let abbr = timeZoneToABBR(json["timezone"].stringValue)
        if abbr == "AEST" { // Fix for Australia Time
            formatter.timeZone = NSTimeZone(name: "Australia/Sydney")
        } else {
            formatter.timeZone = NSTimeZone(abbreviation: abbr)
        }
        
        self.city         = json["city"].stringValue
        self.code         = json["code"].stringValue
        self.country      = json["country"].stringValue
        self.dateStart    = formatter.dateFromString(json["dateStart"].stringValue)
        self.dateEnd      = formatter.dateFromString(json["dateEnd"].stringValue)
        self.districtCode = json["districtCode"].stringValue
        self.divisionCode = json["divisionCode"].stringValue
        self.name         = json["name"].stringValue
        self.stateProv    = json["stateprov"].stringValue
        self.timezone     = json["timezone"].stringValue
        self.type         = json["type"].stringValue
        self.venue        = json["venue"].stringValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.city         = aDecoder.decodeObjectForKey("city")         as! String
        self.code         = aDecoder.decodeObjectForKey("code")         as! String
        self.country      = aDecoder.decodeObjectForKey("country")      as! String
        self.dateStart    = aDecoder.decodeObjectForKey("dateStart")    as? NSDate
        self.dateEnd      = aDecoder.decodeObjectForKey("dateEnd")      as? NSDate
        self.districtCode = aDecoder.decodeObjectForKey("districtCode") as! String
        self.divisionCode = aDecoder.decodeObjectForKey("divisionCode") as! String
        self.name         = aDecoder.decodeObjectForKey("name")         as! String
        self.stateProv    = aDecoder.decodeObjectForKey("stateProv")    as! String
        self.timezone     = aDecoder.decodeObjectForKey("timeZone")     as! String
        self.type         = aDecoder.decodeObjectForKey("type")         as! String
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
        aCoder.encodeObject(type,           forKey: "type")
        aCoder.encodeObject(venue,          forKey: "venue")
    }
    
    func timeZoneToABBR(tz:String) -> String {
        /*
        ["Israel Standard Time", "Eastern Standard Time", "Central Standard Time", "E. Australia Standard Time", "Mountain Standard Time", "Pacific Standard Time", "Hawaiian Standard Time"]
        
        ["IST", "EST", "CST", "AEST", "MST", "PST", "HST"]
        // Australia time currently does not work -- SEE FIX ABOVE
        */
        return tz == "Israel Standard Time"       ? "IST"  :
               tz == "Eastern Standard Time"      ? "EST"  :
               tz == "Central Standard Time"      ? "CST"  :
               tz == "E. Australia Standard Time" ? "AEST"  :
               tz == "Mountain Standard Time"     ? "MST"  :
               tz == "Pacific Standard Time"      ? "PST"  :
               tz == "Hawaiian Standard Time"     ? "HST" : "UTC"
    }
    
}
