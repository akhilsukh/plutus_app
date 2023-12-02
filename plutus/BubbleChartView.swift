//
//  BubbleChartView.swift
//  plutus
//
//  Created by Akhil Sukhthankar on 12/1/23.
//

import SwiftUI
import SwiftData
import Charts

struct BubbleChartView: View {
    @Binding var isPresented: Bool
    @Query private var items: [Holding]
    
    var body: some View {
        NavigationView {
            VStack {
                Chart {
                    ForEach(items) { holding in
                        PointMark(
                            x: .value("Gain/Loss ($)", holding.totalGainDollars),
                            y: .value("Gain/Loss (%)", holding.totalGainPercent)
                        )
                        .annotation(position: .overlay) {
                            Text(holding.ticker)
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(preset: .aligned, position: .bottom)
                }
                .chartYAxis {
                    AxisMarks(preset: .aligned, position: .leading)
                }
                .padding()
            }
            .navigationTitle("Bubble Chart")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    @State var isPresented = true
    return BubbleChartView(isPresented: $isPresented)
        .modelContainer(for: Holding.self)
}
