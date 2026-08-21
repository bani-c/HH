//
//  ViewController.swift
//  Home-Maintenance
//
//  Created by Bani on 14/09/2017.
//  Copyright © 2017 Ultron mobile. All rights reserved.
//

import UIKit
import NYTPhotoViewer
import SQLite


class InsDetectFlowController: UIViewController {
	public var caseName: String!
	public var projectName: String!
	@IBOutlet weak var lblTitle: UILabel!
	@IBOutlet weak var lblProjectName: UILabel!
	@IBOutlet weak var vwOp0: UIView!
	@IBOutlet weak var vwOp1: UIView!
	@IBOutlet weak var vwOp2: UIView!
	@IBOutlet weak var vwOp3: UIView!
	
	@IBOutlet weak var vwStep1: UIView!
	@IBOutlet weak var vwStep2: UIView!
	
	@IBOutlet weak var vwStep1Inside: UIView!
	@IBOutlet weak var vwStep2Inside: UIView!
	@IBOutlet weak var ivStep10: UIImageView!
	
	@IBOutlet weak var ivStep11: UIImageView!
	
	@IBOutlet weak var ivStep12: UIImageView!
	
	@IBOutlet weak var ivStep13: UIImageView!
	@IBOutlet weak var ivMap: UIImageView!
	@IBOutlet weak var lblOp0: UILabel!
	@IBOutlet weak var lblOp1: UILabel!
	@IBOutlet weak var lblOp2: UILabel!
	@IBOutlet weak var lblOp3: UILabel!
	
	@IBOutlet weak var btnOp1: UIButton!
	@IBOutlet weak var btnOp2: UIButton!
	@IBOutlet weak var btnOp3: UIButton!
	
	@IBOutlet weak var btnStep2: UIButton!
	
	
	var flowIdData = [] as [String]
	var flowNameData = [] as [String]
	var phase:Int = 0
    var areaPicName = ""
    var planePicName = ""
	
