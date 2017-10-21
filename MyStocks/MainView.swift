import UIKit
import ScrollableGraphView

class MainView: UITableViewController {
    
    var data: [[Double]] = [[1,2,3,4], [40,2,3,4]]  // TODO: testing

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()  // TODO: testing
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2  // TODO: testing
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath) as! StockCell

        cell.nameLabel.text = "test"
        cell.setGraph(linePlotData: self.data[indexPath.row], xAxisLabels: ["a", "b", "c", "d"])
        
        return cell
    }
}

class StockCell: UITableViewCell, ScrollableGraphViewDataSource {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var trendLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
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






// TODO: remove
