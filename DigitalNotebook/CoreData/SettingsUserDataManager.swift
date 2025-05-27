//
//  SettingsUserDataManager.swift
//  DigitalNotebook
//
//  Created by Developer on 26/05/25.
//

import UIKit

class SettingsUserDataManager {
    static let shared = SettingsUserDataManager()
    
    let emailNotification = "emailNotification"
    let pushNotification = "pushNotification"
    let userImage = "userImage"
    
    private let defaults = UserDefaults.standard
    
    func initializeUserSettingsValues() {
        if defaults.value(forKey: emailNotification) == nil {
            defaults.setValue(true, forKey: emailNotification)
        }
        if defaults.value(forKey: pushNotification) == nil {
            defaults.setValue(true, forKey: pushNotification)
        }
    }
    
    func fetchUserData(to forKey: String) -> Any {
        return defaults.value(forKey: forKey) as Any
    }
    
    func setUserData(to forKey: String, value: Any) {
        defaults.setValue(value, forKey: forKey)
    }
}