	// MARK: Life Circle
	override func viewDidLoad() {
		super.viewDidLoad()
		initLayaout()
        
        let insDetectList1Controller = InsDetectList1Controller()
        insDetectList1Controller.projectName = projectName
        insDetectList1Controller.caseName = caseName
        insDetectList1Controller.opName = "驗屋項目"
        //self.navigationController?.pushViewController(insDetectList1Controller, animated: false)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        if UserDefaults.standard.object(forKey: "ISRECORD") != nil {
            setAllComplete()
        } else {
            setComplete()
            checkComplete()
        }
		setAllComplete()
		//setComplete()
	}
    
    func setAllComplete() {
        if flowIdData.count >= 1 {
                btnOp1.isEnabled = true
                btnOp1.backgroundColor = UIColor.clear
        }
        if flowIdData.count >= 2 {
            btnOp2.isEnabled = true
            btnOp2.backgroundColor = UIColor.clear
        }
        if flowIdData.count >= 3 {
            btnOp3.isEnabled = true
            btnOp3.backgroundColor = UIColor.clear
        }
        
        vwStep2Inside.backgroundColor = UIColor.init(red: 144.0 / 255.0, green: 33.0 / 255.0, blue: 38.0 / 255.0, alpha: 1.0)
        btnStep2.isEnabled = true
    }
	
	func checkComplete() {
		if flowIdData.count >= 1 {
            var sumNotCheck = 0
            let dataArea = InsTmpDataManager.sharedInstance().dicArea[flowIdData[0] + "_DataArea"] 
            for area in dataArea! {
                for item in area.items {
                    if item.check == false {
                        sumNotCheck += 1
                    }
                }
            }
            if sumNotCheck == 0 {
                ivStep10.isHidden = false
                btnOp1.isEnabled = true
                btnOp1.backgroundColor = UIColor.clear
            }
			//if InsTmpDataManager.sharedInstance().dicFlowFinish[flowIdData[0]] != nil {
				
				
			//}
		}
		if flowIdData.count >= 2 {
            var sumNotCheck = 0
            let dataArea = InsTmpDataManager.sharedInstance().dicArea[flowIdData[1] + "_DataArea"]
            for area in dataArea! {
                for item in area.items {
                    if item.check == false {
                        sumNotCheck += 1
                    }
                }
            }
            if sumNotCheck == 0 {
			//if InsTmpDataManager.sharedInstance().dicFlowFinish[flowIdData[1]] != nil {
				ivStep11.isHidden = false
				btnOp2.isEnabled = true
				btnOp2.backgroundColor = UIColor.clear
			}
		}
		if flowIdData.count >= 3 {
            var sumNotCheck = 0
            let dataArea = InsTmpDataManager.sharedInstance().dicArea[flowIdData[2] + "_DataArea"]
            for area in dataArea! {
                for item in area.items {
                    if item.check == false {
                        sumNotCheck += 1
                    }
                }
            }
            if sumNotCheck == 0 {
			//if InsTmpDataManager.sharedInstance().dicFlowFinish[flowIdData[2]] != nil {
				ivStep12.isHidden = false
				btnOp3.isEnabled = true
				btnOp3.backgroundColor = UIColor.clear
			}
		}
		if flowIdData.count >= 4 {
            var sumNotCheck = 0
            let dataArea = InsTmpDataManager.sharedInstance().dicArea[flowIdData[3] + "_DataArea"]
            for area in dataArea! {
                for item in area.items {
                    if item.check == false {
                        sumNotCheck += 1
                    }
                }
            }
            if sumNotCheck == 0 {
			//if InsTmpDataManager.sharedInstance().dicFlowFinish[flowIdData[3]] != nil {
				ivStep13.isHidden = false
			}
		}
        if flowIdData.count > 0 {
            if InsTmpDataManager.sharedInstance().dicFlowFinish[flowIdData[flowIdData.count - 1]] != nil {
                setComplete()
            }
        }
		
	}
	
	func setComplete() {
		vwStep2Inside.backgroundColor = UIColor.init(red: 144.0 / 255.0, green: 33.0 / 255.0, blue: 38.0 / 255.0, alpha: 1.0)
		btnStep2.isEnabled = true
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: Custom Functions
	func initLayaout() {
        initData()
        
		if flowIdData.count >= 1 {
			vwOp0.isHidden = false
		}
		
		if flowIdData.count >= 2 {
			vwOp1.isHidden = false
		}
		
		if flowIdData.count >= 3 {
			vwOp2.isHidden = false
		}
		
		if flowIdData.count >= 4 {
			vwOp3.isHidden = false
		}
        if flowNameData.count > 0 {
            for i in 0...flowNameData.count - 1 {
                switch i {
                case 0:
                    lblOp0.text = flowNameData[i]
                    break
                case 1:
                    lblOp1.text = flowNameData[i]
                    break
                case 2:
                    lblOp2.text = flowNameData[i]
                    break
                case 3:
                    lblOp3.text = flowNameData[i]
                    break
                default:
                    break;
                }
            }
        }
        
		//set title
        if UserDefaults.standard.object(forKey: "ISRECORD") != nil {
            lblTitle.text = "驗屋紀錄_" + InsTargetData.sharedInstance().building + "_" + InsTargetData.sharedInstance().floor + "_" + InsTargetData.sharedInstance().room;
        } else {
            lblTitle.text = InsTargetData.sharedInstance().building + "_" + InsTargetData.sharedInstance().floor + "_" + InsTargetData.sharedInstance().room;
        }
		
		lblProjectName.text = projectName
		
        //init back button
        let btnBack = NaviTool.initBtnBack()
        btnBack.addTarget(self, action: #selector(btnBackPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(btnBack)
		
		//add vwOp corner and shadow
		vwOp0.layer.cornerRadius = 10;
		vwOp0.layer.masksToBounds = true;
		vwOp0.layer.shadowOffset = CGSize.init(width: 20, height: 20)
		vwOp0.layer.shadowColor = UIColor.black.cgColor
		vwOp0.layer.shadowOpacity = 0.5
		
		vwOp1.layer.cornerRadius = 10;
		vwOp1.layer.masksToBounds = true;
		vwOp1.layer.shadowOffset = CGSize.init(width: 20, height: 20)
		vwOp1.layer.shadowColor = UIColor.black.cgColor
		vwOp1.layer.shadowOpacity = 0.5
		
		vwOp2.layer.cornerRadius = 10;
		vwOp2.layer.masksToBounds = true;
		vwOp2.layer.shadowOffset = CGSize.init(width: 20, height: 20)
		vwOp2.layer.shadowColor = UIColor.black.cgColor
		vwOp2.layer.shadowOpacity = 0.5
		
		vwOp3.layer.cornerRadius = 10;
		vwOp3.layer.masksToBounds = true;
		vwOp3.layer.shadowOffset = CGSize.init(width: 0.5, height: 0.5)
		vwOp3.layer.shadowColor = UIColor.black.cgColor
		vwOp3.layer.shadowOpacity = 0.5
		
		vwStep1.layer.cornerRadius = 10;
		vwStep1.layer.masksToBounds = true;
		vwStep1.layer.shadowOffset = CGSize.init(width: 0.5, height: 0.5)
		vwStep1.layer.shadowColor = UIColor.black.cgColor
		vwStep1.layer.shadowOpacity = 0.5
		
		vwStep2.layer.cornerRadius = 10;
		vwStep2.layer.masksToBounds = true;
		vwStep2.layer.shadowOffset = CGSize.init(width: 0.5, height: 0.5)
		vwStep2.layer.shadowColor = UIColor.black.cgColor
		vwStep2.layer.shadowOpacity = 0.5
		
		vwStep1Inside.layer.cornerRadius = 10;
		vwStep1Inside.layer.masksToBounds = true;
		vwStep1Inside.layer.shadowOffset = CGSize.init(width: 0.5, height: 0.5)
		vwStep1Inside.layer.shadowColor = UIColor.black.cgColor
		vwStep1Inside.layer.shadowOpacity = 0.5
		
		vwStep2Inside.layer.cornerRadius = 10;
		vwStep2Inside.layer.masksToBounds = true;
		vwStep2Inside.layer.shadowOffset = CGSize.init(width: 0.5, height: 0.5)
		vwStep2Inside.layer.shadowColor = UIColor.black.cgColor
		vwStep2Inside.layer.shadowOpacity = 0.5
	}
	
	func initData() {
		do {
			let fileManager = FileManager.default
			let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
			let fileURL = documentDirectory.appendingPathComponent(SystemConstants.DBFileName)
			let projectsNo = UserDefaults.standard.string(forKey: "PROJECT_NO")
			let building = UserDefaults.standard.string(forKey: "BUILDING")
			let floor = UserDefaults.standard.string(forKey: "FLOOR")
            let room = UserDefaults.standard.string(forKey: "ROOM")
			let subFileURL = documentDirectory.appendingPathComponent(String.init(format: SystemConstants.DBFileNameSub, projectsNo!, building!))
			let db = try Connection(subFileURL.absoluteString)
			
			let table = Table("HomeProject_CheckFlowItem")
			let table_id = Expression<String?>("CheckFlowItemId")
			let table_elevel_2_1 = Expression<String?>("ELEVEL_2_1")
            let table_elevel_2_2 = Expression<String?>("ELEVEL_2_2")
			let table_elevel_1 = Expression<String?>("ELEVEL_1")
			let table_valid = Expression<String?>("IsValid")
			
			let table_sorting = Expression<String?>("Sorting")
			var query = table.select(table_id).filter(table_valid == "Y" && table_elevel_2_1 == building && (table_elevel_1 == floor || table_elevel_1 == "")  && (table_elevel_2_2 == room || table_elevel_2_2 == "") && table_id != nil).order(table_sorting.asc)
            var flowIdDataTmp:[String] = []
			for data in try db.prepare(query) {
                // 沒出來的忽略掉
				print("0 name: \(data[table_id]!)")
				flowIdDataTmp.append(data[table_id]!)
			}
			
			let dbMain = try Connection(fileURL.absoluteString)
			
            let table1 = Table("CheckFlowItem")
            let table_name = Expression<String?>("CheckFlowItemName")
            query = table1.select(table_name, table_id).order(table_sorting.asc)
            for data in try dbMain.prepare(query) {
                print("1 name: \(data[table_name]!)")
                for id in flowIdDataTmp {
                    if id == data[table_id]! {
                        flowIdData.append(data[table_id]!)
                        flowNameData.append(data[table_name]!)
                        break
                    }
                }
            }
            
			InsTmpDataManager.sharedInstance().flowIdData = flowIdData
			InsTmpDataManager.sharedInstance().flowNameData = flowNameData
			InsTmpDataManager.sharedInstance().dicArea["Add_DataArea"] = []
			InsTmpDataManager.sharedInstance().dicItem["Add_DataItem"] = NSMutableArray.init()
            let ProjectAreaMst = Table("ProjectAreaMst")
            let AreaFileUrl = Expression<String?>("AreaFileUrl")
            let AreaFileName = Expression<String?>("AreaFileName")
            let PlaneFileUrl = Expression<String?>("PlaneFileUrl")
            let PlaneFileName = Expression<String?>("PlaneFileName")
            
            query = ProjectAreaMst.select(AreaFileUrl, AreaFileName, PlaneFileUrl, PlaneFileName).filter(table_elevel_2_1 == building && table_elevel_1 == floor && table_elevel_2_2 == room)
            for data in try db.prepare(query) {
                if data[AreaFileUrl] != nil && data[AreaFileName] != nil && data[AreaFileUrl] != "" && data[AreaFileName] != "" {
                    areaPicName = data[AreaFileName]!
                    InsTmpDataManager.sharedInstance().areaPicName = areaPicName
                }
                if data[PlaneFileUrl] != nil && data[PlaneFileName] != nil && data[PlaneFileUrl] != "" && data[PlaneFileName] != "" {
                    print("*name: \(data[PlaneFileUrl]!) \(data[PlaneFileName]!)")
                    planePicName = data[PlaneFileName]!
                    InsTmpDataManager.sharedInstance().planePicName = planePicName
                }
            }
            if planePicName != "" {
                let fileManager = FileManager.default
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURL = documentDirectory.appendingPathComponent(planePicName)
                ivMap.image = UIImage(contentsOfFile: fileURL.path)
            }
		} catch {
			//handle error
			print(error)
		}
        
        for opId in flowIdData {
            if InsTargetData.sharedInstance().reinspection == "Y" {
                initFlowDataReinspection(opId)
            } else if InsTargetData.sharedInstance().reinspection == "ALL" {
                initFlowDataReinspectionAll(opId)
            }else {
                initFlowData(opId)
            }
        }
        
	}
	
    //MARK: Button Action
    @objc func btnBackPressed(sender: UIBarButtonItem) {
        if UserDefaults.standard.object(forKey: "ISRECORD") != nil {
            self.navigationController?.popViewController(animated: true)
            return
        }
		let alertController = UIAlertController(
			title: "提醒",
			message: "離開此頁面，將清除未儲存資料",
			preferredStyle: .alert)
		
		let okAction = UIAlertAction(title: "確定", style: .default) { (alertController) in
			self.navigationController?.popViewController(animated: true)
		}
		
		let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (alertController) in
		}
		alertController.addAction(cancelAction)
		alertController.addAction(okAction)
		self.present(
			alertController,
			animated: true,
			completion: nil)
    }
	
	@IBAction func btnPhotoPressed(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "請選擇查看圖檔", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("平面圖", comment: ""), style: .default) { _ in
            if self.planePicName != "" {
                do {
                    let fileManager = FileManager.default
                    let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                    let fileURLArea = documentDirectory.appendingPathComponent(self.areaPicName)
                    let imageArea = UIImage(contentsOfFile: fileURLArea.path)
                    let fileURLPlane = documentDirectory.appendingPathComponent(self.planePicName)
                    let imagePlane = UIImage(contentsOfFile: fileURLPlane.path)
                    var photos: [NYTPhoto] = []
                    let titleArea = NSAttributedString(string: "", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
                    let titlePlane = NSAttributedString(string: "", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
                    let photoArea = Photo.init(image:imageArea, attributedCaptionTitle: titleArea)
                    let photoPlane = Photo.init(image:imagePlane, attributedCaptionTitle: titlePlane)
                    photos.append(photoPlane)
                    photos.append(photoArea)
                    let photosViewController = NYTPhotosViewController(photos: photos)
                    photosViewController.display(photoPlane, animated: false)
                    self.present(photosViewController, animated: true, completion: nil)
                } catch {
                    
                }
            }
            
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("格局圖", comment: ""), style: .default) { _ in
            if self.areaPicName != "" {
                do {
                    let fileManager = FileManager.default
                    let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                    let fileURLArea = documentDirectory.appendingPathComponent(self.areaPicName)
                    let imageArea = UIImage(contentsOfFile: fileURLArea.path)
                    let fileURLPlane = documentDirectory.appendingPathComponent(self.planePicName)
                    let imagePlane = UIImage(contentsOfFile: fileURLPlane.path)
                    var photos: [NYTPhoto] = []
                    let titleArea = NSAttributedString(string: "", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
                    let titlePlane = NSAttributedString(string: "", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
                    let photoArea = Photo.init(image:imageArea, attributedCaptionTitle: titleArea)
                    let photoPlane = Photo.init(image:imagePlane, attributedCaptionTitle: titlePlane)
                    photos.append(photoPlane)
                    photos.append(photoArea)
                    let photosViewController = NYTPhotosViewController(photos: photos)
                    photosViewController.display(photoArea, animated: false)
                    self.present(photosViewController, animated: true, completion: nil)
                } catch {
                    
                }
            }
            
        })
        
        
        present(alert, animated: true, completion: nil)
	}
	
	@IBAction func btnOPPressed(_ sender: Any) {
		let button = sender as! UIButton
		let insDetectList0Controller = InsDetectList0Controller()
		insDetectList0Controller.projectName = projectName
		insDetectList0Controller.caseName = caseName
		insDetectList0Controller.opId = flowIdData[button.tag]
		insDetectList0Controller.opName = flowNameData[button.tag]
		self.navigationController?.pushViewController(insDetectList0Controller, animated: true)
	}
	
	@IBAction func btnOP2Pressed(_ sender: Any) {
		let insDetectList1Controller = InsDetectList1Controller()
		insDetectList1Controller.projectName = projectName
		insDetectList1Controller.caseName = caseName
		insDetectList1Controller.opName = "驗屋項目"
		self.navigationController?.pushViewController(insDetectList1Controller, animated: true)
	}
	
}

class Photo: NSObject, NYTPhoto {
	
	var image: UIImage?
	var imageData: Data?
	var placeholderImage: UIImage?
	let attributedCaptionTitle: NSAttributedString?
    let attributedCaptionSummary: NSAttributedString? = NSAttributedString(string: "", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
    let attributedCaptionCredit: NSAttributedString? = NSAttributedString(string: "", attributes: [NSAttributedStringKey.foregroundColor: UIColor.darkGray])
	
	init(image: UIImage? = nil, attributedCaptionTitle: NSAttributedString) {
		self.image = image
		self.attributedCaptionTitle = attributedCaptionTitle
		super.init()
	}
	
}

func initFlowData(_ opId:String) {
    var dataArea = [] as [InsAreaItem]
    do {
        let fileManager = FileManager.default
        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        let mainFileURL = documentDirectory.appendingPathComponent(SystemConstants.DBFileName)
        let projectsNo = UserDefaults.standard.string(forKey: "PROJECT_NO")
        let building = UserDefaults.standard.string(forKey: "BUILDING")
        let floor = UserDefaults.standard.string(forKey: "FLOOR")
        let room = UserDefaults.standard.string(forKey: "ROOM")
        let subFileURL = documentDirectory.appendingPathComponent(String.init(format: SystemConstants.DBFileNameSub, projectsNo!, building!))
        let db = try Connection(subFileURL.absoluteString)
        
        let CheckFlowItem_InspItem = Table("CheckFlowItem_InspItem")
        let ChkInspIdx = Expression<String?>("ChkInspIdx")
        let CheckFlowItemId = Expression<String?>("CheckFlowItemId")
        let ELEVEL_2_1 = Expression<String?>("ELEVEL_2_1")
        let ELEVEL_2_2 = Expression<String?>("ELEVEL_2_2")
        let ELEVEL_1 = Expression<String?>("ELEVEL_1")
        let AreaId = Expression<String?>("AreaId")
        let InspItemId = Expression<String?>("InspItemId")
        let Sorting = Expression<String?>("Sorting")
        let EquipAmount = Expression<String?>("EquipAmount")
        let AreaItem = Table("AreaItem")
        let AreaName = Expression<String?>("AreaName")
        
        let query = CheckFlowItem_InspItem.select(distinct:AreaId).filter(CheckFlowItemId == opId && ELEVEL_2_1 == building && (ELEVEL_2_2 == room || ELEVEL_2_2 == "") && (ELEVEL_1 == floor || ELEVEL_1 == "")).order(Sorting.asc)
        let dbMain = try Connection(mainFileURL.absoluteString)
        var dataAreaTmp:[InsAreaItem] = []
        for data in try db.prepare(query) {
            print("name: \(data[AreaId]!)")
            let insAreaItem = InsAreaItem.init()
            insAreaItem.idx = data[AreaId]!
            dataAreaTmp.append(insAreaItem)
        }
        
        let queryAreaName = AreaItem.select(AreaId, AreaName).order(Sorting.asc)
        for data in try dbMain.prepare(queryAreaName) {
            print("*name: \(data[AreaName]!)")
            for insAreaItem in dataAreaTmp {
                if insAreaItem.idx == data[AreaId]! {
                    insAreaItem.name = data[AreaName]!
                    dataArea.append(insAreaItem)
                    break
                }
            }
        }
        
        for insAreaItem in dataArea {
            let query = CheckFlowItem_InspItem.select(distinct:InspItemId, ChkInspIdx, EquipAmount).filter(CheckFlowItemId == opId && AreaId == insAreaItem.idx && ELEVEL_2_1 == building && (ELEVEL_2_2 == room || ELEVEL_2_2 == "") && (ELEVEL_1 == floor || ELEVEL_1 == "")).order(Sorting.asc)
            for insData in try db.prepare(query) {
                print("id: \(insData[InspItemId]!)")
                let InspItem = Table("InspItem")
                let InspItemName = Expression<String?>("InspItemName")
                let query = InspItem.select(InspItemName).filter(InspItemId == insData[InspItemId]).order(Sorting.asc)
                for data in try dbMain.prepare(query) {
                    print("name: \(data[InspItemName]!)")
                    let insItem = InsItem.init()
                    insItem.fkIdx = insData[ChkInspIdx]!
                    insItem.amount = insData[EquipAmount]!
                    insItem.areaId = insAreaItem.idx
                    insItem.checkFlowItemId = opId
                    insItem.inspItemId = insData[InspItemId]!
                    insItem.name = data[InspItemName]!
                    insItem.detect_amount = Int(insItem.amount) ?? 0
                    insAreaItem.items.append(insItem)
                }
            }
        }
    } catch {
        //handle error
        print(error)
    }
    InsTmpDataManager.sharedInstance().dicArea[opId + "_DataArea"] = dataArea
}

func initFlowDataReinspection(_ opId:String) {
    var dataArea = [] as [InsAreaItem]
    do {
        let fileManager = FileManager.default
        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        let mainFileURL = documentDirectory.appendingPathComponent(SystemConstants.DBFileName)
        let projectsNo = UserDefaults.standard.string(forKey: "PROJECT_NO")
        let building = UserDefaults.standard.string(forKey: "BUILDING")
        let floor = UserDefaults.standard.string(forKey: "FLOOR")
        let room = UserDefaults.standard.string(forKey: "ROOM")
        let subFileURL = documentDirectory.appendingPathComponent(String.init(format: SystemConstants.DBFileNameSub, projectsNo!, building!))
        let db = try Connection(subFileURL.absoluteString)
        let targetChkNo = String(Int(InsTargetData.sharedInstance().inspNo)! - 1)
        
        let InspCheckFlowDetail = Table("InspCheckFlowDetail")
        let CheckFlowItem_InspItem = Table("CheckFlowItem_InspItem")
        let ChkInspIdx = Expression<String?>("ChkInspIdx")
        let CheckFlowItemId = Expression<String?>("CheckFlowItemId")
        let ELEVEL_2_1 = Expression<String?>("ELEVEL_2_1")
        let ELEVEL_2_2 = Expression<String?>("ELEVEL_2_2")
        let ELEVEL_1 = Expression<String?>("ELEVEL_1")
        let AreaId = Expression<String?>("AreaId")
        let InspItemId = Expression<String?>("InspItemId")
        let Sorting = Expression<String?>("Sorting")
        let EquipAmount = Expression<String?>("EquipAmount")
        let AreaItem = Table("AreaItem")
        let AreaName = Expression<String?>("AreaName")
        let IsValid = Expression<String?>("IsValid")
        let ChkNo = Expression<String?>("ChkNo")
        let Result = Expression<String?>("Result")
        let dbMain = try Connection(mainFileURL.absoluteString)
        let InspItem = Table("InspItem")
        let InspItemName = Expression<String?>("InspItemName")
        
        let query = InspCheckFlowDetail.select(distinct:AreaId).filter(CheckFlowItemId == opId && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && Result == "N" && IsValid == "Y" && ChkNo == targetChkNo)
        var dataAreaTmp:[InsAreaItem] = []
        for data in try db.prepare(query) {
            print("name: \(data[AreaId]!)")
            let insAreaItem = InsAreaItem.init()
            insAreaItem.idx = data[AreaId]!
            dataAreaTmp.append(insAreaItem)
        }
        
        let queryAreaName = AreaItem.select(AreaId, AreaName).order(Sorting.asc)
        for data in try dbMain.prepare(queryAreaName) {
            print("*name: \(data[AreaName]!)")
            for insAreaItem in dataAreaTmp {
                if insAreaItem.idx == data[AreaId]! {
                    insAreaItem.name = data[AreaName]!
                    dataArea.append(insAreaItem)
                    break
                }
            }
        }
        
        for insAreaItem in dataArea {
            
            let query = InspCheckFlowDetail.select(distinct:ChkInspIdx).filter(CheckFlowItemId == opId && AreaId == insAreaItem.idx && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && Result == "N" && IsValid == "Y" && ChkNo == targetChkNo).order(Sorting.asc)
            for insData in try db.prepare(query) {
                print("id: \(insData[ChkInspIdx]!)")
                
                let queryItemId = CheckFlowItem_InspItem.select(InspItemId, EquipAmount).filter(ChkInspIdx == insData[ChkInspIdx]).order(Sorting.asc)
                for data in try db.prepare(queryItemId) {
                    print("name: \(data[InspItemId]!)")
                    let insItem = InsItem.init()
                    insItem.fkIdx = insData[ChkInspIdx]!
                    insItem.amount = data[EquipAmount]!
                    insItem.detect_amount = Int(insItem.amount) ?? 0
                    insItem.areaId = insAreaItem.idx
                    insItem.checkFlowItemId = opId
                    insItem.inspItemId = data[InspItemId]!
                    let queryName = InspItem.select(InspItemName).filter(InspItemId == data[InspItemId]).order(Sorting.asc)
                    for dataName in try dbMain.prepare(queryName) {
                        print("name: \(dataName[InspItemName]!)")
                        insItem.name = dataName[InspItemName]!
                    }
                    insAreaItem.items.append(insItem)
                }
            }
        }
    } catch {
        //handle error
        print(error)
    }
    InsTmpDataManager.sharedInstance().dicArea[opId + "_DataArea"] = dataArea
}

func initFlowDataReinspectionAll(_ opId:String) {
    var dataArea = [] as [InsAreaItem]
    do {
        let fileManager = FileManager.default
        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        let mainFileURL = documentDirectory.appendingPathComponent(SystemConstants.DBFileName)
        let projectsNo = UserDefaults.standard.string(forKey: "PROJECT_NO")
        let building = UserDefaults.standard.string(forKey: "BUILDING")
        let floor = UserDefaults.standard.string(forKey: "FLOOR")
        let room = UserDefaults.standard.string(forKey: "ROOM")
        let subFileURL = documentDirectory.appendingPathComponent(String.init(format: SystemConstants.DBFileNameSub, projectsNo!, building!))
        let db = try Connection(subFileURL.absoluteString)
        
        let subFileURLUpload = documentDirectory.appendingPathComponent(String.init(format: SystemConstants.DBFileNameSubUpload, projectsNo!, building!))
        let dbUpload = try Connection(subFileURLUpload.absoluteString)
        let targetChkNo = InsTargetData.sharedInstance().inspNo
        
        let InspCheckFlowDetail = Table("InspCheckFlowDetail")
        let CheckFlowItem_InspItem = Table("CheckFlowItem_InspItem")
        let ChkInspIdx = Expression<String?>("ChkInspIdx")
        let CheckFlowItemId = Expression<String?>("CheckFlowItemId")
        let ELEVEL_2_1 = Expression<String?>("ELEVEL_2_1")
        let ELEVEL_2_2 = Expression<String?>("ELEVEL_2_2")
        let ELEVEL_1 = Expression<String?>("ELEVEL_1")
        let AreaId = Expression<String?>("AreaId")
        let InspItemId = Expression<String?>("InspItemId")
        let Sorting = Expression<String?>("Sorting")
        let EquipAmount = Expression<String?>("EquipAmount")
        let AreaItem = Table("AreaItem")
        let AreaName = Expression<String?>("AreaName")
        let IsValid = Expression<String?>("IsValid")
        let ChkNo = Expression<String?>("ChkNo")
        let Result = Expression<String?>("Result")
        let EquipFailType = Expression<String?>("EquipFailType")
        let dbMain = try Connection(mainFileURL.absoluteString)
        let InspItem = Table("InspItem")
        let InspItemName = Expression<String?>("InspItemName")
        let InspDescItemId = Expression<String?>("InspDescItemId")
        let InspRemark = Expression<String?>("InspRemark")
        let EquipFailLessAmount = Expression<String?>("EquipFailLessAmount")
        
        
        let query = InspCheckFlowDetail.select(distinct:AreaId).filter(CheckFlowItemId == opId && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && IsValid == "Y" && ChkNo == targetChkNo)
        var dataAreaTmp:[InsAreaItem] = []
        for data in try dbUpload.prepare(query) {
            print("name: \(data[AreaId]!)")
            let insAreaItem = InsAreaItem.init()
            insAreaItem.idx = data[AreaId]!
            dataAreaTmp.append(insAreaItem)
        }
        
        let queryAreaName = AreaItem.select(AreaId, AreaName).order(Sorting.asc)
        for data in try dbMain.prepare(queryAreaName) {
            print("*name: \(data[AreaName]!)")
            for insAreaItem in dataAreaTmp {
                if insAreaItem.idx == data[AreaId]! {
                    insAreaItem.name = data[AreaName]!
                    dataArea.append(insAreaItem)
                    break
                }
            }
        }
        
        for insAreaItem in dataArea {
            let queryAreaName = AreaItem.select(AreaName).filter(AreaId == insAreaItem.idx).order(Sorting.asc)
            for data in try dbMain.prepare(queryAreaName) {
                print("*name: \(data[AreaName]!)")
                insAreaItem.name = data[AreaName]!
            }
            
            let query = InspCheckFlowDetail.select(ChkInspIdx, Result, EquipFailType, InspDescItemId, EquipFailLessAmount, InspRemark).filter(CheckFlowItemId == opId && AreaId == insAreaItem.idx && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && IsValid == "Y" && ChkNo == targetChkNo).order(Sorting.asc)
            for insData in try dbUpload.prepare(query) {
                print("id: \(insData[ChkInspIdx]!)")
                
                let queryItemId = CheckFlowItem_InspItem.select(InspItemId, EquipAmount).filter(ChkInspIdx == insData[ChkInspIdx]).order(Sorting.asc)
                for data in try db.prepare(queryItemId) {
                    print("name: \(data[InspItemId]!)")
                    let insItem = InsItem.init()
                    insItem.fkIdx = insData[ChkInspIdx]!
                    insItem.amount = data[EquipAmount]!
                    insItem.detect_amount = Int(insItem.amount) ?? 0
                    insItem.areaId = insAreaItem.idx
                    insItem.checkFlowItemId = opId
                    if insData[EquipFailLessAmount] != nil {
                        insItem.detect_amount = Int(insData[EquipFailLessAmount]!)!
                    }
                    if insData[InspRemark] != nil {
                        insItem.inspRemark = insData[InspRemark]!
                    }
                    if insData[InspDescItemId] != nil {
                        insItem.desId = insData[InspDescItemId]!
                        insItem.inspDescItemId = insData[InspDescItemId]!
                        let table = Table("InspDescItem")
                        let table_inspDescItemId = Expression<String?>("InspDescItemId")
                        let table_inspDescItemName = Expression<String?>("InspDescItemName")
                        let queryDesName = table.select(table_inspDescItemName).filter(table_inspDescItemId == insData[InspDescItemId]!).order(Sorting.asc)
                        for data in try dbMain.prepare(queryDesName) {
                            insItem.desName = data[table_inspDescItemName]!
                        }
                    }
                    
                    if insData[EquipFailType] != nil {
                        if insData[EquipFailType]! == "1" {
                            insItem.status = 1
                        } else {
                            insItem.status = 0
                        }
                    }
                    insItem.inspItemId = data[InspItemId]!
                    insItem.check = false
                    if insData[Result] != nil {
                        if insData[Result] == "N" {
                            insItem.result = 1
                            insItem.check = true
                        } else if insData[Result] == "Y" {
                            insItem.result = 0
                            insItem.check = true
                        } 
                    }
                    let queryName = InspItem.select(InspItemName).filter(InspItemId == data[InspItemId]).order(Sorting.asc)
                    for dataName in try dbMain.prepare(queryName) {
                        print("name: \(dataName[InspItemName]!)")
                        insItem.name = dataName[InspItemName]!
                    }
                    
                    let InspCheckFlowUploadFile = Table("InspCheckFlowUploadFile")
                    let FileType = Expression<String?>("FileType")
                    let FileName = Expression<String?>("FileName")
                    let FileUrl = Expression<String?>("FileUrl")
                    let queryImg = InspCheckFlowUploadFile.select(FileName, FileUrl).filter(CheckFlowItemId == opId && AreaId == insAreaItem.idx && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && ChkNo == targetChkNo && ChkInspIdx == insItem.fkIdx && FileType == "B").order(Sorting.asc)
                    for dataImgName in try db.prepare(queryImg) {
                        print("name: \(dataImgName[FileName]!)")
                        insItem.picUrl = dataImgName[FileName]!
                    }
                    insAreaItem.items.append(insItem)
                }
            }
        }
    } catch {
        //handle error
        print(error)
    }
    InsTmpDataManager.sharedInstance().dicArea[opId + "_DataArea"] = dataArea
}

