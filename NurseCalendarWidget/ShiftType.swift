import Foundation
import SwiftUI

enum ShiftType: Codable, Hashable {
    case day
    case night
    case afterNight
    case rest
    case custom(String)
    
    var name: String {
        switch self {
        case .day: return "白班"
        case .night: return "夜班"
        case .afterNight: return "下夜"
        case .rest: return "休息"
        case .custom(let name): return name
        }
    }
    
    var color: Color {
        switch self {
        case .day: return .blue
        case .night: return .purple
        case .afterNight: return .orange
        case .rest: return .gray
        case .custom: return .green
        }
    }
    
    static var defaultPattern: [ShiftType] {
        [.day, .night, .afterNight, .rest]
    }
    
    static var predefinedCases: [ShiftType] {
        [.day, .night, .afterNight, .rest]
    }
    
    static var allCases: [ShiftType] {
        predefinedCases
    }
} 