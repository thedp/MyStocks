import Foundation
import Alamofire
import SwiftyJSON

// Doc: https://www.alphavantage.co/documentation/

class API {
    
    var symbol: String?
    
    init(symbol: String) {
        self.symbol = symbol
    }
    
    func makeDailyRequest(resultClosure: @escaping ([StockHistory]) -> ()) {
        guard let symbol = self.symbol else { return }
        let url = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(symbol)&outputsize=compact&apikey=\(AppDelegate.alphaVantageAPIKey)"
        
        Alamofire.request(url).responseJSON { response in
            guard let value = response.result.value else { return }
            let json = JSON(value)
            
            var historyList = [StockHistory]()
            for (dateString, infoDict) in json["Time Series (Daily)"] {
                guard let stockHistory = self.constructStockHistory(dateString: dateString, infoDict: infoDict) else { continue }
                historyList.append(stockHistory)
            }
            resultClosure(historyList)
        }
    }
    
    func makeIntradayRequest(resultClosure: @escaping ([StockHistory]) -> ()) {
        guard let symbol = self.symbol else { return }
        let url = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&interval=1min&symbol=\(symbol)&outputsize=compact&apikey=\(AppDelegate.alphaVantageAPIKey)"
        
        Alamofire.request(url).responseJSON { response in
            guard let value = response.result.value else { return }
            let json = JSON(value)
            
            var historyList = [StockHistory]()
            for (dateString, infoDict) in json["Time Series (1min)"] {
                let test = self.constructStockHistory(dateString: dateString, infoDict: infoDict)
                guard let stockHistory = test else { continue }
                historyList.append(stockHistory)
            }
            resultClosure(historyList)
        }
    }
    
    private func constructStockHistory(dateString: String, infoDict: JSON) -> StockHistory? {
        guard let closingPrice = Double(infoDict["4. close"].stringValue) else { return nil }
        guard let date = Date.getDateFromString(dateString: dateString) else { return nil }
        return StockHistory(date: date, closingPrice: closingPrice)
    }
}
