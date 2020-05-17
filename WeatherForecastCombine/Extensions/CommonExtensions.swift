//
//  CommonExtensions.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 17/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation
import UIKit

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

extension UIImageView {
    /// Loads image from web asynchronosly and caches it, in case you have to load url
    /// again, it will be loaded from cache if available
    func load(url: URL, placeholder: UIImage?, cache: URLCache? = nil) {
        let cache = cache ?? URLCache.shared
        let request = URLRequest(url: url)
        if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
            DispatchQueue.main.async {
                self.image = image
            }
        } else {
            self.image = placeholder
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data, let response = response, ((response as? HTTPURLResponse)?.statusCode ?? 500) < 300, let image = UIImage(data: data) {
                    let cachedData = CachedURLResponse(response: response, data: data)
                    cache.storeCachedResponse(cachedData, for: request)
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }).resume()
        }
    }
}
