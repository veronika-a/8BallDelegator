//
//  Ball+CoreDataProperties.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 24.11.2021.
//
//

import Foundation
import CoreData

extension Ball {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ball> {
        return NSFetchRequest<Ball>(entityName: "Ball")
    }

    @NSManaged public var answer: String?
    @NSManaged public var date: Date?
    @NSManaged public var question: String?
    @NSManaged public var type: String?

}

extension Ball: Identifiable {

}
