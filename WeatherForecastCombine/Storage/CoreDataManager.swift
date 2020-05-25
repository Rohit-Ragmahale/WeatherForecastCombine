//
//  CoreDataManager.swift
//  SocialMediaBanking
//
//  Created by TCS on 30/10/19.
//  Copyright © 2019 RBS. All rights reserved.
//

import Foundation
import CoreData

//class Pincode: String {
//
//    let code: String
//    init?(pin: Stirng){
//        if(isValidPin(pin: pin)) {
//            self.code = pin
//        } else {
//            return nil
//        }
//    }
//
//    func isValidPin(pin: String) {
//        if pin.count == 6 {
//            return true
//        }
//        return false
//    }
//}


class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
   
    func bookmarkLocation(city: String) {
         let bookmarkedEntiries: [BookMark] = Entity<BookMark>.fetch(onContext: WeatherCoreData.shared.mainContext(), predicate:NSPredicate(format: "pincode = '\(city)'"))
        if let bookmark = bookmarkedEntiries.first {
            bookmark.pincode = city
            WeatherCoreData.shared.mainContext().saveContext()
        } else {
            if let bookmark: BookMark = Entity<BookMark>.create(onContext: WeatherCoreData.shared.mainContext()) {
                bookmark.pincode = city
                WeatherCoreData.shared.mainContext().saveContext()
            }
        }
    }

    func getAllBookmarks() -> [String] {
        var bookmarks: [String] = []

        let bookmarkedEntiries: [BookMark] = Entity<BookMark>.fetch(
            onContext: WeatherCoreData.shared.mainContext(),
            predicate: nil)
        
        for bookmark in bookmarkedEntiries {
            bookmarks.append(bookmark.pincode ?? "")
        }
        
        return bookmarks
    }

    func deleteBookmark(city: String) {
        if !city.isEmpty {
            Entity<BookMark>.deleteAllObjectsOfType(
                predicate: NSPredicate(format: "pincode = '\(city)'"),
                context: WeatherCoreData.shared.mainContext())
            WeatherCoreData.shared.mainContext().saveContext()
        }
    }
    
    func deleteAllBookmark() {
            Entity<BookMark>.deleteAllObjectsOfType(
                predicate: nil,
                context: WeatherCoreData.shared.mainContext())
            WeatherCoreData.shared.mainContext().saveContext()
        
    }
}
