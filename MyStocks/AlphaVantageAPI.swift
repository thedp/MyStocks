import Foundation
import Alamofire
import AlamofireObjectMapper

// Doc: https://www.alphavantage.co/documentation/

class AlphaVantageAPIDaily {
    
    func call(symbol: String, resultClosure: @escaping (AlphaVantageDailyResponse) -> ()) {
        let url = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(symbol)&outputsize=compact&apikey=\(AppDelegate.alphaVantageAPIKey)"
        Alamofire.request(url).responseObject { (response: DataResponse<AlphaVantageDailyResponse>) in
            guard let response = response.result.value else { return }
            resultClosure(response)
        }
    }
}

class AlphaVantageAPIIntraday {
    
    func call(symbol: String, resultClosure: @escaping (AlphaVantageIntradayResponse) -> ()) {
        let url = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&interval=1min&symbol=\(symbol)&outputsize=compact&apikey=\(AppDelegate.alphaVantageAPIKey)"
        Alamofire.request(url).responseObject { (response: DataResponse<AlphaVantageIntradayResponse>) in
            guard let response = response.result.value else { return }
            resultClosure(response)
        }
    }
}
