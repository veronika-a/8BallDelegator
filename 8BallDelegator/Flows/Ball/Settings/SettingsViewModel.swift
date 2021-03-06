//
//  SettingsViewModel.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 19.11.2021.
//

import Foundation

class SettingsViewModel {
    private let settingsModel: SettingsModel

    init(settingsModel: SettingsModel) {
        self.settingsModel = settingsModel
    }
    
    func presentMain() {
        settingsModel.presentMain()
    }
}
