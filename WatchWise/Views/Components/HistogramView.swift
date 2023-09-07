//
//  HistogramView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 24/08/23.
//

import SwiftUI
import AxisRatingBar

struct HistogramView: View {
    @Binding var ratings: [CGFloat]
    let maxRating: Double = 5.0
    let step: Double = 0.5
    
    var body: some View {
        let ratingCounts = calculateRatingCounts()
        let maxCount = ratingCounts.max() ?? 0
        let totalRating = ratings.reduce(0, +)
        let averageRating = ratings.isEmpty ? 0.0 : totalRating / Double(ratings.count)
        
        HStack {
            LeftHistogramPartView(ratingsCount: ratings.count)
            
            HistogramBarView(ratingCounts: ratingCounts, maxCount: maxCount, step: step, ratings: $ratings)
            
            RightHistogramPartView(averageRating: averageRating)
        }
    }
}

struct LeftHistogramPartView: View {
    let ratingsCount: Int
    
    var body: some View {
        VStack {
            Text("\(Utils.formatNumber(ratingsCount))")
                .fontWeight(.thin)
            Image(systemName: "star")
                .resizable()
                .scaledToFit()
                .foregroundColor(.accentColor)
                .frame(width: 10, height: 10, alignment: .bottom)
        }
    }
}

struct HistogramBarView: View {
    let ratingCounts: [Int]
    let maxCount: Int
    let step: Double
    @Binding var ratings: [CGFloat]
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(0..<ratingCounts.count, id: \.self) { index in
                    let actualRating = Double(index + 1) * step
                    if actualRating > 0.0 {
                        Rectangle()
                            .fill(Color.accentColor.opacity(0.5))
                            .frame(height: !ratings.isEmpty ? CGFloat(ratingCounts[index]) / CGFloat(maxCount) * 50 + 1 : 1)
                    }
                }
            }
        }
    }
}

struct RightHistogramPartView: View {
    let averageRating: Double
    
    var body: some View {
        VStack {
            Text(String(format: "%.1f", !averageRating.isNaN ? averageRating : 0.0))
                .bold()
            HStack(spacing: 0) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.accentColor)
                        .frame(width: 10, height: 10, alignment: .bottom)
                }
            }
        }
    }
}

extension HistogramView {
    private func calculateRatingCounts() -> [Int] {
        var counts = [Int](repeating: 0, count: Int(maxRating / step))
        for rating in ratings {
            let index = Int(rating / step) - 1
            if index >= 0 && index < counts.count {
                counts[index] += 1
            }
        }
        return counts
    }
}


#Preview {
    HistogramView(ratings: .constant([0.5, 1, 1, 1.5, 2, 2, 2, 2.5, 3, 3, 4, 4.5, 5, 5, 0.5, 1, 1, 1.5, 2, 2, 2, 2.5, 3, 3, 4, 4.5, 5, 5, 0.5, 1, 1, 1.5, 2, 2, 2, 2.5, 3, 3, 4, 4.5, 5, 5, 0.5, 1, 1, 1.5, 2, 2, 2, 2.5, 3, 3, 4, 4.5, 5, 5, 0.5, 1, 1, 1.5, 2, 2, 2, 2.5, 3, 3, 4, 4.5, 5, 5]))
        .accentColor(.cyan)
}
