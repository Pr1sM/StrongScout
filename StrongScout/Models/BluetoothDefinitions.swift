//
//  BluetoothDefinitions.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 3/7/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import CoreBluetooth

let MATCH_DATA_SERVICE  = "29EE6C47-01F9-43C3-A1E6-CF2E54C50325"
let LAST_UPDATE_SERVICE = "614FA73D-E585-469D-B057-74831579D32E"

let ALL_MATCH_DATA_CHARACTERISTIC = "9171AAC7-A053-46E7-9F6E-91E379C57B67"
let LAST_UPDATE_CHARACTERISTIC    = "598E71F7-8726-4706-B374-67AAE781B660"
let NEW_MATCH_DATA_CHARACTERISTIC = "1D79DD8C-D493-4250-9DF3-0A041B0C969B"

let NOTIFY_MTU = 20

let dataServiceUUID       = CBUUID(string: MATCH_DATA_SERVICE)
let lastUpdateServiceUUID = CBUUID(string: LAST_UPDATE_SERVICE)

let allMatchDataCharacteristicUUID = CBUUID(string: ALL_MATCH_DATA_CHARACTERISTIC)
let lastUpdateCharacteristicUUID   = CBUUID(string: LAST_UPDATE_CHARACTERISTIC)
let newMatchDataCharacteristicUUID = CBUUID(string: NEW_MATCH_DATA_CHARACTERISTIC)