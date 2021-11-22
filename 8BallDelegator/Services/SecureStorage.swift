//
//  SecureStorage.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 22.11.2021.
//

import Foundation
import SwiftKeychainWrapper

class SecureStorage {
    func setValue(_ value: String, forKey: String) {
        let saveSuccessful: Bool = KeychainWrapper.standard.set("\(value)", forKey: forKey)
        print("saveSuccessful = \(saveSuccessful)")
    }

    func getValue(forKey: String) -> String? {
        let value: String? = KeychainWrapper.standard.string(forKey: forKey)
        return value
    }
}
