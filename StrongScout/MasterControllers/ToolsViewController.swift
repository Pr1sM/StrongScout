//
//  ToolsViewController.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 3/7/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import CoreBluetooth
import MBProgressHUD

class ToolsViewController: UIViewController {
    
    @IBOutlet weak var fieldLayout:UIImageView!
    @IBOutlet weak var getScheduleButton:UIButton!
    @IBOutlet weak var buildListButton:UIButton!
    
    @IBOutlet var listSelectorButtons:[UIButton]!
    
    /**
     * represents the list the user wants to build
     * the first 2 bits correspond to the number of the list
     * bit 3 corresponds to the color (0 == red, 1 == blue)
     * ex: 5 = Blue 1 ~> (5 & 4) == 1, (5 & 3) == 1
     * ex: 3 = Red  3 ~> (5 & 4) == 0, (5 & 3) == 3
     */
    private var selectedList = 0
    
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(fieldLayoutTap(_:)))
        fieldLayout.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fieldLayout.image = MatchStore.sharedStore.fieldLayout.getImage()
        self.view.backgroundColor = themeOrange
        
        adSwitch.on = false
        
        getScheduleButton.enabled = EventStore.sharedStore.selectedEvent != nil
        buildListButton.enabled = false
        selectedList = 0
        for b in listSelectorButtons {
            b.selected = false
            b.enabled = ScheduleStore.sharedStore.currentSchedule != nil
        }
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
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        hud.labelText = "Loading..."
        hud.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelRequest(_:))))
        self.navigationItem.leftBarButtonItem?.enabled = false
        EventStore.sharedStore.getEventsList({(progress) in
            dispatch_async(dispatch_get_main_queue(), {
                let hud = MBProgressHUD(forView: self.navigationController?.view)
                hud.mode = .Determinate
                hud.progress = Float(progress)
            })
        }, completion: {(error) in
            dispatch_async(dispatch_get_main_queue(), {
                let hud = MBProgressHUD(forView: self.navigationController?.view)
                let image = UIImage(named: error == nil ? "check" : "close")
                let imageView = UIImageView(image: image)
                self.navigationItem.leftBarButtonItem?.enabled = true
                hud.customView = imageView
                hud.mode = .CustomView
                hud.labelText = error == nil ? "Completed" : "Error"
                hud.hide(true, afterDelay: 1)
            })
        })
    }
    
    func cancelRequest(sender:UITapGestureRecognizer) {
        EventStore.sharedStore.cancelRequest({
            dispatch_async(dispatch_get_main_queue(), {
                let hud = MBProgressHUD(forView: self.navigationController?.view)
                let imageView = UIImageView(image: UIImage(named: "close"))
                self.navigationItem.leftBarButtonItem?.enabled = true
                hud.customView = imageView
                hud.mode = .CustomView
                hud.labelText = "Canceled"
                hud.hide(true, afterDelay: 1)
            })
        })
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
    
    @IBAction func selectList(sender:UIButton) {
        selectedList = sender.selected ? 0 : sender.tag
        for b in listSelectorButtons {
            b.selected = b.tag == selectedList
        }
        buildListButton.enabled = selectedList > 0
    }
    
    @IBAction func getSchedule(sender:UIButton) {
        ScheduleStore.sharedStore.currentSchedule = EventStore.sharedStore.selectedEvent?.code
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        hud.mode = .Indeterminate
        hud.labelText = "Loading..."
        hud.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ToolsViewController.cancelScheduleRequest(_:))))
        self.navigationItem.leftBarButtonItem?.enabled = false
        self.getScheduleButton.enabled = false
        self.buildListButton.enabled = false
        ScheduleStore.sharedStore.getScheduleList({ (progress:Double) in
            dispatch_async(dispatch_get_main_queue(), {
                let hud = MBProgressHUD(forView: self.navigationController?.view)
                hud.mode = .Determinate
                hud.progress = Float(progress)
            })
            }, completion: { (error) in
                dispatch_async(dispatch_get_main_queue(), {
                    let hud = MBProgressHUD(forView: self.navigationController?.view)
                    let imageView = UIImageView(image: UIImage(named: error == nil ? "check" : "close"))
                    self.navigationItem.leftBarButtonItem?.enabled = true
                    self.getScheduleButton.enabled = true
                    for b in self.listSelectorButtons {
                        b.enabled = ScheduleStore.sharedStore.currentSchedule != nil
                    }
                    self.buildListButton.enabled = self.selectedList > 0
                    hud.customView = imageView
                    hud.mode = .CustomView
                    hud.labelText = error == nil ? "Completed" : "Error"
                    hud.hide(true, afterDelay: 1)
                })
        })
    }
    
    @IBAction func buildList(sender:UIButton) {
        if ScheduleStore.sharedStore.currentSchedule != EventStore.sharedStore.selectedEvent?.code {
            let scheduleAC = UIAlertController(title: "Current Schedule is different from Selected Event", message: "You have a schedule from a different event! Would you like to continue with the build, or get the new schedule", preferredStyle: .Alert)
            let buildAction = UIAlertAction(title: "Continue With Build", style: .Default, handler: { (action) in
                self.confirmBuildList()
            })
            scheduleAC.addAction(buildAction)
            
            let getScheduleAction = UIAlertAction(title: "Get New Schedule", style: .Default, handler: { (action) in
                self.getSchedule(self.getScheduleButton)
            })
            scheduleAC.addAction(getScheduleAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            scheduleAC.addAction(cancelAction)
            
            self.presentViewController(scheduleAC, animated: true, completion: nil)
        } else {
            confirmBuildList()
        }
    }
    
    func confirmBuildList() {
        var list = (selectedList & 4) == 1 ? "Blue" : "Red"
        list += " \(selectedList & 3)"
        let ac = UIAlertController(title: "Build \(list) List for event \(ScheduleStore.sharedStore.currentSchedule!)", message: "Building this list will clear the previous queue of matches.  Do you want to continue?", preferredStyle: .Alert)
        let continueAction = UIAlertAction(title: "Continue", style: .Destructive, handler: {(action) in
            let hud = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
            hud.mode = .Indeterminate
            hud.labelText = "Building List"
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
                ScheduleStore.sharedStore.buildMatchListForGroup(self.selectedList)
                dispatch_async(dispatch_get_main_queue(), {
                    let hud = MBProgressHUD(forView: self.navigationController?.view)
                    let imageView = UIImageView(image: UIImage(named: "check"))
                    hud.customView = imageView
                    hud.mode = .CustomView
                    hud.labelText = "Completed"
                    hud.hide(true, afterDelay: 1)
                })
            })
        })
        ac.addAction(continueAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        ac.addAction(cancelAction)
        
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    func cancelScheduleRequest(sender:UITapGestureRecognizer) {
        ScheduleStore.sharedStore.cancelRequest({
            dispatch_async(dispatch_get_main_queue(), {
                let hud = MBProgressHUD(forView: self.navigationController?.view)
                let imageView = UIImageView(image: UIImage(named: "close"))
                self.navigationItem.leftBarButtonItem?.enabled = true
                self.getScheduleButton.enabled = true
                for b in self.listSelectorButtons {
                    b.enabled = ScheduleStore.sharedStore.currentSchedule != nil
                }
                self.buildListButton.enabled = self.selectedList > 0
                hud.customView = imageView
                hud.mode = .CustomView
                hud.labelText = "Canceled"
                hud.hide(true, afterDelay: 1)
            })
        })
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
