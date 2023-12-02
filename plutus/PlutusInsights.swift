//
//  HoldingUpdateView.swift
//  plutus
//
//  Created by Akhil Sukhthankar on 11/30/23.
//

import SwiftUI
import SwiftData
import Charts

struct PlutusInsightsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Holding]
    
    @State private var showingBubbleSheet = false
    @State private var showingPieChartSheet = false

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "circle.hexagongrid.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(.blue)
                Text("Plutus Insights")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .fontDesign(.rounded)
                    .foregroundStyle(.blue)
                    .bold()
            }
            List {
                Section("Charts") {
                    Button(action: {
                        showingBubbleSheet.toggle()
                    }, label: {
                        Label("Bubble Chart", systemImage: "bubbles.and.sparkles.fill")
                    })
                    Button(action: {
                        showingPieChartSheet.toggle()
                    }, label: {
                        Label("Pie Chart", systemImage: "chart.pie.fill")
                    })
                }
            }
            .sheet(isPresented: $showingBubbleSheet, content: {
                BubbleChartView(isPresented: $showingBubbleSheet)
            })
            .sheet(isPresented: $showingPieChartSheet, content: {
                HoldingsPieChartView(isPresented: $showingPieChartSheet)
            })
        }
    }
}


#Preview {
    PlutusInsightsView()
        .modelContainer(for: Holding.self)
}
