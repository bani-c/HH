//
//  ViewController.swift
//  Home-Maintenance
//
//  Created by Bani on 14/09/2017.
//  Copyright © 2017 Ultron mobile. All rights reserved.
//

import UIKit
import JGProgressHUD
import EPSignature
import NYTPhotoViewer
import SQLite
import PDFGenerator

class PDFTemplateCountView:UIView, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblBuilding: UILabel!
    @IBOutlet weak var lblFloor: UILabel!
    @IBOutlet weak var lblRoom: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblCustomerName: UILabel!
    @IBOutlet weak var lblTel: UILabel!
    @IBOutlet weak var vwHeader: UIView!
  
    @IBOutlet weak var vwSign: UIView!
    @IBOutlet weak var ivSign0: UIImageView!
    @IBOutlet weak var ivSign1: UIImageView!
    @IBOutlet weak var ivSign2: UIImageView!
    
    @IBOutlet weak var lblPageNumber: UILabel!
    var pdfData:[PDFCountData] = []
    var index = 0
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.frame = CGRect(x: 0, y: 0, width: 612, height: 772)
        
        
        
        
    }
    
    func setup(_ pdfData:[PDFCountData], index:Int) {
        self.pdfData = pdfData
        self.index = index
        tableView.register(UINib(nibName: "PDFErrorCountCell", bundle: nil), forCellReuseIdentifier: "PDFErrorCountCell")
        
    }
    
    func initLayout() {
        
        vwHeader.layer.borderColor = UIColor.darkGray.cgColor
        vwHeader.layer.borderWidth = 1.0
        vwSign.layer.borderColor = UIColor.darkGray.cgColor
        vwSign.layer.borderWidth = 1.0
        
        tableView.layer.borderColor = UIColor.darkGray.cgColor
        tableView.layer.borderWidth = 1.0
        let projectsName = UserDefaults.standard.string(forKey: "PROJECT_NAME")
        let building = UserDefaults.standard.string(forKey: "BUILDING")
        let floor = UserDefaults.standard.string(forKey: "FLOOR")
        let room = UserDefaults.standard.string(forKey: "ROOM")
        lblTitle.text = projectsName! + " - 數量清點單"
        lblBuilding.text = building
        lblFloor.text = floor
        lblRoom.text = room
        lblPageNumber.text = String(format: "%d", (index / 20) + 1)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        lblDate.text = dateFormatter.string(from: Date())
        do {
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            if UserDefaults.standard.object(forKey: "sign0") != nil {
                let fileName = UserDefaults.standard.string(forKey: "sign0")
                let fileURL = documentDirectory.appendingPathComponent(fileName!)
                let image = try UIImage.init(data: Data.init(contentsOf: fileURL), scale:1.0)
                self.ivSign0.image = image
            }
            if UserDefaults.standard.object(forKey: "sign1") != nil {
                let fileName = UserDefaults.standard.string(forKey: "sign1")
                let fileURL = documentDirectory.appendingPathComponent(fileName!)
                let image = try UIImage.init(data: Data.init(contentsOf: fileURL), scale:1.0)
                self.ivSign1.image = image
            }
            if UserDefaults.standard.object(forKey: "sign2") != nil {
                let fileName = UserDefaults.standard.string(forKey: "sign2")
                let fileURL = documentDirectory.appendingPathComponent(fileName!)
                let image = try UIImage.init(data: Data.init(contentsOf: fileURL), scale:1.0)
                self.ivSign2.image = image
            }
        } catch {
            
        }
        
        
        
    }
    

    override func layoutSubviews() {
        initLayout()
    }
 
    //MARK: TableView Datasource and Delegate
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pdfData.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = pdfData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PDFErrorCountCell", for: indexPath) as! PDFErrorCountCell
        cell.selectionStyle = .none
        cell.lblTitle.text = data.title
        cell.lblAmount.text = "應有數量: " + data.amount
        cell.lblDetectAmount.text = "清點數量: " + data.detectAmount
        cell.lblLackAmount.text = "缺少數量: " +  String(format: "%d", Int(data.amount)! - Int(data.detectAmount)!)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
	
	
	
    
}


