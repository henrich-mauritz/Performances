//
//  Time.swift
//  Performance
//
//  Created by Henrich Mauritz on 5/03/2022.
//

import Foundation

struct Time {
    var hoursString: String
    var minutesString: String
    var secondsString: String
    
    var hours: Int {
        get {
            guard let int = Int(hoursString) else {
                return 0
            }
            return int
        }
    }
    var minutes: Int {
        get {
            guard let int = Int(minutesString) else {
                return 0
            }
            return int
        }
    }
    var seconds: Double {
        get {
            guard let double = Double(secondsString) else {
                return 0.0
            }
            return double
        }
    }
    
    var timeInterval: TimeInterval {
        get {
            return (((Double(hours) * 60) + Double(minutes)) * 60 + seconds)
        }
    }
}
