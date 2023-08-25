//
//  Utils.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 24/08/23.
//

import Foundation

struct Utils {
    static func convertDate(from input: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = inputFormatter.date(from: input) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd MMM yyyy"
            
            return outputFormatter.string(from: date)
        } else {
            return nil
        }
    }
    
    static func formatNumber(_ number: Int) -> String {
        switch number {
        case 0..<1000:
            return "\(number)"
        case 1000..<1_000_000:
            let formattedNumber = Double(number) / 1_000
            return String(format: "%.1fk", formattedNumber)
        default:
            let formattedNumber = Double(number) / 1_000_000
            return String(format: "%.1fM", formattedNumber)
        }
    }

}
