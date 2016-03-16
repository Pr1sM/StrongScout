# StrongScout Data Transfer Description

## Overview

The StrongScout data transfer JSON representation is an array of anonymous classes, called matches.  Unless otherwise noted, every variable represents an integer.  Each match has 5 different categories in no particular order:

+ team
+ auto
+ score
+ defense
+ final

## Team

The team class contains general information about the match and team.  

+ matchNumber - the match number as it appears on the schedule of the event
+ teamNumber - the team that was scouted this match
+ alliance - the alliance this team was a part of.  (will be a string equal to "Red" or "Blue")

## Auto

The auto class contains scoring information during the autonomous period.

+ scoreBatters - the number of goals scored from the batters
+ scoreCourtyard - the number of goals scored from the courtyard area
+ scoreDefenses - the number of goals scored from the area near the defenses
+ scoreLow - the number of goals scored in the low goal
+ missedLow - the number of goals missed aimed at the low goal
+ scoreHigh - the number of goals scored in the high goal
+ missedHigh - the number of goals missed aimed at the high goal

## Score

The score class contains scoring information during the teleop period.

+ scoreBatters - the number of goals scored from the batters
+ scoreCourtyard - the number of goals scored from the courtyard area
+ scoreDefenses - the number of goals scored from the area near the defenses
+ scoreLow - the number of goals scored in the low goal
+ missedLow - the number of goals missed aimed at the low goal
+ scoreHigh - the number of goals scored in the high goal
+ missedHigh - the number of goals missed aimed at the high goal

## Defense

The defense class contains 5 classes that contain the same information, one for each defense.  They are labeled as follows (order may vary):

+ defense1
+ defense2
+ defense3
+ defense4
+ defense5

#### Defense Data

The defense data contains all aggregated information of the defense.

+ cross - the number of successful crosses (teleop).
+ bcross - the number of successful crosses with possession of a ball (tele lop).
+ fcross - the number of failed attempts to cross a defense (teleop).
+ across - the number of times the robot assisted a different robot in crossing a defense (teleop).
+ atcross - the number of successful crosses (auto).
+ abcross - the number of successful crosses with possession of a ball (auto).
+ afcross - the number of failed attempts to cross a defense (auto).
+ aacross - the number of times the robot assisted a different robot in crossing a defense (auto).

## Final

The final class contains information about the results of a match.

+ score - the final score of the match.
+ rPoints - the number of ranking points earned during the match.
+ result - the final result of the match.
    + 0 - no result was given.
    + 1 - the robot's alliance lost the match.
    + 2 - the robot's alliance won the match.
    + 3 - the robot's alliance tied the match.
    + 4 - the robot was a No Show.
+ pScore - the number of penalty points received from the opposite alliance.
+ fouls - the number of fouls committed by the robot.
+ tFouls - the number of technical fouls committed by the robot.
+ yCards - the number of yellow cards given to the robot.
+ rCards - the number of red cards given to the robot.
+ robot - the state of the robot during the match.
    + 0 - the robot performed normally.
    + 1 - the robot had at least once instance of stalling.
    + 2 - the robot had at least once instance of tipping over.
    + 3 - the robot had at least once instance of stalling AND at least once instance of tipping over.
+ config - the final configuration of the robot (if they attempted the endgame).
    + 0 - the robot neither completed the challenge, nor successfully hung from the tower.
    + 1 - the robot successfully hung from the tower.
    + 2 - the robot completed the challenge.
+ comments - a String containing notes the user wrote about the robot's overall performance.

## Example

