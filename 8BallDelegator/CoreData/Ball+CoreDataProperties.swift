//
//  Ball+CoreDataProperties.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 13.11.2021.
//
//

import Foundation
import CoreData

extension Ball {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ball> {
        return NSFetchRequest<Ball>(entityName: "Ball")
    }

    @NSManaged public var answer: String?
    @NSManaged public var id: UUID?
    @NSManaged public var type: String?
    @NSManaged public var question: String?

}

extension Ball: Identifiable {

}
