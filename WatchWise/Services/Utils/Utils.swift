//
//  Utils.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 24/08/23.
//

import Foundation
import SwiftUI

struct Utils {
    static var linearGradient: LinearGradient {
        LinearGradient(colors: [.primary.opacity(0.1), .primary.opacity(0.3), .primary.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    static func formatDateToLocalString(dateString: String) -> String? {
        // Creare un DateFormatter per interpretare la stringa di data nel formato "YYYY-MM-DD"
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        // Convertire la stringa in un oggetto Date
        guard let date = inputFormatter.date(from: dateString) else {
            return nil
        }
        
        // Creare un altro DateFormatter per convertire l'oggetto Date in una stringa localizzata
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .long  // Formato lungo, es. "29 agosto 2023"
        outputFormatter.timeStyle = .none // Nessuna informazione sul tempo
        outputFormatter.locale = Locale.current // Utilizzare la lingua e le impostazioni locali correnti del dispositivo
        
        // Convertire l'oggetto Date in una stringa localizzata
        return outputFormatter.string(from: date)
    }
    
    static func formatDateToLocalString(date: Date) -> String {
        // Creare un DateFormatter per convertire l'oggetto Date in una stringa localizzata
        let formatter = DateFormatter()
        formatter.dateStyle = .long  // Formato lungo, es. "29 agosto 2023"
        formatter.timeStyle = .short // Formato breve, es. "14:32"
        formatter.locale = Locale.current // Utilizzare la lingua e le impostazioni locali correnti del dispositivo
        
        // Convertire l'oggetto Date in una stringa localizzata
        return formatter.string(from: date)
    }
    
    static func formatDateToLocalStringShort(date: Date) -> String {
        // Creare un DateFormatter per convertire l'oggetto Date in una stringa localizzata
        let formatter = DateFormatter()
        formatter.dateStyle = .short  // Formato lungo, es. "29 agosto 2023"
        formatter.timeStyle = .short // Formato breve, es. "14:32"
        formatter.locale = Locale.current // Utilizzare la lingua e le impostazioni locali correnti del dispositivo
        
        // Convertire l'oggetto Date in una stringa localizzata
        return formatter.string(from: date)
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
    
    static func formatToDollars(_ value: Int) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value))
    }
    
    static func convertSeasonEpisodeNumber(_ number: Int) -> String {
        if number < 10 {
            return "0\(number)"
        } else {
            return "\(number)"
        }
    }
    
    static func convertMinutesToTimeComponents(minutes: Int) -> (months: Int, days: Int, hours: Int) {
        let totalHours = minutes / 60
        let days = totalHours / 24
        let months = days / 30 // Considerando una media di 30 giorni per mese

        let remainingHours = totalHours % 24
        let remainingDays = days % 30

        return (months: months, days: remainingDays, hours: remainingHours)
    }

}