Here is an example of the formatted transfer message.  After the contents of the message are sent an 'End-of-Message' flag will be sent as well.  This message is a string that contains "<EOM>".  

    [
    {
    "team" : {
    "matchNumber" : 21,
    "teamNumber" : 123,
    "alliance" : "Blue"
    },
    "defense" : {
    "defense3" : {
    "across" : 0,
    "aacross" : 0,
    "abcross" : 0,
    "bcross" : 0,
    "fcross" : 1,
    "atcross" : 0,
    "afcross" : 0,
    "cross" : 0,
    "loc" : 3,
    "type" : 6
    },
    "defense4" : {
    "across" : 0,
    "aacross" : 0,
    "abcross" : 0,
    "bcross" : 1,
    "fcross" : 0,
    "atcross" : 0,
    "afcross" : 0,
    "cross" : 0,
    "loc" : 4,
    "type" : 4
    },
    "defense2" : {
    "across" : 0,
    "aacross" : 0,
    "abcross" : 0,
    "bcross" : 0,
    "fcross" : 0,
    "atcross" : 0,
    "afcross" : 0,
    "cross" : 0,
    "loc" : 2,
    "type" : 8
    },
    "defense1" : {
    "across" : 0,
    "aacross" : 0,
    "abcross" : 0,
    "bcross" : 0,
    "fcross" : 0,
    "atcross" : 0,
    "afcross" : 0,
    "cross" : 0,
    "loc" : 1,
    "type" : 9
    },
    "defense5" : {
    "across" : 0,
    "aacross" : 0,
    "abcross" : 0,
    "bcross" : 0,
    "fcross" : 0,
    "atcross" : 2,
    "afcross" : 0,
    "cross" : 0,
    "loc" : 5,
    "type" : 2
    }
    },
    "final" : {
    "yCards" : 0,
    "robot" : 3,
    "fouls" : 1,
    "result" : 2,
    "score" : 130,
    "config" : 1,
    "rCards" : 0,
    "comments" : "Good robot, a little unstable though...",
    "rPoints" : 2,
    "pScore" : 24,
    "tFouls" : 0
    },
    "auto" : {
    "scoreCourtyard" : 0,
    "scoreBatters" : 0,
    "missedLow" : 0,
    "scoreLow" : 0,
    "scoreDefenses" : 0,
    "missedHigh" : 0,
    "scoreHigh" : 0
    },
    "score" : {
    "scoreCourtyard" : 0,
    "scoreBatters" : 1,
    "missedLow" : 1,
    "scoreLow" : 0,
    "scoreDefenses" : 0,
    "missedHigh" : 1,
    "scoreHigh" : 2
    }
    },
    {
    "team" : {
    "matchNumber" : 2,
    "teamNumber" : 243,
    "alliance" : "Red"
    },
    "defense" : {
    "defense3" : {
    "across" : 0,
    "aacross" : 0,
    "abcross" : 0,
    "bcross" : 0,
    "fcross" : 0,
    "atcross" : 0,
    "afcross" : 0,
    "cross" : 1,
    "loc" : 3,
    "type" : 2
    },
    "defense4" : {
    "across" : 0,
    "aacross" : 0,
    "abcross" : 0,
    "bcross" : 1,
    "fcross" : 0,
    "atcross" : 0,
    "afcross" : 0,
    "cross" : 0,
    "loc" : 4,
    "type" : 3
    },
    "defense2" : {
    "across" : 0,
    "aacross" : 0,
    "abcross" : 0,
    "bcross" : 0,
    "fcross" : 0,
    "atcross" : 0,
    "afcross" : 0,
    "cross" : 0,
    "loc" : 2,
    "type" : 5
    },
    "defense1" : {
    "across" : 0,
    "aacross" : 0,
    "abcross" : 0,
    "bcross" : 0,
    "fcross" : 0,
    "atcross" : 1,
    "afcross" : 0,
    "cross" : 0,
    "loc" : 1,
    "type" : 9
    },
    "defense5" : {
    "across" : 0,
    "aacross" : 0,
    "abcross" : 0,
    "bcross" : 0,
    "fcross" : 0,
    "atcross" : 0,
    "afcross" : 0,
    "cross" : 1,
    "loc" : 5,
    "type" : 8
    }
    },
    "final" : {
    "yCards" : 1,
    "robot" : 1,
    "fouls" : 1,
    "result" : 3,
    "score" : 43,
    "config" : 1,
    "rCards" : 0,
    "comments" : "Okay robot,  no defensive abilities.",
    "rPoints" : 2,
    "pScore" : 34,
    "tFouls" : 0
    },
    "auto" : {
    "scoreCourtyard" : 0,
    "scoreBatters" : 2,
    "missedLow" : 0,
    "scoreLow" : 0,
    "scoreDefenses" : 2,
    "missedHigh" : 2,
    "scoreHigh" : 2
    },
    "score" : {
    "scoreCourtyard" : 0,
    "scoreBatters" : 2,
    "missedLow" : 2,
    "scoreLow" : 0,
    "scoreDefenses" : 1,
    "missedHigh" : 2,
    "scoreHigh" : 1
    }
    }
    ]
    <EOM>