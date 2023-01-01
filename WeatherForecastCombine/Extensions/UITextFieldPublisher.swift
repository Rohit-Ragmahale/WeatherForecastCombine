//
//  UITextFieldPublisher.swift
//  WeatherForecastCombine
//
//  Created by Rohit Ragmahale on 01/01/2023.
//  Copyright © 2023 Rohit. All rights reserved.
//

import UIKit
import Combine

extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .map { ($0.object as? UITextField)?.text  ?? "" }
            .eraseToAnyPublisher()
    }
}
