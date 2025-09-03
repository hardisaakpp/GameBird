//
//  BackgroundConstants.swift
//  WordCraftGame
//
//  Created by Isaac Ortiz on 26/1/25.
//

import CoreFoundation
import Foundation
import QuartzCore

struct BackgroundConstants {
    static var textureName: String {
        return isNightTime() ? "Background-Night" : "background-day"
    }
    static let movementSpeed: CGFloat = 30.0
    static let zPosition: CGFloat = -99
    
    struct Size {
        static let widthRatio: CGFloat = 1.0
        static let heightRatio: CGFloat = 1.0
    }
}

// MARK: - Day/Night Helper
private func isNightTime(date: Date = Date(), calendar: Calendar = Calendar.current) -> Bool {
    // Si el modo día está forzado, siempre retornar false (día)
    if BackgroundConstants.isForcedDayMode() {
        return false
    }
    
    let components = calendar.dateComponents([.hour, .minute], from: date)
    guard let hour = components.hour, let minute = components.minute else { return false }
    let totalMinutes = hour * 60 + minute
    // Night: from 18:30 (1110) to 05:50 (350) next day
    let nightStart = 18 * 60 + 30 // 18:30
    let nightEnd = 5 * 60 + 50    // 05:50
    if nightStart <= totalMinutes { return true } // 18:30 .. 23:59
    if totalMinutes <= nightEnd { return true }   // 00:00 .. 05:50
    return false
}

extension BackgroundConstants {
    static func isNightNow() -> Bool { isNightTime() }
    
    // MARK: - Modo Día Forzado
    private static var forcedDayMode: Bool = false
    private static var forcedDayEndTime: TimeInterval = 0
    
    static func forceDayMode(duration: TimeInterval = 300) { // 5 minutos por defecto
        forcedDayMode = true
        forcedDayEndTime = CACurrentMediaTime() + duration
    }
    
    static func isForcedDayMode() -> Bool {
        if forcedDayMode {
            let currentTime = CACurrentMediaTime()
            if currentTime >= forcedDayEndTime {
                forcedDayMode = false
                return false
            }
            return true
        }
        return false
    }
    
    static func cancelForcedDayMode() {
        forcedDayMode = false
    }
}
