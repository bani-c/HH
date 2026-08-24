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
import PDFGenerator
import SQLite

class InsDetectListConfirmFinalController: UIViewController, UITableViewDelegate, UITableViewDataSource, EPSignatureDelegate {
	
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
    var placeData:[InsPlaceItem] = []
    var placeAllData:[InsPlaceItem] = []
    var isPrint = false
	
    var targetCell: InsDetectSignCell?
    @IBOutlet weak var lcTable: NSLayoutConstraint!
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var ivSign0: UIImageView!
	@IBOutlet weak var ivSign1: UIImageView!
	@IBOutlet weak var ivSign2: UIImageView!
	// MARK: Life Circle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resetTableViewHeight()
    }
    
    func resetTableViewHeight() {
		let availableHeight = scrollview.bounds.height
		guard availableHeight > 0, abs(lcTable.constant - availableHeight) > 0.5 else {
			return
		}
		lcTable.constant = availableHeight
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
		UserDefaults.standard.removeObject(forKey: "sign0")
        UserDefaults.standard.removeObject(forKey: "sign1")
        UserDefaults.standard.removeObject(forKey: "sign2")
		//set title
		//lblTitle.text = caseName
		lblTitle.text = "驗屋確認單"
		
		//register nib
		tableView.register(UINib(nibName: "InsDetect0HeaderCell", bundle: nil), forCellReuseIdentifier: "InsDetect0HeaderCell")
        tableView.register(UINib(nibName: "InsHeaderTitleCell", bundle: nil), forCellReuseIdentifier: "InsHeaderTitleCell")
        
		tableView.register(UINib(nibName: "InsDetect0ItemCell", bundle: nil), forCellReuseIdentifier: "InsDetect0ItemCell")
        tableView.register(UINib(nibName: "InsDetectSignCell", bundle: nil), forCellReuseIdentifier: "InsDetectSignCell")
		
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
		initAreaItem()
        initDisplayData()
        initDisplayAllData()
        //initSign()
	}
	
    func initSign() {
        do {
            
            
            let projectsNo = UserDefaults.standard.string(forKey: "PROJECT_NO")!
            
            let building = UserDefaults.standard.string(forKey: "BUILDING")!
            let fileNameUpload = String.init(format: SystemConstants.DBFileNameSubUpload, projectsNo, building)
            
            
            let room = UserDefaults.standard.string(forKey: "ROOM")!
            let floor = UserDefaults.standard.string(forKey: "FLOOR")!
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileName = String.init(format: SystemConstants.DBFileNameSub, projectsNo, building)
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            
            
            let db = try Connection(fileURL.absoluteString)
            let InspSignUploadFile = Table("InspSignUploadFile")
            let FileName = Expression<String?>("FileName")
            let FileType = Expression<String?>("FileType")
            
            
            let ELEVEL_2_1 = Expression<String?>("ELEVEL_2_1")
            let ELEVEL_2_2 = Expression<String?>("ELEVEL_2_2")
            let ELEVEL_1 = Expression<String?>("ELEVEL_1")
            let ChkNo = Expression<String?>("ChkNo")
            
            
            
            
            var query = InspSignUploadFile.select(FileName).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && ChkNo == InsTargetData.sharedInstance().inspNo && FileType == "0")
            
            for data in try db.prepare(query) {
                print("name: \(data[FileName]!)")
                let fileManager = FileManager.default
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURL = documentDirectory.appendingPathComponent(data[FileName]!)
                
                let image = try UIImage.init(data: Data.init(contentsOf: fileURL), scale:1.0)
                ivSign0.image = image
            }
            
            query = InspSignUploadFile.select(FileName).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && ChkNo == InsTargetData.sharedInstance().inspNo && FileType == "1")
            for data in try db.prepare(query) {
                print("name: \(data[FileName]!)")
                let fileManager = FileManager.default
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURL = documentDirectory.appendingPathComponent(data[FileName]!)
                
                let image = try UIImage.init(data: Data.init(contentsOf: fileURL), scale:1.0)
                ivSign1.image = image
            }
            
            query = InspSignUploadFile.select(FileName).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && ChkNo == InsTargetData.sharedInstance().inspNo && FileType == "2")
            for data in try db.prepare(query) {
                print("name: \(data[FileName]!)")
                let fileManager = FileManager.default
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURL = documentDirectory.appendingPathComponent(data[FileName]!)
                
                let image = try UIImage.init(data: Data.init(contentsOf: fileURL), scale:1.0)
                ivSign2.image = image
            }
            
            
            
        } catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        
    }
    
    func initAreaItem() {
        let tmpAreaData = InsTmpDataManager.sharedInstance().dicArea[catOpId[opIndex] + "_DataArea"]!
        targetAreaData.removeAll()
        tmpAreaItem = InsAreaItem.init()
        for areaData in tmpAreaData {
            let aData = InsAreaItem.init()
            aData.name = areaData.name
            aData.type = areaData.type
            aData.places = []
            for place in areaData.places {
                let tmpPlace = InsPlaceItem.init()
                tmpPlace.name = place.name
                for item in place.items {
                    tmpPlace.items.append(item)
                }
                aData.places.append(tmpPlace)
            }
            aData.items = []
            for item in areaData.items {
                aData.items.append(item)
            }
            targetAreaData.append(aData)
        }
        if targetAreaData.count == 0 || areaIndex == -1 {
            return
        }
        tmpAreaItem = targetAreaData[areaIndex]
        if tmpAreaItem.type == 0 {
            tmpAreaItem.places.removeAll()
            let insPlaceItem = InsPlaceItem.init()
            insPlaceItem.name = "檢核項目"
            for insItem in tmpAreaItem.items {
                if catFilterIndex == 0 {
                    if insItem.result == 1 {
                        insPlaceItem.items.append(insItem)
                    }
                } else if catFilterIndex == 1 {
                    if insItem.result == 0 {
                        insPlaceItem.items.append(insItem)
                    }
                } else if catFilterIndex == 2 {
                    insPlaceItem.items.append(insItem)
                }
            }
            if insPlaceItem.items.count != 0 {
                tmpAreaItem.places.append(insPlaceItem)
            }
            
        } else {
            var tmpPlaces:[InsPlaceItem] = []
            for placeItem in tmpAreaItem.places {
                var tmpItems:[InsItem] = []
                for insItem in placeItem.items {
                    if catFilterIndex == 0 {
                        if insItem.result == 1 {
                            tmpItems.append(insItem)
                        }
                    } else if catFilterIndex == 1 {
                        if insItem.result == 0 {
                            tmpItems.append(insItem)
                        }
                    } else if catFilterIndex == 2 {
                        tmpItems.append(insItem)
                    }
                }
                if tmpItems.count != 0 {
                    placeItem.items = tmpItems
                    tmpPlaces.append(placeItem)
                }
            }
            tmpAreaItem.places = tmpPlaces
        }
       
    }
    
    func initDisplayData() {
        placeData = []
        if catOpName.count == 0 {
            return
        }
        for i in 0...catOpName.count - 1 {
            let tmpAreaData = InsTmpDataManager.sharedInstance().dicArea[catOpId[i] + "_DataArea"]!
            for areaItem in tmpAreaData {
                if areaItem.type == 0 {
                    let placeItem = InsPlaceItem()
                    placeItem.areaName = areaItem.name
                    placeItem.name = catOpName[i] + "-" + areaItem.name
                    for insItem in areaItem.items {
                        if insItem.result == 1 {
                            placeItem.items.append(insItem)
                        }
                    }
                    if placeItem.items.count > 0 {
                        placeData.append(placeItem)
                    }
                } else {
                    
                    for placeItemTmp in areaItem.places {
                        let placeItem = InsPlaceItem()
                        placeItem.areaName = areaItem.name
                        placeItem.placeName = placeItemTmp.name
                        placeItem.name = areaItem.name + "-" + placeItemTmp.name
                        for insItem in placeItemTmp.items {
                            if insItem.result == 1 {
                                placeItem.items.append(insItem)
                            }
                        }
                        if placeItem.items.count > 0 {
                            placeData.append(placeItem)
                        }
                    }
                }
            }
        }
        tableView.reloadData()
    }
    
    func initDisplayAllData() {
        placeAllData = []
        if catOpName.count == 0 {
            return
        }
        for i in 0...catOpName.count - 1 {
            let tmpAreaData = InsTmpDataManager.sharedInstance().dicArea[catOpId[i] + "_DataArea"]!
            for areaItem in tmpAreaData {
                if areaItem.type == 0 {
                    let placeItem = InsPlaceItem()
                    placeItem.areaName = areaItem.name
                    placeItem.name = catOpName[i] + "-" + areaItem.name
                    for insItem in areaItem.items {
                        placeItem.items.append(insItem)
                    }
                    if placeItem.items.count > 0 {
                        placeAllData.append(placeItem)
                    }
                } else {
                    for placeItemTmp in areaItem.places {
                        let placeItem = InsPlaceItem()
                        placeItem.areaName = areaItem.name
                        placeItem.placeName = placeItemTmp.name
                        placeItem.name = areaItem.name + "-" + placeItemTmp.name
                        for insItem in placeItemTmp.items {
                            placeItem.items.append(insItem)
                        }
                        if placeItem.items.count > 0 {
                            placeAllData.append(placeItem)
                        }
                    }
                }
            }
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPrint {
            if section == placeData.count && isPrint {
                return placeData[section - 1].items.count + 1
            } else if section == 0 {
                return 0
            } else {
                return placeData[section - 1].items.count
            }
        } else {
            if section == placeData.count - 1 && isPrint {
                return placeData[section].items.count + 1
            } else {
                return placeData[section].items.count
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 58.0
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == placeData.count - 1 && isPrint && indexPath.row == placeData[indexPath.section].items.count {
            return 200.0
        } else {
			return 58.0
        }
    }
 
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 0 {
            return nil
        } else {
            if isPrint {
                if section == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "InsHeaderTitleCell") as! InsHeaderTitleCell
                    cell.lblTitle.text = "驗屋確認單"
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
            if indexPath.section == placeData.count && isPrint && indexPath.row == placeData[indexPath.section - 1].items.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "InsDetectSignCell") as! InsDetectSignCell
                
                targetCell = cell
                targetCell?.isHidden = true
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "InsDetect0ItemCell", for: indexPath) as! InsDetect0ItemCell
                cell.selectionStyle = .none
                let insItem = placeData[indexPath.section - 1].items[indexPath.row]
                if insItem.name == "" {
                    insItem.name = "數量檢核"
                }
                if insItem.amount.count != 0 && insItem.amount != "0"{
                    cell.lblTitle.text = String.init(format: "%d.%@ 數量:%@ ", indexPath.row + 1, insItem.name, insItem.amount)
                } else {
                    cell.lblTitle.text = String(indexPath.row + 1) + "." + insItem.name
                }
                cell.setCheck(InsItem: insItem)
                cell.tfNumber.isEnabled = false
                if insItem.desId != "" || insItem.inspRemark != "" || insItem.picUrl != "" {
                    cell.btnCamera.isHidden = false
                    cell.btnCamera.tag = indexPath.section * 10000 + indexPath.row
                    cell.btnCamera.addTarget(self, action: #selector(clickEdit(button:)), for: UIControlEvents.touchUpInside)
                } else {
                    cell.btnCamera.isHidden = true
                }
                
                return cell
            }
        } else {
            if indexPath.section == placeData.count - 1 && isPrint && indexPath.row == placeData[indexPath.section].items.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "InsDetectSignCell") as! InsDetectSignCell
                
                targetCell = cell
                targetCell?.isHidden = true
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "InsDetect0ItemCell", for: indexPath) as! InsDetect0ItemCell
                cell.selectionStyle = .none
                let insItem = placeData[indexPath.section].items[indexPath.row]
                if insItem.name == "" {
                    insItem.name = "數量檢核"
                }
                if insItem.amount.count != 0 && insItem.amount != "0"{
                    cell.lblTitle.text = String.init(format: "%d.%@ 數量:%@ ", indexPath.row + 1, insItem.name, insItem.amount)
                } else {
                    cell.lblTitle.text = String(indexPath.row + 1) + "." + insItem.name
                }
                cell.setCheck(InsItem: insItem)
                cell.tfNumber.isEnabled = false
                if insItem.desId != "" || insItem.inspRemark != "" || insItem.picUrl != "" {
                    cell.btnCamera.isHidden = false
                    cell.btnCamera.tag = indexPath.section * 10000 + indexPath.row
                    cell.btnCamera.addTarget(self, action: #selector(clickEdit(button:)), for: UIControlEvents.touchUpInside)
                } else {
                    cell.btnCamera.isHidden = true
                }
                
                return cell
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.viewDidLayoutSubviews()
    }
    
    @objc func clickEdit(button: UIButton) {
        
        let section = button.tag / 10000
        let row = button.tag % 10000
        let addMistakeEditController = AddMistakeEditController()
        addMistakeEditController.type = 2
        addMistakeEditController.areaName = placeData[section].areaName
        if placeData[section].placeName == "" {
            addMistakeEditController.placeName = placeData[section].items[row].name
        } else {
            addMistakeEditController.placeName = placeData[section].placeName
        }
        
        if placeData[section].items[row].desName == "" {
            addMistakeEditController.desName = placeData[section].items[row].name
        } else {
            addMistakeEditController.desName = placeData[section].items[row].desName
        }
        
        addMistakeEditController.targetInsItem = placeData[section].items[row]
        self.navigationController?.pushViewController(addMistakeEditController, animated: true)
        
    }
	
	func clickCamera(button: UIButton) {
		do {
            let section = button.tag / 10000
            let row = button.tag % 10000
            let insItem = placeData[section].items[row]
			
			let fileManager = FileManager.default
			let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
			let fileURL = documentDirectory.appendingPathComponent(insItem.picUrl)
			print(insItem.picUrl)
			let image = try UIImage.init(data: Data.init(contentsOf: fileURL), scale:1.0)
			var photos: [NYTPhoto] = []
            let title = NSAttributedString(string: insItem.name, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
            
			let photo = Photo.init(image:image, attributedCaptionTitle: title)
			photos.append(photo)
			let photosViewController = NYTPhotosViewController(photos: photos)
			present(photosViewController, animated: true, completion: nil)
			
		} catch {
			print(error)
		}
	}
	
    //MARK: Button Action
    @objc func btnBackPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
	
    @IBAction func clickCountDetail(_ sender: Any) {
        let insDetectListCountController = InsDetectListCountController()
        insDetectListCountController.targetPlaceData = placeAllData
        self.navigationController?.pushViewController(insDetectListCountController, animated: true)
    }
    
    @IBAction func btnNextPressed(_ sender: Any) {
        /*
		if ivSign0.image == nil {
			let alertController = UIAlertController(
				title: "提醒",
				message: "完成驗收，需有屋主代表簽名",
				preferredStyle: .alert)
			
			let okAction = UIAlertAction(title: "確定", style: .default) { (alertController) in
			}
			
			alertController.addAction(okAction)
			self.present(
				alertController,
				animated: true,
				completion: nil)
			return
		}
		
		if ivSign1.image == nil {
			let alertController = UIAlertController(
				title: "提醒",
				message: "完成驗收，需有業主代表簽名",
				preferredStyle: .alert)
			
			let okAction = UIAlertAction(title: "確定", style: .default) { (alertController) in
			}
			
			alertController.addAction(okAction)
			self.present(
				alertController,
				animated: true,
				completion: nil)
			return
		}
		
		if ivSign2.image == nil {
			let alertController = UIAlertController(
				title: "提醒",
				message: "完成驗收，需有主管簽名",
				preferredStyle: .alert)
			
			let okAction = UIAlertAction(title: "確定", style: .default) { (alertController) in
			}
			
			alertController.addAction(okAction)
			self.present(
				alertController,
				animated: true,
				completion: nil)
			return
		}
		*/
		print(InsTmpDataManager.sharedInstance().sign0UrlStr + " "  + InsTmpDataManager.sharedInstance().sign1UrlStr  + " " + InsTmpDataManager.sharedInstance().sign2UrlStr )
		let hud = JGProgressHUD(style: .dark)
		hud.vibrancyEnabled = true
		hud.textLabel.text = "儲存中..."
		hud.show(in: self.view)
		
		InsTmpDataManager.sharedInstance().saveData()
		
		hud.dismiss()
		
		InsTmpDataManager.sharedInstance().clearData()
		for viewController in (navigationController?.viewControllers)! {
            if viewController.isKind(of: InsDashboardController.self) {
				navigationController?.popToViewController(viewController, animated: true)
				break
			}
		}
		
	}
	
	@IBAction func btnSignPressed(_ sender: Any) {
		let btn = sender as! UIButton
		signIndex = btn.tag
		let signatureVC = EPSignatureViewController(signatureDelegate: self, showsDate: true, showsSaveSignatureOption: true)
		signatureVC.showsDate = false
        signatureVC.modalPresentationStyle = .fullScreen
		signatureVC.showsSaveSignatureOption = false
		signatureVC.title = "線上簽名"
		signatureVC.subtitleText = "簽名處"
		let nav = UINavigationController(rootViewController: signatureVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
		
	}
	
	func epSignature(_: EPSignatureViewController, didSign signatureImage : UIImage, boundingRect: CGRect) {
		switch signIndex {
		case 0:
			ivSign0.image = signatureImage
			do {
				if let data = UIImagePNGRepresentation(ivSign0.image!) {
					let fileManager = FileManager.default
					let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
					let userIdx = UserDefaults.standard.string(forKey: "UserIdx")
					let fileName = String.init(format: "%@_%.0f.png", userIdx!, NSDate().timeIntervalSince1970)
					let fileURL = documentDirectory.appendingPathComponent(fileName)
					UserDefaults.standard.set(fileName, forKey: "sign0")
                    try data.write(to: fileURL)
					InsTmpDataManager.sharedInstance().sign0UrlStr = fileName
					
				}
			} catch {
				print(error)
			}
			break
		case 1:
			ivSign1.image = signatureImage
			do {
				if let data = UIImagePNGRepresentation(ivSign1.image!) {
					let fileManager = FileManager.default
					let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
					let userIdx = UserDefaults.standard.string(forKey: "UserIdx")
					let fileName = String.init(format: "%@_%.0f.png", userIdx!, NSDate().timeIntervalSince1970)
					let fileURL = documentDirectory.appendingPathComponent(fileName)
					try data.write(to: fileURL)
                    UserDefaults.standard.set(fileName, forKey: "sign1")
					InsTmpDataManager.sharedInstance().sign1UrlStr = fileName
					
				}
			} catch {
				print(error)
			}
			break
		case 2:
			ivSign2.image = signatureImage
			do {
				if let data = UIImagePNGRepresentation(ivSign2.image!) {
					let fileManager = FileManager.default
					let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
					let userIdx = UserDefaults.standard.string(forKey: "UserIdx")
					let fileName = String.init(format: "%@_%.0f.png", userIdx!, NSDate().timeIntervalSince1970)
					let fileURL = documentDirectory.appendingPathComponent(fileName)
					try data.write(to: fileURL)
                    UserDefaults.standard.set(fileName, forKey: "sign2")
					InsTmpDataManager.sharedInstance().sign2UrlStr = fileName
					
				}
			} catch {
				print(error)
			}
			break
		
		default:
			return
		}
	}
	
	func epSignature(_: EPSignatureViewController, didCancel error : NSError) {
		
	}
    @IBAction func clickPrint(_ sender: Any) {
        /*
        isPrint = true
        tableView.reloadData()
        tableView.setContentOffset(.zero, animated: false)
        targetCell?.isHidden = false
        do {

            for i in 0...tableView.numberOfSections - 1  {
                for j in 0...tableView.numberOfRows(inSection: i) {
                  tableView.cellForRow(at: IndexPath(row: j, section: j))
                }
            }
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let pdfURL = documentDirectory.appendingPathComponent("final.pdf")
            var data = PDFWithScrollView(scrollview: self.tableView)
            data.write(toFile: pdfURL.path, atomically: true)
            data = PDFWithScrollView(scrollview: self.tableView)
            data.write(toFile: pdfURL.path, atomically: true)
           //try PDFGenerator.generate(self.tableView, to: pdfURL)
            let printController = UIPrintInteractionController.shared
            let printInfo = UIPrintInfo(dictionary : nil)
            printInfo.duplex = .longEdge
            printInfo.outputType = .grayscale
            printInfo.jobName = "列印驗屋確認單"
            printController.printInfo = printInfo
            printController.printingItem = pdfURL
            printController.present(animated : true, completionHandler : nil)
    
        } catch let error {
            print(error)
        }
      targetCell?.isHidden = true
        isPrint = false
        tableView.reloadData()
      tableView.setContentOffset(.zero, animated: false)
 */
        let pdfURL = PDFGenerator().createPDF(placeData)
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary : nil)
        printInfo.duplex = .longEdge
        printInfo.outputType = .general
        printInfo.jobName = "列印驗屋確認單"
        printController.printInfo = printInfo
        printController.printingItem = pdfURL
        printController.present(animated : true, completionHandler : nil)
        
    }

    @IBAction func btnListPressed(sender: AnyObject) {
        let button = sender as! UIButton
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        /*alert.addAction(UIAlertAction(title: "顯示數量清點單", style: .default) { _ in
            
            let insDetectListCountController = InsDetectListCountController()
            insDetectListCountController.targetPlaceData = self.placeAllData
            self.navigationController?.pushViewController(insDetectListCountController, animated: true)
            
            
            
        })*/
        
        
        alert.addAction(UIAlertAction(title: "列印驗屋缺失資料", style: .default) { _ in
            let pdfURL = PDFGenerator().createPDF(self.placeData)
            let printController = UIPrintInteractionController.shared
            let printInfo = UIPrintInfo(dictionary : nil)
            printInfo.duplex = .longEdge
            printInfo.outputType = .general
            printInfo.jobName = "列印驗屋確認單"
            printController.printInfo = printInfo
            printController.printingItem = pdfURL
            printController.present(animated : true, completionHandler : nil)
        })
        
        alert.addAction(UIAlertAction(title: "儲存驗屋紀錄", style: .default) { _ in
            print(InsTmpDataManager.sharedInstance().sign0UrlStr + " "  + InsTmpDataManager.sharedInstance().sign1UrlStr  + " " + InsTmpDataManager.sharedInstance().sign2UrlStr )
            let hud = JGProgressHUD(style: .dark)
            hud.vibrancyEnabled = true
            hud.textLabel.text = "儲存中..."
            hud.show(in: self.view)
            
            InsTmpDataManager.sharedInstance().saveData()
            
            hud.dismiss()
            
            InsTmpDataManager.sharedInstance().clearData()
            for viewController in (self.navigationController?.viewControllers)! {
                if viewController.isKind(of: InsDashboardController.self) {
                    self.navigationController?.popToViewController(viewController, animated: true)
                    break
                }
            }
        })
        
        
        let popPresenter = alert.popoverPresentationController
        popPresenter?.sourceView = button
        popPresenter?.sourceRect = button.bounds
        present(alert, animated: true)
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
 
 

