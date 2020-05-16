//
//  BookMark+CoreDataProperties.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 13/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//
//

import Foundation
import CoreData


extension BookMark {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookMark> {
        return NSFetchRequest<BookMark>(entityName: "BookMark")
    }

    @NSManaged public var pincode: String?

}
