//
//  StockInputView.swift
//  plutus
//
//  Created by Akhil Sukhthankar on 11/20/23.
//

import SwiftUI

struct StockInputView: View {
    @Environment(\.modelContext) var modelContext
    var dismissAction: () -> Void
    
    @State private var showingAlert = false
    @State private var alertMessage = ""

    @State private var ticker: String = ""
    @State private var averageCost: String = ""
    @State private var numberOfShares: String = ""
    
    let allTickers = ["AAPL", "MSFT", "GOOGL", "AMZN", "FB", "TSLA", "AVGO", "ARM", "GM", "GOOG", "NVDA", "TSM"] // Your static list of tickers

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Stock")) {
                    TextField("Stock Ticker", text: $ticker)
                }
                Section(header: Text("Lot Information")) {
                    TextField("Average Cost", text: $averageCost)
                        .keyboardType(.decimalPad)
                    TextField("Number of Shares", text: $numberOfShares)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Stock Details")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: dismissAction)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Confirm") {
                        guard let cost = Double(averageCost), let shares = Double(numberOfShares) else {
                            return
                        }
                        submit(ticker: ticker, cost: cost, shares: shares)
                        dismissAction()
                    }
                }
            }
            .alert("Invalid Ticker", isPresented: $showingAlert) {
                Button("OK") {}
            }
        }
    }

    private func submit(ticker: String, cost: Double, shares: Double) {
        if !allTickers.contains(ticker) {
            alertMessage = "Ticker \(ticker) is not valid."
            showingAlert = true
        } else {
            Task {
                do {
                    let stockPrice = try await fetchTickerInfo(ticker: ticker)
                    let newHolding = Holding(ticker: ticker, avgCostPrice: cost, numSharesOwned: shares, dayOpenPrice: stockPrice.o, currentPrice: stockPrice.c)
                    DispatchQueue.main.async {
                        withAnimation {
                            modelContext.insert(newHolding)
                            dismissAction()
                        }
                    }
                } catch {
                    // If there is an error, handle it accordingly
                    DispatchQueue.main.async {
                        alertMessage = "Failed to fetch stock information: \(error.localizedDescription)"
                        showingAlert = true
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
