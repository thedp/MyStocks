import Foundation

class MainPresenter {
    
    private var cachedFormattedStocks = [String: FormattedStock]()
    private var currentlyActiveStockRequests = Set<String>()
    private var dailyAPI = AlphaVantageAPIDaily()
    private var intradayAPI = AlphaVantageAPIIntraday()
    
    func getStock(stock: Stock, completionClosure: @escaping (FormattedStock) -> ()) {
        guard let symbol = stock.symbol else { return }
        guard !self.currentlyActiveStockRequests.contains(symbol) else { return }
        
        if cachedFormattedStocks[symbol] != nil {
            // if already cached, use it
            completionClosure(cachedFormattedStocks[symbol]!)
            return
        }
        
        self.currentlyActiveStockRequests.insert(symbol)
        
        let formattedStock = FormattedStock()
        formattedStock.formatSymbolText(rawSymbol: symbol)
        formattedStock.formatNameText(rawName: stock.name)
        
        self.dailyAPI.call(symbol: symbol, resultClosure: { [weak self] result in
            guard let timeSeries = result.timeSeries else {
                self?.finishAPIcall(symbol: symbol)
                return
            }
            let sortedTimeSeries = timeSeries.sorted{ Date.getDateFromString(dateString: $0.key)! < Date.getDateFromString(dateString: $1.key)! }
            formattedStock.formatTrend(priceHistory: sortedTimeSeries)
            formattedStock.formatGraphData(priceHistory: sortedTimeSeries)
            
            self?.intradayAPI.call(symbol: symbol, resultClosure: { result in
                guard let timeSeries = result.timeSeries else {
                    self?.finishAPIcall(symbol: symbol)
                    return
                }
                let sortedTimeSeries = timeSeries.sorted{ Date.getDateFromString(dateString: $0.key)! < Date.getDateFromString(dateString: $1.key)! }
                formattedStock.formatCurrentPrice(priceHistory: sortedTimeSeries)
                
                self?.cachedFormattedStocks[symbol] = formattedStock
                self?.finishAPIcall(symbol: symbol)
                completionClosure(formattedStock)
            })
        })
    }
    
    private func finishAPIcall(symbol: String) {
        self.currentlyActiveStockRequests.remove(symbol)
    }
}

class Stock {
    var name: String?
    var symbol: String?
    
    init(name: String, symbol: String) {
        self.name = name
        self.symbol = symbol
    }
}

class FormattedStock {
    
    var nameText = ""
    var symbolText = ""
    var currentPriceText = ""
    var trendText = ""
    var trendDirection = false
    
    var graphAxisLabels = [String]()
    var graphPoints = [Double]()
    
    func formatGraphData(priceHistory: [(key: String, value: AlphaVantageTimeSeriesEntry)]?) {
        guard let priceHistory = priceHistory else { return }
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM-dd"
        for (key, value) in priceHistory {
            let date = dateFormatterPrint.string(from: Date.getDateFromString(dateString: key)!)
            self.graphAxisLabels.append(date)
            self.graphPoints.append(Double(value.close ?? "0") ?? 0)
        }
        let toRange = graphAxisLabels.count - 1
        let fromRange = graphAxisLabels.count - 7
        self.graphAxisLabels = Array(self.graphAxisLabels[fromRange..<toRange])
        self.graphPoints = Array(self.graphPoints[fromRange..<toRange])
    }
    
    func formatNameText(rawName: String?) {
        self.nameText = rawName ?? "n/a"
    }
    
    func formatSymbolText(rawSymbol: String?) {
        self.symbolText = rawSymbol ?? "n/a"
    }

    func formatCurrentPrice(priceHistory: [(key: String, value: AlphaVantageTimeSeriesEntry)]?) {
        guard let count = priceHistory?.count, count > 0 else { return }
        let lastIndex = count - 1
        self.currentPriceText = String(describing: String(format: "%.1f", Double(priceHistory?[lastIndex].value.close ?? "0.0") ?? 0))
    }

    func formatTrend(priceHistory: [(key: String, value: AlphaVantageTimeSeriesEntry)]?) {
        guard let count = priceHistory?.count, count > 0 else { return }
        let lastIndex = count - 1
        guard let first = priceHistory?[lastIndex].value.close, let second = priceHistory?[lastIndex - 1].value.close else { return }
        let delta =  (Double(first) ?? 0) - (Double(second) ?? 0)
        self.trendDirection = delta >= 0
        self.trendText = "\(self.trendDirection ? "+" : "")\(String(format: "%.1f", delta))"
    }
}

extension Date {
    static func getDateFromString(dateString: String) -> Date? {
        let date = Date.getDateFromString(dateString: dateString, formatString: "yyyy-MM-dd HH:mm:ss")
        if date != nil { return date }
        return Date.getDateFromString(dateString: dateString, formatString: "yyyy-MM-dd")
    }
    
    static func getDateFromString(dateString: String, formatString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatString
        return dateFormatter.date(from: dateString)
    }
}
