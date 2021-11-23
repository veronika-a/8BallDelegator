//
//  SecureStorage.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 22.11.2021.
//

import Foundation
import SwiftKeychainWrapper

class SecureStorage {
    let keychainWrapper: KeychainWrapper

    init() {
        keychainWrapper = KeychainWrapper.standard
    }

    func setValue(_ value: String, forKey: String) {
        let saveSuccessful: Bool = keychainWrapper.set("\(value)", forKey: forKey)
        print("saveSuccessful = \(saveSuccessful)")
    }

    func getValue(forKey: String) -> String? {
        let value: String? = keychainWrapper.string(forKey: forKey)
        return value
    }
}
