//
//  Date+extension.swift
//  SnapCat
//
//  Created by Corey Baker on 7/4/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation

// swiftlint:disable line_length

// Source: Leo Dabus, http://stackoverflow.com/questions/27310883/swift-ios-doesrelativedateformatting-have-different-values-besides-today-and
extension Date {
    func yearsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.year,
                                                           from: date,
                                                           to: self,
                                                           options: []).year ?? 0
    }
    func monthsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.month, from: date,
                                                           to: self,
                                                           options: []).month ?? 0
    }
    func weeksFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.weekOfYear,
                                                           from: date,
                                                           to: self,
                                                           options: []).weekOfYear ?? 0
    }
    func daysFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.day,
                                                           from: date,
                                                           to: self,
                                                           options: []).day ?? 0
    }
    func hoursFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.hour,
                                                           from: date,
                                                           to: self,
                                                           options: []).hour ?? 0
    }
    func minutesFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.minute,
                                                           from: date,
                                                           to: self,
                                                           options: []).minute ?? 0
    }
    func secondsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.second,
                                                           from: date,
                                                           to: self,
                                                           options: []).second ?? 0
    }
    var relativeTime: String {
        let now = Date()
        if now.yearsFrom(self)   > 0 {
            return now.yearsFrom(self).description  + " year"  + { return now.yearsFrom(self)   > 1 ? "s" : "" }() + " ago"
        }
        if now.monthsFrom(self)  > 0 {
            return now.monthsFrom(self).description + " month" + { return now.monthsFrom(self)  > 1 ? "s" : "" }() + " ago"
        }
        if now.weeksFrom(self)   > 0 {
            return now.weeksFrom(self).description  + " week"  + { return now.weeksFrom(self)   > 1 ? "s" : "" }() + " ago"
        }
        if now.daysFrom(self)    > 0 {
            if daysFrom(self) == 1 { return "Yesterday" }
            return now.daysFrom(self).description + " days ago"
        }
        if now.hoursFrom(self)   > 0 {
            return "\(now.hoursFrom(self)) hour"     + { return now.hoursFrom(self)   > 1 ? "s" : "" }() + " ago"
        }
        if now.minutesFrom(self) > 0 {
            return "\(now.minutesFrom(self)) minute" + { return now.minutesFrom(self) > 1 ? "s" : "" }() + " ago"
        }
        if now.secondsFrom(self) > 0 {
            if now.secondsFrom(self) < 15 { return "Just now"  }
            return "\(now.secondsFrom(self)) second" + { return now.secondsFrom(self) > 1 ? "s" : "" }() + " ago"
        }
        return ""
    }
}
