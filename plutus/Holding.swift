//
//  Item.swift
//  plutus
//
//  Created by Akhil Sukhthankar on 11/17/23.
//

import Foundation
import SwiftData

@Model
final class Holding {
    var ticker: String
    
    var avgCostPrice: Double
    var numSharesOwned: Double
    
    var dayOpenPrice: Double
    var currentPrice: Double
    
    var dayGainDollars: Double { (currentPrice - dayOpenPrice) * numSharesOwned }
    var dayGainPercent: Double { avgCostPrice != 0 ? ((currentPrice - dayOpenPrice) / avgCostPrice) * 100 : 0 }
    
    var totalGainDollars: Double { (currentPrice - avgCostPrice) * numSharesOwned }
    var totalGainPercent: Double { avgCostPrice != 0 ? ((currentPrice - avgCostPrice) / avgCostPrice) * 100 : 0 }
    
    var marketValue: Double { currentPrice * numSharesOwned }
    
    init(ticker: String, avgCostPrice: Double, numSharesOwned: Double, dayOpenPrice: Double, currentPrice: Double) {
        self.ticker = ticker
        self.avgCostPrice = avgCostPrice
        self.numSharesOwned = numSharesOwned
        self.dayOpenPrice = dayOpenPrice
        self.currentPrice = currentPrice
    }
}
