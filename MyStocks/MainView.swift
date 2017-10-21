import UIKit
import ScrollableGraphView
import Alamofire

class MainView: UITableViewController {

    let mp = MainPresenter()
    var stocksList = [Stock(name: "S&P 500", symbol: "INX"),
                Stock(name: "Dow Jones", symbol: "DJIA"),
                Stock(name: "Nasdaq", symbol: "NDAQ"),
                Stock(name: "Amazon", symbol: "AMZN"),
                Stock(name: "Alphabet", symbol: "GOOGL")
    ]

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stocksList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath) as! StockCell
        
        mp.getStock(stock: stocksList[indexPath.row], completionClosure: { formattedStock in
            cell.nameLabel.text = formattedStock.nameText
            cell.symbolLabel.text = formattedStock.symbolText
            cell.priceLabel.text = formattedStock.currentPriceText
            cell.trendLabel.text = formattedStock.trendText
            cell.trendLabelColor(trendDirection: formattedStock.trendDirection)
            cell.setGraph(linePlotData: formattedStock.graphPoints, xAxisLabels: formattedStock.graphAxisLabels)
        })
        
        return cell
    }
}

class StockCell: UITableViewCell, ScrollableGraphViewDataSource {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var trendLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    func trendLabelColor(trendDirection: Bool) {
        self.trendLabel.textColor = trendDirection ? .green : .red
    }
    
    // MARK: - graph related
    var linePlotData: [Double]?
    var xAxisLabels: [String]?
    
    func setGraph(linePlotData: [Double], xAxisLabels: [String]) {
        self.linePlotData = linePlotData
        self.xAxisLabels = xAxisLabels
        
        let graph = ScrollableGraphView(frame: self.bottomView.bounds, dataSource: self)
        let linePlot = LinePlot(identifier: "line") // Identifier should be unique for each plot.
        let referenceLines = ReferenceLines()
        graph.addPlot(plot: linePlot)
        graph.addReferenceLines(referenceLines: referenceLines)
        graph.rangeMax = self.linePlotData?.max() ?? 0
        graph.rangeMin = self.linePlotData?.min() ?? 0
        graph.shouldAnimateOnStartup = false
        self.bottomView.addSubview(graph)
    }
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        switch(plot.identifier) {
        case "line":
            guard let linePlotData = self.linePlotData else { return 0 }
            guard pointIndex < linePlotData.count else { return 0 }
            return linePlotData[pointIndex]
        default:
            return 0
        }
    }
    
    func label(atIndex pointIndex: Int) -> String {
        return self.xAxisLabels?[pointIndex] ?? ""
    }
    
    func numberOfPoints() -> Int {
        return self.linePlotData?.count ?? 0
    }
}
