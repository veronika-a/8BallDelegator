//
//  Repository.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 08.11.2021.
//

import Foundation

class Repository {
    private let networkDataProvider: NetworkDataProvider

    init(networkDataProvider: NetworkDataProvider) {
        self.networkDataProvider = networkDataProvider
    }

    func getAnswer(completion: @escaping (Result<MagicResponse?, CallError>) -> Void) {
        networkDataProvider.getAnswer(completion: completion)
    }
}
