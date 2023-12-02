//
//  ContentView.swift
//  plutus
//
//  Created by Akhil Sukhthankar on 11/17/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Holding]
    
    @State private var showingStockInputSheet = false
    @State private var showingHoldingUpdateSheet = false
    
    @State private var currentFormattedTotalValue = "$XX,XXX"
    @State private var currentTotalGain = "$XX,XXX"
    @State private var currentDayGain = "$XX,XXX"
    
    @State private var isFetching = false
    @State private var updatingHoldings: [Holding] = []
    @State private var updatedHoldings: [Holding] = []

    let colorProfitGreen: Color = Color(red: 0, green: 0.55, blue: 0.05)
    let colorLossRed: Color = Color(red: 0.85, green: 0, blue: 0)

    var body: some View {
        NavigationSplitView {
            VStack {
                HStack {
                    Text("My Portfolio")
                        .font(.title2)
                        .bold()
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)
                        .padding(EdgeInsets(top: 2, leading: 16, bottom: 0, trailing: 16))
                    Spacer()
                }
                HStack {
                    Text(currentFormattedTotalValue)
                        .font(.largeTitle)
                        .fontDesign(.rounded)
                        .bold()
                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 2, trailing: 16))
                    Spacer()
                }
                HStack {
                    Text("Day's Gain: \(currentDayGain)")
                        .font(.headline)
                        .fontDesign(.rounded)
                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    Spacer()
                }
                HStack {
                    Text("Total Gain: \(currentTotalGain)")
                        .font(.headline)
                        .fontDesign(.rounded)
                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 4, trailing: 16))
                    Spacer()
                }
                List {
                    Section(header: HStack {
                        Text("Investments")
                    }, footer: Text("Total Value: \(currentFormattedTotalValue)")) {
                        ForEach(items) { item in
                            NavigationLink {
                                StockView(holding: item)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.ticker)
                                            .font(.headline)
                                            .fontDesign(.rounded)
                                        Text(formattedShares(shares: item.numSharesOwned))
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        formattedHoldingValueChangeText(holding: item)
                                        formattedTotalHoldingValueText(holding: item)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        showingStockInputSheet.toggle()
                    } label: {
                        Label("Add Holding", systemImage: "plus")
                    }
                }
                ToolbarItem() {
                    Button(action: {
                        updateAllHoldings()
                    }) {
                        Label("Update Holdings", systemImage: "arrow.clockwise")
                    }
                }
                ToolbarItem() {
                    NavigationLink(destination: PlutusInsightsView()) {
                        Label("View Insights", systemImage: "circle.hexagongrid.fill")
                    }
                }
            }
            .sheet(isPresented: $showingStockInputSheet) {
                StockInputView(modelContext: _modelContext, dismissAction: { showingStockInputSheet = false })
            }
            .onAppear() {
                calculateTotalHoldingsValue()
                calculateTotalGain()
                calculateDayGain()
            }
        } detail: {
            Text("Select an item")
        }
    }
    
    private func formattedShares(shares: Double) -> String {
        return String(format: "%.1f", shares) + " shares"
    }
    
    private func formatAsCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        // Assuming U.S. dollars
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        return formatter.string(from: NSNumber(value: value)) ?? "$\(String(format: "%.2f", value))"
    }
    
    private func calculateTotalHoldingsValue() {
        let totalValue = items.reduce(0) { partialResult, holding in
            partialResult + (holding.currentPrice * holding.numSharesOwned)
        }
        currentFormattedTotalValue = formatAsCurrency(totalValue)
    }
    
    private func calculateTotalGain() {
        let totalValue = items.reduce(0) { partialResult, holding in
            partialResult + holding.totalGainDollars
        }
        currentTotalGain = formatAsCurrency(totalValue)
    }
    
    private func calculateDayGain() {
        let totalValue = items.reduce(0) { partialResult, holding in
            partialResult + holding.dayGainDollars
        }
        currentDayGain = formatAsCurrency(totalValue)
    }
    
    private func formattedTotalHoldingValueText(holding: Holding) -> Text {
        let value = holding.currentPrice * holding.numSharesOwned
        return Text(formatAsCurrency(value))
    }

    private func formattedHoldingValueChangeText(holding: Holding) -> Text {
        let holdingProfited: Bool = holding.currentPrice >= holding.avgCostPrice
        let change = abs(holding.currentPrice - holding.avgCostPrice) * holding.numSharesOwned
        let changeText = formatAsCurrency(change)
        let sign = holdingProfited ? "+" : "-"

        return Text(sign + changeText)
            .foregroundStyle(holdingProfited ? colorProfitGreen : colorLossRed)
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
    
    private func updateAllHoldings() {
        isFetching = true
        updatingHoldings = items
        updatedHoldings = []

        for holding in updatingHoldings {
            Task {
                do {
                    let stockPrice = try await fetchTickerInfo(ticker: holding.ticker)
                    DispatchQueue.main.async {
                        withAnimation {
                            holding.currentPrice = stockPrice.c
                            holding.dayOpenPrice = stockPrice.o
                            try? modelContext.save()
                            updatedHoldings.append(holding)
                            updatingHoldings.removeAll { $0.ticker == holding.ticker }
                            if updatingHoldings.isEmpty {
                                isFetching = false
                            }
                        }
                    }
                } catch {
                    // Handle errors
                    print("Error updating \(holding.ticker): \(error)")
                    // Optionally, handle the failed update (e.g., move to a 'failedUpdates' list)
                    updatingHoldings.removeAll { $0.ticker == holding.ticker }
                    if updatingHoldings.isEmpty {
                        isFetching = false
                    }
                }
            }
        }
    }

    private func fetchTickerInfo(ticker: String) async throws -> StockPrice {
        let apiKey = "clfih89r01qovepq88v0clfih89r01qovepq88vg"
        let urlString = "https://finnhub.io/api/v1/quote?symbol=\(ticker)&token=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let stockPrice = try JSONDecoder().decode(StockPrice.self, from: data)
        return stockPrice
    }

}

#Preview {
    ContentView()
        .modelContainer(for: Holding.self)
}
