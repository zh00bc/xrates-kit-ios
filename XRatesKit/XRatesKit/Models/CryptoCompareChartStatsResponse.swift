import ObjectMapper

struct CryptoCompareChartStatsResponse: ImmutableMappable {
    let chartPoints: [ChartPoint]

    init(map: Map) throws {
        var chartPoints = [ChartPoint]()

        if let rateDataList: [[String: Any]] = try? map.value("Data.Data") {
            for rateData in rateDataList {
                if let timestamp = rateData["time"] as? Int, let open = rateData["open"] as? Double, let close = rateData["close"] as? Double {
                    let rateValue = NSNumber(value: (open + close) / 2).decimalValue
                    chartPoints.append(ChartPoint(timestamp: TimeInterval(timestamp), value: rateValue))
                }
            }
        }

        self.chartPoints = chartPoints
    }

}