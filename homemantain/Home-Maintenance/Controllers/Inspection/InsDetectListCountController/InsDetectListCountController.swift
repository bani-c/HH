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


class InsDetectListCountController: UIViewController, UITableViewDelegate, UITableViewDataSource, EPSignatureDelegate {
	
	@IBOutlet weak var lblTitle: UILabel!
	@IBOutlet weak var tableView: UITableView!
	public var opName: String!
	public var caseName: String!
	public var projectName: String!
	let data0 = NSMutableArray.init()
	let data1 = NSMutableArray.init()
	var projectIndex:Int = 0
	var characterIndex:Int = 0
	var buildingIndex:Int = 0
	var catOpName:[String] = []
	var catOpId:[String] = []
	var catArea:[String] = []
	var catFilter = ["缺失項目", "通過項目", "全部項目"]
	var targetAreaData:[InsAreaItem] = []
	var targetItemData = NSMutableArray.init()
	var tmpAreaItem:InsAreaItem = InsAreaItem.init()
	var opIndex = 0
	var areaIndex:Int = 0
	var catFilterIndex:Int = 0
	var signIndex:Int = 0
    public var targetPlaceData:[InsPlaceItem] = []
    var placeData:[InsPlaceItem] = []
    var flowIdData:[String] = []
    var flowNameData:[String] = []
	var isPrint = false
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lcTable: NSLayoutConstraint!
    // MARK: Life Circle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resetTableViewHeight()
    }
    
    func resetTableViewHeight() {
        //lcTable.constant = tableView.contentSize.height
        view.updateConstraints()
    }
	override func viewDidLoad() {
		super.viewDidLoad()
		initLayaout()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: Custom Functions
	func initLayaout() {
		initData()
		
		//set title
		//lblTitle.text = caseName
		lblTitle.text = "數量清點單"
		
		//register nib
		tableView.register(UINib(nibName: "InsDetect0HeaderCell", bundle: nil), forCellReuseIdentifier: "InsDetect0HeaderCell")
        tableView.register(UINib(nibName: "InsHeaderTitleCell", bundle: nil), forCellReuseIdentifier: "InsHeaderTitleCell")
        
		tableView.register(UINib(nibName: "InsCountItemCell", bundle: nil), forCellReuseIdentifier: "InsCountItemCell")
		
        //init back button
        let btnBack = NaviTool.initBtnBack()
        btnBack.addTarget(self, action: #selector(btnBackPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(btnBack)
	}
	
	func initData() {
        for flowName in InsTmpDataManager.sharedInstance().flowNameData {
            catOpName.append(flowName)
        }
		catOpName.append("一般檢核項目")
        for flowId in InsTmpDataManager.sharedInstance().flowIdData {
            catOpId.append(flowId)
        }
		catOpId.append("Ins")
		print(catOpId[opIndex] + "_DataArea")
        initDisplayData()
	}
    
    func initDisplayData() {
        placeData = []
        if targetPlaceData.count > 0 {
            for i in 0...targetPlaceData.count - 1 {
                let tmpPlaceItem = InsPlaceItem()
                let placeItem = targetPlaceData[i]
                tmpPlaceItem.areaName = placeItem.areaName
                tmpPlaceItem.placeName = placeItem.placeName
                tmpPlaceItem.name = placeItem.name
                for insItem in placeItem.items {
                    if insItem.check {
                        if insItem.amount != "" && insItem.amount != "0" {
                            tmpPlaceItem.items.append(insItem)
                        }
                    }
                }
                if tmpPlaceItem.items.count != 0 {
                    placeData.append(tmpPlaceItem)
                }
            }
            tableView.reloadData()
        }
        
    }
	
	
	
	//MARK: TableView Datasource and Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        if isPrint {
            return placeData.count + 1
        } else {
            return placeData.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPrint {
            if section == 0 {
                return 0
            } else {
                return placeData[section - 1].items.count
            }
        } else {
            return placeData[section].items.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isPrint {
            if section == 0 {
                return tableView.frame.size.height / 7.0
            } else {
                return tableView.frame.size.height / 14.0
            }
        } else {
            return tableView.frame.size.height / 14.0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / 14.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 0 {
            return nil
        } else {
            if isPrint {
                if section == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "InsHeaderTitleCell") as! InsHeaderTitleCell
                    cell.lblTitle.text = "數量清點單"
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "InsDetect0HeaderCell") as! InsDetect0HeaderCell
                    cell.lblTitle.text = placeData[section - 1].name
                    return cell
                }
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "InsDetect0HeaderCell") as! InsDetect0HeaderCell
                cell.lblTitle.text = placeData[section].name
                return cell
                
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isPrint {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InsCountItemCell", for: indexPath) as! InsCountItemCell
            cell.selectionStyle = .none
            let insItem = placeData[indexPath.section - 1].items[indexPath.row]
            if insItem.name == "" {
                insItem.name = "數量檢核"
            }
            cell.lblTitle.text = String(indexPath.row + 1) + "." + insItem.name
            cell.tfCount.text = insItem.amount
            var amount = insItem.amount
            if amount == "" {
                amount = "0"
            }
            cell.tfDetectCount.text = String(insItem.detect_amount)
            cell.tfLessCount.text = String(Int(amount)! - insItem.detect_amount)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InsCountItemCell", for: indexPath) as! InsCountItemCell
            cell.selectionStyle = .none
            let insItem = placeData[indexPath.section].items[indexPath.row]
            if insItem.name == "" {
                insItem.name = "數量檢核"
            }
            cell.lblTitle.text = String(indexPath.row + 1) + "." + insItem.name
            cell.tfCount.text = insItem.amount
            var amount = insItem.amount
            if amount == "" {
                amount = "0"
            }
            cell.tfDetectCount.text = String(Int(amount)! - insItem.detect_amount)
            cell.tfLessCount.text = String(insItem.detect_amount)
            return cell
        }
       
    }
	
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.viewDidLayoutSubviews()
    }
    
    //MARK: Button Action
    @objc func btnBackPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
 
    @IBAction func clickPrint(_ sender: Any) {
        /*
        isPrint = true
        tableView.reloadData()
        tableView.setContentOffset(.zero, animated: false)
        do {
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let pdfURL = documentDirectory.appendingPathComponent("count.pdf")
   
        
            //try PDFGenerator.generate(self.tableView, to: pdfURL)
            var data = PDFWithScrollView(scrollview: self.tableView)
            data.write(toFile: pdfURL.path, atomically: true)
            data = PDFWithScrollView(scrollview: self.tableView)
            data.write(toFile: pdfURL.path, atomically: true)

        
            let printController = UIPrintInteractionController.shared
            let printInfo = UIPrintInfo(dictionary : nil)
            printInfo.duplex = .longEdge
            printInfo.outputType = .general
            printInfo.jobName = "列印數量清單"
            printController.printInfo = printInfo
            printController.printingItem = pdfURL
            printController.present(animated : true, completionHandler : nil)
        } catch let error {
            print(error)
        }
        isPrint = false
        tableView.reloadData()
        tableView.setContentOffset(.zero, animated: false)
        */
        let pdfURL = PDFCountGenerator().createPDF(placeData)
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary : nil)
        printInfo.duplex = .longEdge
        printInfo.outputType = .general
        printInfo.jobName = "列印數量清點單"
        printController.printInfo = printInfo
        printController.printingItem = pdfURL
        printController.present(animated : true, completionHandler : nil)
    }
    /*
    func PDFWithScrollView(scrollview: UIScrollView) -> NSData {
        
       
        
        let pageDimensions = scrollview.bounds
        
       
        let pageSize = pageDimensions.size
        let totalSize = scrollview.contentSize
        
        let numberOfPagesThatFitHorizontally = Int(ceil(totalSize.width / pageSize.width))
        let numberOfPagesThatFitVertically = Int(ceil(totalSize.height / pageSize.height))
        
        
        let outputData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(outputData, pageDimensions, nil)
        
        
        let savedContentOffset = scrollview.contentOffset
        let savedContentInset = scrollview.contentInset
        
        scrollview.contentInset = UIEdgeInsets.zero
        
        
        
        if let context = UIGraphicsGetCurrentContext()
        {
            for indexHorizontal in 0 ..< numberOfPagesThatFitHorizontally
            {
                for indexVertical in 0 ..< numberOfPagesThatFitVertically
                {
                    
                    
                    
                    UIGraphicsBeginPDFPage()
                    
                   
                    
                    let offsetHorizontal = CGFloat(indexHorizontal) * pageSize.width
                    let offsetVertical = CGFloat(indexVertical) * pageSize.height
                    
                    scrollview.contentOffset = CGPoint(x:offsetHorizontal, y:offsetVertical)
                    context.translateBy(x: -offsetHorizontal, y: -offsetVertical)
                   
                  
                    
                    scrollview.layer.render(in: context)
                }
            }
        }
       
        
        UIGraphicsEndPDFContext()
        
        
        
        scrollview.contentInset = savedContentInset
        scrollview.contentOffset = savedContentOffset
        
        
        return outputData
    }
 */
    
}

