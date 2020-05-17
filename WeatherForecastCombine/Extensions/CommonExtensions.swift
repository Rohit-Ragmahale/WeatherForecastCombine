//
//  CommonExtensions.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 17/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    func doubleValue() -> Double {
        let formatter = NumberFormatter()
        Formatter.number.locale = Locale.current // USA: Locale(identifier: "en_US")
        Formatter.number.numberStyle = .decimal
        return formatter.number(from: self) as? Double ?? 0.0
    }
}

extension Formatter {
    static let number = NumberFormatter()
}

extension FloatingPoint {
    func toString(min: Int = 2, max: Int = 2, roundingMode: NumberFormatter.RoundingMode = .floor) -> String {
        Formatter.number.minimumFractionDigits = min
        Formatter.number.maximumFractionDigits = max
        Formatter.number.minimumIntegerDigits = 1
        Formatter.number.roundingMode = roundingMode
        Formatter.number.numberStyle = .none
        return Formatter.number.string(for: self) ?? ""
    }
}
