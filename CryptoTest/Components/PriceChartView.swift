import Charts
import SwiftUI

private struct PricePoint: Identifiable {
    let id: Int
    let label: String
    let price: Double
}

struct PriceChartView: View {
    let labels: [String]
    let prices: [Double]

    /// Plotted by index rather than by `label` — labels (e.g. weekday names)
    /// repeat across a multi-day hourly series, and a categorical x-axis
    /// would group/reorder repeated categories instead of preserving
    /// chronological order.
    private var points: [PricePoint] {
        zip(labels, prices).enumerated().map { index, pair in
            PricePoint(id: index, label: pair.0, price: pair.1)
        }
    }

    private var trendColor: Color {
        guard let first = prices.first, let last = prices.last else { return .positive }
        return .priceChange(last - first)
    }

    private var priceRange: (min: Double, max: Double)? {
        guard let minPrice = prices.min(), let maxPrice = prices.max() else { return nil }
        return (minPrice, maxPrice)
    }

    private var useK: Bool {
        guard let range = priceRange else { return false }
        return Swift.max(abs(range.min), abs(range.max)) >= 1000
    }

    private var yAxisTicks: [Double] {
        guard let range = priceRange else { return [] }
        guard range.min != range.max else { return [range.min] }
        return (0..<5).map { range.min + (range.max - range.min) / 4 * Double($0) }
    }

    /// Picks the smallest decimal count (starting from 0/2, k-notation above
    /// $1000) that still keeps all 5 evenly-spaced tick labels visibly
    /// distinct after rounding — avoids e.g. "63k / 63k / 63k" collisions on
    /// tight price ranges.
    private var yAxisDecimals: Int {
        guard let range = priceRange, range.min != range.max else { return useK ? 0 : 2 }
        let maxDecimals = useK ? 3 : 4
        var decimals = useK ? 0 : 2
        let ticks = yAxisTicks
        for candidate in decimals...maxDecimals {
            decimals = candidate
            let rendered = ticks.map { formattedTick($0, decimals: candidate) }
            if Set(rendered).count == rendered.count { break }
        }
        return decimals
    }

    private func formattedTick(_ value: Double, decimals: Int) -> String {
        useK ? String(format: "%.\(decimals)fk", value / 1000) : String(format: "%.\(decimals)f", value)
    }

    /// AreaMark defaults to a zero-based y-domain, which would compress a
    /// tight price range (e.g. $62k–$64k) into a sliver at the top of the
    /// chart. Scope the domain to the actual data range instead, with a
    /// small margin so the line/area don't touch the chart edges.
    private var yDomain: ClosedRange<Double> {
        guard let range = priceRange else { return 0...1 }
        guard range.min != range.max else {
            let margin = Swift.max(abs(range.min) * 0.05, 1)
            return (range.min - margin)...(range.max + margin)
        }
        let margin = (range.max - range.min) * 0.05
        return (range.min - margin)...(range.max + margin)
    }

    private var accessibilityValueDescription: String {
        guard let first = prices.first, let last = prices.last, let range = priceRange else {
            return "No data"
        }
        let direction = last >= first ? "up" : "down"
        return "Ranges from \(range.min.formatted(.currency(code: "USD"))) to \(range.max.formatted(.currency(code: "USD"))), trending \(direction)"
    }

    var body: some View {
        if !prices.isEmpty {
            Chart(points) { point in
                AreaMark(
                    x: .value("Time", point.id),
                    yStart: .value("Baseline", yDomain.lowerBound),
                    yEnd: .value("Price", point.price)
                )
                    .foregroundStyle(trendColor.opacity(0.12).gradient)
                LineMark(x: .value("Time", point.id), y: .value("Price", point.price))
                    .foregroundStyle(trendColor)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                if points.count == 1 {
                    PointMark(x: .value("Time", point.id), y: .value("Price", point.price))
                        .foregroundStyle(trendColor)
                }
            }
            .chartXAxis(.hidden)
            .chartYScale(domain: yDomain)
            .chartYAxis {
                AxisMarks(values: yAxisTicks) { value in
                    AxisGridLine()
                    if let price = value.as(Double.self) {
                        AxisValueLabel(formattedTick(price, decimals: yAxisDecimals))
                    }
                }
            }
            .frame(height: 220)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Price chart")
            .accessibilityValue(accessibilityValueDescription)
        }
    }
}

#Preview {
    PriceChartView(
        labels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
        prices: [64_120, 63_780, 64_510, 63_205, 62_940, 63_310, 62_476]
    )
    .padding()
}
