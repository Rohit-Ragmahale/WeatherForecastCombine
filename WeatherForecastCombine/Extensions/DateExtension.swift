//
//  DateExtension.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 17/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation

extension Date {
    func getDaysInMonth() -> Int {
        let calender = Calendar.current
        let dateComponents = DateComponents(year: calender.component(.year, from: self), month: calender.component(.month, from: self))
        let date = calender.date(from: dateComponents)!
        let range = calender.range(of: .day, in: .month, for: date)!
        return range.count
    }

    func addMonth(month: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: month, to: self)!
    }

    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }

    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }

    func getDayOfWeek() -> Int? {
        let calender = Calendar(identifier: .gregorian)
        let weekDay = calender.component(.weekday, from: self)
        return weekDay
    }

    func getDay(days: Int) -> Date {
        let day = Calendar.current.date(byAdding: .day, value: days, to: self)!
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: day)!
    }

    func getHeaderText() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM, YYYY"
        return dateFormatter.string(from: self)
    }

    func getYearText() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
        return dateFormatter.string(from: self)
    }

    func getDateText() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY, HH:MM"
        return dateFormatter.string(from: self)
    }

    func getDateMonthText() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        return dateFormatter.string(from: self)
    }

    func daysFrom(date: Date) -> Int {
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: date)
        let date2 = calendar.startOfDay(for: self)
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day ?? -1
    }
}
