//
//  StockView.swift
//  plutus
//
//  Created by Akhil Sukhthankar on 11/22/23.
//

import SwiftUI

struct StockView: View {
    @State var holding: Holding // This would be passed in or fetched asynchronously

    let colorProfitGreen: Color = Color(red: 0, green: 0.55, blue: 0.05)
    let colorLossRed: Color = Color(red: 0.85, green: 0, blue: 0)

    var body: some View {
        VStack(alignment: .center) {
            Text(formatAsCurrency(holding.currentPrice))
                .font(.title)
                .fontDesign(.monospaced)
                .foregroundColor(holding.dayGainPercent >= 0 ? colorProfitGreen : colorLossRed)
            Text("\(holding.dayGainPercent, specifier: "%.2f")% (\(holding.dayGainDollars, specifier: "%.2f"))")
                .font(.title3)
                .fontDesign(.monospaced)
                .foregroundColor(holding.dayGainPercent >= 0 ? colorProfitGreen : colorLossRed)
            
            List {
                // Section for Change
                Section(header: Text("Change")) {
                    HStack {
                        Text("Day's Gain")
                        Spacer()
                        Text(formatAsCurrency(holding.dayGainDollars))
                    }
                    HStack {
                        Text("Total Gain")
                        Spacer()
                        Text(formatAsCurrency(holding.totalGainDollars))
                    }
                    HStack {
                        Text("Market Value")
                        Spacer()
                        Text(formatAsCurrency(holding.marketValue))
                    }
                }
                
                // Section for Lots
                Section(header: Text("Lots")) {
                    HStack {
                        Text("Average Cost")
                        Spacer()
                        Text(formatAsCurrency(holding.avgCostPrice))
                    }
                    HStack {
                        Text("Total Shares")
                        Spacer()
                        Text("\(holding.numSharesOwned, specifier: "%.0f")")
                    }
                }
                
                Section() {
                    Button("Edit Lots") {
                        // Action to edit lots
                    }
                    Button("Remove Stock", role: .destructive) {
                        // Action to remove stock
                    }
                }
            }
            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    EditButton()
//                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(holding.ticker)
        }
    }
    
    private func formatAsCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        return formatter.string(from: NSNumber(value: value)) ?? "$\(String(format: "%.2f", value))"
    }

}

#Preview {
    let dummyHolding = Holding(ticker: "TSLA", avgCostPrice: 100.0, numSharesOwned: 50, dayOpenPrice: 40, currentPrice: 150.0)
    return StockView(holding: dummyHolding)
}
