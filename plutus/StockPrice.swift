//
//  StockPrice.swift
//  plutus
//
//  Created by Akhil Sukhthankar on 11/23/23.
//

import Foundation

// MARK: - StockPrice
struct StockPrice: Codable {
    let c, d, dp, h: Double
    let l, o, pc: Double
    let t: Int
}
