//
//  Extensions.swift
//  BabyMind
//
//  Yardımcı uzantılar
//

import Foundation
import SwiftUI

extension Date {
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: self)
    }
}

extension Double {
    func formatted(decimalPlaces: Int = 2) -> String {
        return String(format: "%.\(decimalPlaces)f", self)
    }
}







