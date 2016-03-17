//
//  ToolsViewController.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 3/7/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import CoreBluetooth

class ToolsViewController: UIViewController {
    
    @IBOutlet weak var fieldLayout:UIImageView!
    
    private var peripheralManager:CBPeripheralManager?
    private var infoCharacteristic:CBMutableCharacteristic?
    private var newDataCharacteristic:CBMutableCharacteristic?
    private var allDataCharacteristic:CBMutableCharacteristic?
    
    private var dataToSend:NSData?
    private var sendDataIndex:Int = 0
    private var sendingEOM = false
    private var sendingCharacteristic:CBMutableCharacteristic!
    
    @IBOutlet var adSwitch:UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        fieldLayout.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "fieldLayoutTap:")
        fieldLayout.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fieldLayout.image = MatchStore.sharedStore.fieldLayout.getImage()
        
        adSwitch.on = false
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        adSwitch.on = false
        peripheralManager?.stopAdvertising()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fieldLayoutTap(sender:UITapGestureRecognizer) {
        MatchStore.sharedStore.fieldLayout.reverse()
        NSUserDefaults.standardUserDefaults().setInteger(MatchStore.sharedStore.fieldLayout.rawValue, forKey: "StrongScout.fieldLayout")
        let image = MatchStore.sharedStore.fieldLayout.getImage()
        UIView.transitionWithView(fieldLayout, duration: 0.2, options: .TransitionCrossDissolve, animations: {[weak self] in
            self?.fieldLayout.image = image
        }, completion: nil)
    }
    
    @IBAction func startAdvertising(sender:UISwitch) {
        if(peripheralManager?.state != CBPeripheralManagerState.PoweredOn && adSwitch.on) {
            adSwitch.on = false
            let alertController = UIAlertController(title: "Bluetooth Advertising", message: "Before you can advertise data via bluetooth, you must enable it.  Go to the settings and turn Bluetooth on to start sending data", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        if(adSwitch.on) {
            print("Advertising")
            peripheralManager?.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [lastUpdateServiceUUID, dataServiceUUID]])
        } else {
            peripheralManager?.stopAdvertising()
        }
    }
    
    @IBAction func getEventList(sender:UIButton) {
        SessionStore.sharedStore.getEventList(self)
    }
    
    func sendData() {
        if sendingEOM {
            let didSend = peripheralManager?.updateValue("<EOM>".dataUsingEncoding(NSUTF8StringEncoding)!, forCharacteristic: sendingCharacteristic!, onSubscribedCentrals: nil)
            if didSend == true {
                sendingEOM = false
                print("Sent: EOM")
            }
            return
        }
        
        if sendDataIndex >= dataToSend?.length {
            return
        }
        
        var didSend = true
        while didSend {
            var amountToSend = dataToSend!.length - sendDataIndex
            if amountToSend > NOTIFY_MTU {
                amountToSend = NOTIFY_MTU
            }
            let chunk = NSData(bytes: dataToSend!.bytes + sendDataIndex, length: amountToSend)
            
            didSend = (peripheralManager?.updateValue(chunk, forCharacteristic: sendingCharacteristic, onSubscribedCentrals: nil))!
            
            if !didSend { return }
            
            sendDataIndex += amountToSend
            
            if sendDataIndex >= dataToSend?.length {
                sendingEOM = true
                let eomSent = peripheralManager!.updateValue("<EOM>".dataUsingEncoding(NSUTF8StringEncoding)!, forCharacteristic: sendingCharacteristic, onSubscribedCentrals: nil)
                
                if eomSent {
                    sendingEOM = false
                    print("Send complete")
                }
                
                return
            }
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension ToolsViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if(peripheral.state != .PoweredOn) {
            print("Peripheral manager updated state: \(peripheral.state.rawValue), \(CBPeripheralManagerState.PoweredOn.rawValue)")
            return
        }
        
        print("Peripheral Manager Powered On")
        
        infoCharacteristic = CBMutableCharacteristic(type: lastUpdateCharacteristicUUID,
                                               properties: .Read,
                                                    value: nil,
                                              permissions: .Readable)
        newDataCharacteristic = CBMutableCharacteristic(type: newMatchDataCharacteristicUUID,
                                                  properties: .Notify,
                                                       value: nil,
                                                 permissions: .Readable)
        allDataCharacteristic = CBMutableCharacteristic(type: allMatchDataCharacteristicUUID,
                                                  properties: .Notify,
                                                       value: nil,
                                                 permissions: .Readable)
        
        let infoService = CBMutableService(type: lastUpdateServiceUUID, primary: false)
        infoService.characteristics = [infoCharacteristic!]
        
        let dataService = CBMutableService(type: dataServiceUUID, primary: true)
        dataService.characteristics = [allDataCharacteristic!]
        
        peripheralManager!.addService(infoService)
        peripheralManager!.addService(dataService)
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        print("Central: \(central.identifier) has subscibed to characteristic: \(characteristic.UUID)")
        
        sendDataIndex = 0
        dataToSend = MatchStore.sharedStore.dataTransferMatchesAll(characteristic.UUID == allDataCharacteristic?.UUID) ?? "An Error Occured".dataUsingEncoding(NSUTF8StringEncoding)
        sendingCharacteristic = characteristic.UUID == allDataCharacteristic?.UUID ? allDataCharacteristic! : newDataCharacteristic!
        
        sendData();
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        print("Central: \(central.identifier) has unsubscibed to characteristic: \(characteristic.UUID)")
    }
    
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager) {
        sendData()
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if let error = error {
            print(error)
        }
    }
}

extension ToolsViewController: SessionStoreDelegate {
    func sessionStore(progress: Double, forDownloadTask task: NSURLSessionDownloadTask) {
        print("Progress for event list: \(progress)")
    }
    
    func sessionStoreCompleted(DownloadTask task: NSURLSessionDownloadTask, toURL location: NSURL, withDictionary result: [String : AnyObject]?) {
        print("Download Completed")
        //print("\(result)")
        
        let events = result!["Events"] as! [AnyObject]
        
        print(events)
    }
}
