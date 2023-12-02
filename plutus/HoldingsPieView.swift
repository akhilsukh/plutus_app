//
//  HoldingsPieView.swift
//  plutus
//
//  Created by Akhil Sukhthankar on 12/1/23.
//

import SwiftUI
import SwiftData

struct HoldingsPieChartView: View {
    @Binding var isPresented: Bool
    @Query private var items: [Holding]

    private var totalValue: Double {
        items.reduce(0) { $0 + ($1.currentPrice * $1.numSharesOwned) }
    }

    private var pieSliceData: [PieSliceData] {
        var startAngle = Angle(degrees: 0)
        return items.map { holding in
            let value = holding.currentPrice * holding.numSharesOwned
            let percentage = 100 * value / totalValue
            let endAngle = startAngle + Angle(degrees: 360 * percentage / 100)
            let slice = PieSliceData(
                startAngle: startAngle,
                endAngle: endAngle,
                label: holding.ticker,
                color: randomColor(),
                percentage: percentage
            )
            startAngle = endAngle
            return slice
        }
    }

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    ForEach(pieSliceData.indices, id: \.self) { index in
                        PieSliceView(data: pieSliceData[index])
                    }
                }
            }
            HoldingsDetailsView(pieSliceData: pieSliceData)
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

    func randomColor() -> Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

struct PieSliceData {
    var startAngle: Angle
    var endAngle: Angle
    var label: String
    var color: Color
    var percentage: Double
}

struct PieSliceView: View {
    var data: PieSliceData

    var midRadians: Double {
        return (data.startAngle.radians + data.endAngle.radians) / 2
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in
                    let width = min(geometry.size.width, geometry.size.height)
                    let center = CGPoint(x: width / 2, y: width / 2)
                    let radius = width / 2

                    path.move(to: center)
                    path.addArc(center: center, radius: radius,
                                startAngle: data.startAngle,
                                endAngle: data.endAngle,
                                clockwise: false)
                }
                .fill(data.color)

                // Add label for each slice
                Text(data.label)
                    .position(
                        x: geometry.size.width / 2 + CGFloat(cos(midRadians)) * 250 / 2,
                        y: geometry.size.height / 2 + CGFloat(sin(midRadians)) * 250 / 2
                    )
                    .foregroundColor(.white)
            }
        }
        .aspectRatio(0.80, contentMode: .fit)
        .padding()
    }
}

struct HoldingsDetailsView: View {
    var pieSliceData: [PieSliceData]

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(pieSliceData, id: \.label) { data in
                HStack {
                    Circle()
                        .fill(data.color)
                        .frame(width: 20, height: 20)
                    Text(data.label)
                    Spacer()
                    Text("\(data.percentage, specifier: "%.2f")%")
                }
            }
        }
        .padding()
    }
}


#Preview {
    @State var isPresented = true
    return HoldingsPieChartView(isPresented: $isPresented)
        .modelContainer(for: Holding.self)
}
