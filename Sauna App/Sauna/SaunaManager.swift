//
//  SaunaManager.swift
//  Sauna
//
//  Created by William Henderson on 9/8/19.
//  Copyright © 2019 Knock Software, Inc. All rights reserved.
//

import Foundation
#if !os(macOS)
import HomeKit
#endif

protocol SaunaManagerDelegate: AnyObject {
    func saunaDidUpdate()
}

class SaunaManager: NSObject, ObservableObject, HMHomeManagerDelegate, HMAccessoryDelegate {
    let homeManager: HMHomeManager = HMHomeManager()
    private var saunaPowerAccessory: HMAccessory?
    private var saunaPowerCharacteristic: HMCharacteristic?
    private var saunaTemperatureAccessory: HMAccessory?
    private var saunaTemperatureCharacteristic: HMCharacteristic?
    
    var isOn: Bool? {
        get {
            return saunaPowerCharacteristic?.value as? Bool
        }
    }
    
    var temperatureFareinheit: Double? {
        get {
            guard let temperatureCelcius = saunaTemperatureCharacteristic?.value as? Double else {
                return nil
            }
            
            let temperatureFarenheit = temperatureCelcius * 9/5 + 32
            return temperatureFarenheit
        }
    }
    
    override init() {
        super.init()
        homeManager.delegate = self
    }
    
    func toggle() {
        guard let isOn = self.isOn else {
            return
        }
        
        self.saunaPowerCharacteristic?.writeValue(!isOn, completionHandler: { (error) in
            self.objectWillChange.send()
        })
    }
    
    func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
        if characteristic == saunaPowerCharacteristic || characteristic == saunaTemperatureCharacteristic {
            objectWillChange.send()
        }
    }
    
    func homeManager(_ manager: HMHomeManager, didUpdate status: HMHomeManagerAuthorizationStatus) {
        print("log")
    }
    
    func homeManagerDidUpdatePrimaryHome(_ manager: HMHomeManager) {
        print("log")
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        guard let home = manager.primaryHome else {
            return
        }
        
        for accessory in home.accessories {
            if accessory.manufacturer == "Home Assistant" && accessory.name.contains("Sauna") {
                for service in accessory.services {
                    if service.serviceType == HMServiceTypeSwitch {
                        for charateristic in service.characteristics {
                            if charateristic.characteristicType == HMCharacteristicTypePowerState {
                                charateristic.enableNotification(true) { (error) in
                                    guard error == nil else {
                                        return
                                    }
                                    
                                    self.saunaPowerAccessory = accessory
                                    self.saunaPowerAccessory!.delegate = self
                                    self.saunaPowerCharacteristic = charateristic
                                    self.objectWillChange.send()
                                }
                            }
                        }
                    } else if service.serviceType == HMServiceTypeTemperatureSensor {
                        for charateristic in service.characteristics {
                            if charateristic.characteristicType == HMCharacteristicTypeCurrentTemperature {
                                charateristic.enableNotification(true) { (error) in
                                    guard error == nil else {
                                        return
                                    }
                                    
                                    self.saunaTemperatureAccessory = accessory
                                    self.saunaTemperatureAccessory!.delegate = self
                                    self.saunaTemperatureCharacteristic = charateristic
                                    self.objectWillChange.send()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
