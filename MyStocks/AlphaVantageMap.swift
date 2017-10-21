import Foundation
import ObjectMapper

class AlphaVantageDailyResponse: Mappable {
    
    var timeSeries: [String: AlphaVantageTimeSeriesEntry]?
    
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        timeSeries <- map["Time Series (Daily)"]
    }
}

class AlphaVantageIntradayResponse: Mappable {
    
    var timeSeries: [String: AlphaVantageTimeSeriesEntry]?
    
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        timeSeries <- map["Time Series (1min)"]
    }
}

class AlphaVantageTimeSeriesEntry: Mappable {
    
//    "1. open": "78.3200",
//    "2. high": "78.9700",
//    "3. low": "78.2200",
//    "4. close": "78.8100",
//    "5. volume": "22517092
    
    var close: String?
    
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        close <- map["4. close", delimiter: "->"]
    }
}
