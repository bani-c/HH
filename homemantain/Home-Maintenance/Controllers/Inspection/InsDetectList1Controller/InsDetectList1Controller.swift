//
//  ViewController.swift
//  Home-Maintenance
//
//  Created by Bani on 14/09/2017.
//  Copyright © 2017 Ultron mobile. All rights reserved.
//

import UIKit
import SQLite
import NYTPhotoViewer

class InsDetectList1Controller: UIViewController, UITableViewDelegate, UITableViewDataSource, CameraControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var btnAddMistake: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var ivBig: UIImageView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
	@IBOutlet weak var lblProjectName: UILabel!
	@IBOutlet weak var tableViewArea: UITableView!
	@IBOutlet weak var tableViewItem: UITableView!
    @IBOutlet weak var ivMap: UIImageView!
	public var opName: String!
	public var caseName: String!
	public var projectName: String!
	var dataArea = [] as [InsAreaItem]
    var dataPlace = NSMutableArray.init()
	var dataItem = NSMutableArray.init()
	var areaIndex = 0
	var targetItem:InsItem!

    static func prepareDataForSavingIfNeeded() {
        let dataManager = InsTmpDataManager.sharedInstance()
        guard dataManager.dicArea["Ins_DataArea"] == nil else {
            return
        }

        let controller = InsDetectList1Controller()
        controller.loadViewIfNeeded()
        if InsTargetData.sharedInstance().reinspection == "Y" {
            controller.initDataReinspection()
        } else if InsTargetData.sharedInstance().reinspection == "ALL" {
            controller.initDataReinspectionAll()
        } else {
            controller.initData()
        }
    }
	
	// MARK: Life Circle
	override func viewDidLoad() {
		super.viewDidLoad()
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initLayaout()
    }

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: Custom Functions
	func initLayaout() {
		if getLocalData() == false{
			if InsTargetData.sharedInstance().reinspection == "Y" {
				initDataReinspection()
			} else if InsTargetData.sharedInstance().reinspection == "ALL" {
                initDataReinspectionAll()
            } else {
				initData()
			}
        } else {
            tableViewArea.reloadData()
            tableViewItem.reloadData()
        }

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(longPressGestureRecognizer:)))
        self.tableViewItem.addGestureRecognizer(longPressRecognizer)
		
		//set title
        lblTitle.text = InsTargetData.sharedInstance().displayTitle
        if UserDefaults.standard.object(forKey: "ISRECORD") != nil {
            self.btnNext.isHidden = true
        }
		lblProjectName.text = projectName
		
		//register nib
		tableViewArea.register(UINib(nibName: "InsDetect0CategoryCell", bundle: nil), forCellReuseIdentifier: "InsDetect0CategoryCell")
		tableViewItem.register(UINib(nibName: "InsDetect0HeaderCell", bundle: nil), forCellReuseIdentifier: "InsDetect0HeaderCell")
		tableViewItem.register(UINib(nibName: "InsDetect0ItemCell", bundle: nil), forCellReuseIdentifier: "InsDetect0ItemCell")
		
        //init back button
        let btnBack = NaviTool.initBtnBack()
        btnBack.addTarget(self, action: #selector(btnBackPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(btnBack)
        
        if InsTmpDataManager.sharedInstance().areaPicName  != "" {
            do {
                let fileManager = FileManager.default
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURL = documentDirectory.appendingPathComponent(InsTmpDataManager.sharedInstance().areaPicName )
                ivMap.image = UIImage(contentsOfFile: fileURL.path)
                ivBig.image = UIImage(contentsOfFile: fileURL.path)
            } catch {
                
            }
        }
		
	}
    
    @IBAction func clickMap(_ sender: Any) {
        if InsTmpDataManager.sharedInstance().planePicName != "" {
            do {
                let fileManager = FileManager.default
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURLPlane = documentDirectory.appendingPathComponent(InsTmpDataManager.sharedInstance().areaPicName)
                let imageArea = UIImage(contentsOfFile: fileURLPlane.path)
                var photos: [NYTPhoto] = []
                let titleArea = NSAttributedString(string: "", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
                let photoArea = Photo.init(image:imageArea, attributedCaptionTitle: titleArea)
                photos.append(photoArea)
                let photosViewController = NYTPhotosViewController(photos: photos)
                self.present(photosViewController, animated: true, completion: nil)
            } catch {
                
            }
        }
    }
	
	func saveLocalData() {
		InsTmpDataManager.sharedInstance().dicArea["Ins_DataArea"] = dataArea
		//InsTmpDataManager.sharedInstance().dicItem["Ins_DataItem"] = dataItem
	}
	
	func getLocalData() -> Bool {
		if InsTmpDataManager.sharedInstance().dicArea["Ins_DataArea"] != nil {
			dataArea = InsTmpDataManager.sharedInstance().dicArea["Ins_DataArea"]!
			//dataItem = InsTmpDataManager.sharedInstance().dicItem["Ins_DataItem"]!
			return true
		}
		return false
	}
	
	func initData() {
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
			
			let InspPlaceItem_InspItem = Table("InspPlaceItem_InspItem")
			let ProjInspIdx = Expression<String?>("ProjInspIdx")
			let ELEVEL_2_1 = Expression<String?>("ELEVEL_2_1")
            let ELEVEL_2_2 = Expression<String?>("ELEVEL_2_2")
			let ELEVEL_1 = Expression<String?>("ELEVEL_1")
			let AreaId = Expression<String?>("AreaId")
            let InspPlaceId = Expression<String?>("InspPlaceId")
			let InspItemId = Expression<String?>("InspItemId")
			let Sorting = Expression<String?>("Sorting")
            
			let query = InspPlaceItem_InspItem.select(distinct:AreaId).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && (ELEVEL_1 == floor || ELEVEL_1 == nil)).order(Sorting.asc)
			let dbMain = try Connection(mainFileURL.absoluteString)
            
            var dataAreaTmp:[InsAreaItem] = []
            for data in try db.prepare(query) {
                print("name: \(data[AreaId] ?? "")")
                let insAreaItem = InsAreaItem.init()
                insAreaItem.idx = data[AreaId] ?? ""
                insAreaItem.type = 1
                dataAreaTmp.append(insAreaItem)
            }
            let AreaItem = Table("AreaItem")
            let AreaName = Expression<String?>("AreaName")
            
            let queryAreaName = AreaItem.select(AreaId, AreaName).order(Sorting.asc)
            for data in try dbMain.prepare(queryAreaName) {
                print("*name: \(data[AreaName] ?? "")")
                for insAreaItem in dataAreaTmp {
                    if insAreaItem.idx == data[AreaId] ?? "" {
                        insAreaItem.name = data[AreaName]!
                        dataArea.append(insAreaItem)
                        break
                    }
                }
            }
            
            
            let InspPlaceItem = Table("InspPlaceItem")
            let InspPlaceName = Expression<String?>("InspPlaceName")
            let InspItem = Table("InspItem")
            let InspItemName = Expression<String?>("InspItemName")
            let CheckEquipType = Expression<String?>("CheckEquipType")
            let EquipAmount = Expression<String?>("EquipAmount")
            
            for insAreaItem in dataArea {
                
                let queryPlace = InspPlaceItem_InspItem.select(distinct:InspPlaceId).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && (ELEVEL_1 == floor || ELEVEL_1 == nil) && AreaId == insAreaItem.idx).order(Sorting.asc)
                for data in try db.prepare(queryPlace) {
                    print("  name: \(data[InspPlaceId]!)")
                    let insPlaceItem = InsPlaceItem.init()
                    insPlaceItem.idx = data[InspPlaceId]!
                    insAreaItem.places.append(insPlaceItem)
                }
                
                for insPlaceItem in insAreaItem.places {
                    let queryPlaceName = InspPlaceItem.select(InspPlaceName).filter(InspPlaceId == insPlaceItem.idx).order(Sorting.asc)
                    for data in try dbMain.prepare(queryPlaceName) {
                        print("*name: \(data[InspPlaceName]!)")
                        insPlaceItem.name = data[InspPlaceName]!
                    }
                    let queryItem = InspPlaceItem_InspItem.select(InspItemId, ProjInspIdx, CheckEquipType, EquipAmount).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && (ELEVEL_1 == floor || ELEVEL_1 == nil) && AreaId == insAreaItem.idx && InspPlaceId == insPlaceItem.idx).order(Sorting.asc)
                    for data in try db.prepare(queryItem) {
                        print("  name: \(data[InspItemId]!)")
                        let insItem = InsItem.init()
                        insItem.idx = data[InspItemId]!
                        insItem.fkIdx = data[ProjInspIdx]!
                        insItem.CheckEquipType = data[CheckEquipType] ?? "1"
                        insItem.amount = data[EquipAmount] ?? "0"
                        insItem.areaId = insAreaItem.idx
                        insItem.placeId = insPlaceItem.idx
                        insPlaceItem.items.append(insItem)
                    }
                    
                    for insItem in insPlaceItem.items {
                        
                        let queryItemName = InspItem.select(InspItemName).filter(InspItemId == insItem.idx).order(Sorting.asc)
                        for data in try dbMain.prepare(queryItemName) {
                            print("***name: \(data[InspItemName]!)")
                            insItem.name = data[InspItemName]!
                        }
                    }
                    
                }
            }
		} catch {
			//handle error
			print(error)
		}
        tableViewArea.reloadData()
        tableViewItem.reloadData()
		saveLocalData()
	}
	
	func initDataReinspection() {
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
			let dbMain = try Connection(mainFileURL.absoluteString)

            let ChkNo = Expression<String?>("ChkNo")
			let ELEVEL_2_1 = Expression<String?>("ELEVEL_2_1")
            let ELEVEL_2_2 = Expression<String?>("ELEVEL_2_2")
			let ELEVEL_1 = Expression<String?>("ELEVEL_1")
			let IsValid = Expression<String?>("IsValid")
			let Sorting = Expression<String?>("Sorting")
			let Result = Expression<String?>("Result")
			let AreaId = Expression<String?>("AreaId")
            let InspItemId = Expression<String?>("InspItemId")
			let targetChkNo = String(Int(InsTargetData.sharedInstance().inspNo)! - 1)
            
			//general data
			let InspDetail = Table("InspDetail")
			let InspPlaceId = Expression<String?>("InspPlaceId")
			let ProjInspIdx = Expression<String?>("ProjInspIdx")
            
            let query = InspDetail.select(distinct:AreaId).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && Result == "N" && IsValid == "Y" && ChkNo == targetChkNo)
            
            var dataAreaTmp:[InsAreaItem] = []
            for data in try db.prepare(query) {
                print("name: \(data[AreaId]!)")
                let insAreaItem = InsAreaItem.init()
                insAreaItem.idx = data[AreaId]!
                insAreaItem.type = 1
                dataAreaTmp.append(insAreaItem)
            }
            let AreaItem = Table("AreaItem")
            let AreaName = Expression<String?>("AreaName")
            
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
            
            let InspPlaceItem = Table("InspPlaceItem")
            let InspPlaceName = Expression<String?>("InspPlaceName")
            let InspItem = Table("InspItem")
            let InspItemName = Expression<String?>("InspItemName")
            let InspDescItemId = Expression<String?>("InspDescItemId")
            let InspRemark = Expression<String?>("InspRemark")
            let SeqNo = Expression<String?>("SeqNo")
            let InspPlaceItem_InspItem = Table("InspPlaceItem_InspItem")
            let CheckEquipType = Expression<String?>("CheckEquipType")
            let EquipAmount = Expression<String?>("EquipAmount")
       
            for insAreaItem in dataArea {
                let queryPlace = InspDetail.select(distinct:InspPlaceId).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && Result == "N" && IsValid == "Y" && ChkNo == targetChkNo && AreaId == insAreaItem.idx).order(Sorting.asc)
                for data in try db.prepare(queryPlace) {
                    print("  name: \(data[InspPlaceId]!)")
                    let insPlaceItem = InsPlaceItem.init()
                    insPlaceItem.idx = data[InspPlaceId]!
                    insAreaItem.places.append(insPlaceItem)
                }
                
                for insPlaceItem in insAreaItem.places {
                    let queryPlaceName = InspPlaceItem.select(InspPlaceName).filter(InspPlaceId == insPlaceItem.idx).order(Sorting.asc)
                    for data in try dbMain.prepare(queryPlaceName) {
                        print("*name: \(data[InspPlaceName]!)")
                        insPlaceItem.name = data[InspPlaceName]!
                    }
                    
                    let queryItem = InspDetail.select(InspDescItemId, InspRemark, SeqNo, ProjInspIdx).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && Result == "N" && IsValid == "Y" && ChkNo == targetChkNo && AreaId == insAreaItem.idx && InspPlaceId == insPlaceItem.idx).order(Sorting.asc)
                    for data in try db.prepare(queryItem) {
                        
                        let insItem = InsItem.init()
                        if data[SeqNo] != nil {
                           insItem.seqNo = data[SeqNo]!
                        }
                        if data[InspRemark] != nil {
                            insItem.inspRemark = data[InspRemark]!
                        }
                        if data[InspDescItemId] != nil {
                            insItem.desId = data[InspDescItemId]!
                            insItem.inspDescItemId = data[InspDescItemId]!
                            let table = Table("InspDescItem")
                            let table_inspDescItemId = Expression<String?>("InspDescItemId")
                            let table_inspDescItemName = Expression<String?>("InspDescItemName")
                            let queryDesName = table.select(table_inspDescItemName).filter(table_inspDescItemId == data[InspDescItemId]!).order(Sorting.asc)
                            for data in try dbMain.prepare(queryDesName) {
                                insItem.name = data[table_inspDescItemName]!
                                insItem.desName = data[table_inspDescItemName]!
                            }
                        }
                        if data[ProjInspIdx] == nil {
                            insItem.fkIdx = ""
                        } else {
                            insItem.fkIdx = data[ProjInspIdx]!
                        }
                        
                        insItem.areaId = insAreaItem.idx
                        insItem.placeId = insPlaceItem.idx
                        insPlaceItem.items.append(insItem)
                    }
                    
                    for insItem in insPlaceItem.items {
                        let queryItemId = InspPlaceItem_InspItem.select(InspItemId, CheckEquipType, EquipAmount).filter(ProjInspIdx == insItem.fkIdx).order(Sorting.asc)
                        for data in try db.prepare(queryItemId) {
                            print("***name: \(data[InspItemId]!)")
                            insItem.idx = data[InspItemId]!
                            if data[CheckEquipType] != nil {
                                insItem.CheckEquipType = data[CheckEquipType]!
                            }  else {
                                insItem.CheckEquipType = "0"
                            }
                            if data[EquipAmount] != nil {
                                insItem.amount = data[EquipAmount]!
                            }  else {
                                insItem.amount = "0"
                            }
                        }
                        let queryItemName = InspItem.select(InspItemName).filter(InspItemId == insItem.idx).order(Sorting.asc)
                        for data in try dbMain.prepare(queryItemName) {
                            print("***name: \(data[InspItemName]!)")
                            insItem.name = data[InspItemName]!
                        }
                    }
                }
            }
		} catch {
			//handle error
			print(error)
		}
        tableViewArea.reloadData()
        tableViewItem.reloadData()
		saveLocalData()
	}
    
    func initDataReinspectionAll() {
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
            let dbMain = try Connection(mainFileURL.absoluteString)
            let subFileURLUpload = documentDirectory.appendingPathComponent(String.init(format: SystemConstants.DBFileNameSubUpload, projectsNo!, building!))
            let dbUpload = try Connection(subFileURLUpload.absoluteString)
            
            let ChkNo = Expression<String?>("ChkNo")
            let ELEVEL_2_1 = Expression<String?>("ELEVEL_2_1")
            let ELEVEL_2_2 = Expression<String?>("ELEVEL_2_2")
            let ELEVEL_1 = Expression<String?>("ELEVEL_1")
            let IsValid = Expression<String?>("IsValid")
            let Sorting = Expression<String?>("Sorting")
            let Result = Expression<String?>("Result")
            let AreaId = Expression<String?>("AreaId")
            let InspItemId = Expression<String?>("InspItemId")
            let targetChkNo = InsTargetData.sharedInstance().inspNo
            
            //general data
            let InspDetail = Table("InspDetail")
            let InspPlaceId = Expression<String?>("InspPlaceId")
            let ProjInspIdx = Expression<String?>("ProjInspIdx")
            
            let query = InspDetail.select(distinct:AreaId).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && IsValid == "Y" && ChkNo == targetChkNo)
            var dataAreaTmp:[InsAreaItem] = []
            for data in try dbUpload.prepare(query) {
                print("name: \(data[AreaId]!)")
                let insAreaItem = InsAreaItem.init()
                insAreaItem.idx = data[AreaId]!
                insAreaItem.type = 1
                dataAreaTmp.append(insAreaItem)
            }
            let AreaItem = Table("AreaItem")
            let AreaName = Expression<String?>("AreaName")
            
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
            
            let InspPlaceItem = Table("InspPlaceItem")
            let InspPlaceName = Expression<String?>("InspPlaceName")
            let InspItem = Table("InspItem")
            let InspItemName = Expression<String?>("InspItemName")
            let InspDescItemId = Expression<String?>("InspDescItemId")
            let InspRemark = Expression<String?>("InspRemark")
            let SeqNo = Expression<String?>("SeqNo")
            let InspPlaceItem_InspItem = Table("InspPlaceItem_InspItem")
            let CheckEquipType = Expression<String?>("CheckEquipType")
            let EquipFailLessAmount = Expression<String?>("EquipFailLessAmount")
            let EquipAmount = Expression<String?>("EquipAmount")
            
            for insAreaItem in dataArea {
                let queryAreaName = AreaItem.select(AreaName).filter(AreaId == insAreaItem.idx).order(Sorting.asc)
                for data in try dbMain.prepare(queryAreaName) {
                    print("*name: \(data[AreaName]!)")
                    insAreaItem.name = data[AreaName]!
                }
                
                let queryPlace = InspDetail.select(distinct:InspPlaceId).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && IsValid == "Y" && ChkNo == targetChkNo && AreaId == insAreaItem.idx).order(Sorting.asc)
                for data in try dbUpload.prepare(queryPlace) {
                    print("  name: \(data[InspPlaceId]!)")
                    let insPlaceItem = InsPlaceItem.init()
                    insPlaceItem.idx = data[InspPlaceId]!
                    insAreaItem.places.append(insPlaceItem)
                }
                
                for insPlaceItem in insAreaItem.places {
                    let queryPlaceName = InspPlaceItem.select(InspPlaceName).filter(InspPlaceId == insPlaceItem.idx).order(Sorting.asc)
                    for data in try dbMain.prepare(queryPlaceName) {
                        print("*name: \(data[InspPlaceName]!)")
                        insPlaceItem.name = data[InspPlaceName]!
                    }
                    
                    let queryItem = InspDetail.select(InspDescItemId, InspRemark, SeqNo, ProjInspIdx, Result, CheckEquipType, EquipFailLessAmount).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && IsValid == "Y" && ChkNo == targetChkNo && AreaId == insAreaItem.idx && InspPlaceId == insPlaceItem.idx).order(Sorting.asc)
                    for data in try dbUpload.prepare(queryItem) {
                        
                        let insItem = InsItem.init()
                        if data[SeqNo] != nil {
                            insItem.seqNo = data[SeqNo]!
                        } else {
                            insItem.seqNo = ""
                        }
                        if data[InspRemark] != nil {
                            insItem.inspRemark = data[InspRemark]!
                        }  else {
                            insItem.inspRemark = ""
                        }
                        if data[CheckEquipType] != nil {
                            insItem.CheckEquipType = data[CheckEquipType]!
                        }  else {
                            insItem.CheckEquipType = "1"
                        }
                        
                        if data[EquipFailLessAmount] != nil {
                            insItem.detect_amount = Int(data[EquipFailLessAmount]!)!
                        }  else {
                            insItem.detect_amount = Int(insItem.amount) ?? 0
                        }
                        
                        insItem.check = false
                        if data[Result] != nil {
                            if data[Result] == "N" {
                                insItem.result = 1
                                insItem.check = true
                            } else if data[Result] == "Y" {
                                insItem.result = 0
                                insItem.check = true
                            }
                        }
                        if data[InspDescItemId] != nil {
                            insItem.desId = data[InspDescItemId]!
                            insItem.inspDescItemId = data[InspDescItemId]!
                            let table = Table("InspDescItem")
                            let table_inspDescItemId = Expression<String?>("InspDescItemId")
                            let table_inspDescItemName = Expression<String?>("InspDescItemName")
                            let queryDesName = table.select(table_inspDescItemName).filter(table_inspDescItemId == data[InspDescItemId]!).order(Sorting.asc)
                            for data in try dbMain.prepare(queryDesName) {
                                insItem.name = data[table_inspDescItemName]!
                                insItem.desName = data[table_inspDescItemName]!
                            }
                        }
                        if data[ProjInspIdx] == nil {
                            insItem.fkIdx = ""
                        } else {
                            insItem.fkIdx = data[ProjInspIdx]!
                        }
                        insItem.areaId = insAreaItem.idx
                        insItem.placeId = insPlaceItem.idx
                        let InspUploadFile = Table("InspUploadFile")
                        let FileType = Expression<String?>("FileType")
                        let FileName = Expression<String?>("FileName")
                        let FileUrl = Expression<String?>("FileUrl")
                        let queryImg = InspUploadFile.select(FileName, FileUrl).filter(AreaId == insAreaItem.idx && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && ChkNo == targetChkNo && ProjInspIdx == insItem.fkIdx && FileType == "B" && InspPlaceId == insItem.placeId && SeqNo == (insItem.seqNo == "" ? "" : insItem.seqNo)).order(Sorting.asc)
                        print(insItem.placeId)
                        for dataImgName in try db.prepare(queryImg) {
                            print("name: \(dataImgName[FileName]!)")
                            insItem.picUrl = dataImgName[FileName]!
                        }
                        
                        insPlaceItem.items.append(insItem)
                    }
                    
                    for insItem in insPlaceItem.items {
                        let queryItemId = InspPlaceItem_InspItem.select(InspItemId, EquipAmount).filter(ProjInspIdx == insItem.fkIdx).order(Sorting.asc)
                        for data in try db.prepare(queryItemId) {
                            print("***name: \(data[InspItemId]!)")
                            insItem.idx = data[InspItemId]!
                            if data[EquipAmount] != nil {
                                insItem.amount = data[EquipAmount]!
                            }
                        }
                        let queryItemName = InspItem.select(InspItemName).filter(InspItemId == insItem.idx).order(Sorting.asc)
                        for data in try dbMain.prepare(queryItemName) {
                            print("***name: \(data[InspItemName]!)")
                            insItem.name = data[InspItemName]!
                        }
                    }
                }
            }
        } catch {
            //handle error
            print(error)
        }
        
        tableViewArea.reloadData()
        tableViewItem.reloadData()
        saveLocalData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.tag == 0 {
            return 1
        } else {
            if areaIndex >= dataArea.count {
                return 0
            } else {
                return dataArea[areaIndex].places.count
            }
        }
    }
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableView.tag == 0 {
			return dataArea.count
		} else {
			return dataArea[areaIndex].places[section].items.count
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if tableView.tag == 0 {
			return 90.0
		} else {
			return 70.0
		}
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if tableView.tag == 0 {
			return 0.0
		} else {
			return 50.0
		}
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if tableView.tag == 0 {
			return nil
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "InsDetect0HeaderCell") as! InsDetect0HeaderCell
			cell.lblTitle.text = dataArea[areaIndex].places[section].name
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if tableView.tag == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "InsDetect0CategoryCell", for: indexPath) as! InsDetect0CategoryCell
			let insAreaItem = dataArea[indexPath.row]
			cell.lblTitle.text = String(indexPath.row + 1) + "." + insAreaItem.name
            
            var sumMiss = 0
            
            for place in insAreaItem.places {
                for item in place.items {
                    if item.check == true && item.result == 1 {
                        sumMiss += 1
                    }
                }
            }
            
            cell.lblCount.text = String(format: "%d", sumMiss)
        
			if areaIndex == indexPath.row && ivBig.isHidden == true {
				cell.backgroundColor = UIColor.init(red: 144.0 / 255.0, green: 33.0 / 255.0, blue: 38.0 / 255.0, alpha: 1.0)
			} else {
				cell.backgroundColor = UIColor.clear
			}
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "InsDetect0ItemCell", for: indexPath) as! InsDetect0ItemCell
			cell.selectionStyle = .none
			let InsItem = dataArea[areaIndex].places[indexPath.section].items[indexPath.row]
			if InsItem.amount.count != 0 && InsItem.amount != "0"{
                if InsItem.name == "" {
                    InsItem.name = "檢核數量"
                }
                cell.lblTitle.text = String.init(format: "%d.%@ 數量:%@", indexPath.row + 1, InsItem.name, InsItem.amount)
			} else {
				cell.lblTitle.text = String(indexPath.row + 1) + "." + InsItem.name
			}
            
            cell.setCheck(InsItem: InsItem)
            if UserDefaults.standard.object(forKey: "ISRECORD") != nil {
                if InsItem.picUrl == "" {
                    cell.btnCamera.isHidden = true
                }
            } else {
                cell.btnCheck.tag = indexPath.section * 10000 + indexPath.row
                cell.btnCheck.addTarget(self, action: #selector(clickCheck(button:)), for: UIControlEvents.touchUpInside)
                cell.btnMiss.tag = indexPath.section * 10000 + indexPath.row
                cell.btnMiss.addTarget(self, action: #selector(clickMiss(button:)), for: UIControlEvents.touchUpInside)
                cell.btnCamera.tag = indexPath.section * 10000 + indexPath.row
                cell.btnCamera.addTarget(self, action: #selector(clickEdit(button:)), for: UIControlEvents.touchUpInside)
                cell.lblStatus.tag = indexPath.section * 10000 + indexPath.row
                cell.lblStatus.isUserInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapLabel(sender:)))
                cell.lblStatus.addGestureRecognizer(tapGesture)
                cell.tfNumber.tag = indexPath.section * 10000 + indexPath.row
                cell.tfNumber.text = "\(InsItem.detect_amount)"
                cell.tfNumber.delegate = self
                //let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTapCamera(_:)))
                //cell.btnCamera.addGestureRecognizer(longGesture)
            }
			return cell
		}
	}
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0 {
            areaIndex = indexPath.row
            tableViewArea.reloadData()
            tableViewItem.reloadData()
            tableViewItem.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            ivBig.isHidden = true
            btnAddMistake.isHidden = false
            btnSave.isHidden = false
        } else {
            /*
            let addMistakeEditController = AddMistakeEditController()
            let insAreaItem = dataArea[areaIndex]
            addMistakeEditController.areaName = insAreaItem.name
            addMistakeEditController.placeName = dataArea[areaIndex].places[indexPath.section].name
            addMistakeEditController.desName = dataArea[areaIndex].places[indexPath.section].items[indexPath.row].name
            addMistakeEditController.targetInsItem = dataArea[areaIndex].places[indexPath.section].items[indexPath.row]
            self.navigationController?.pushViewController(addMistakeEditController, animated: true)
 */
        }
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.tableViewItem)
            if let indexPath = self.tableViewItem.indexPathForRow(at: touchPoint) {
                let InsItemDelete = dataArea[areaIndex].places[indexPath.section].items[indexPath.row]
                if InsItemDelete.fkIdx == "" {
                    let alert = UIAlertController(title: "提醒", message: "是否刪除新增資料？" + InsItemDelete.name, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.destructive, handler:nil))
                    alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
                        let targetAreaData = InsTmpDataManager.sharedInstance().dicArea["Ins_DataArea"]!
                        targetAreaData[self.areaIndex].places[indexPath.section].items.remove(at: indexPath.row)
                        InsTmpDataManager.sharedInstance().dicArea["Ins_DataArea"] = targetAreaData
                        self.tableViewArea.reloadData()
                        self.tableViewItem.reloadData()
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
        }
    }
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		textField.text = ""
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxLength = 7
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length >= maxLength {
            return false
        }
        
		let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
		let compSepByCharInSet = string.components(separatedBy: aSet)
		let numberFiltered = compSepByCharInSet.joined(separator: "")
		return string == numberFiltered
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
        let section = textField.tag / 10000
        let row = textField.tag % 10000
        let InsItem = dataArea[areaIndex].places[section].items[row]
        if(textField.text?.count == 0) {
            let alert = UIAlertController(title: "提醒", message: "缺少數量不可為空值", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
            
            textField.text = "0"
        }
        if Int(textField.text!)! > Int(InsItem.amount)! {
            let alert = UIAlertController(title: "提醒", message: "缺少數量不可大於應有數量", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
            textField.text = "0"
        }
        
		InsItem.detect_amount = Int(textField.text!)!
	}
    
    @objc func clickEdit(button: UIButton) {
        do {
            let section = button.tag / 10000
            let row = button.tag % 10000
            let addMistakeEditController = AddMistakeEditController()
            let insAreaItem = dataArea[areaIndex]
            addMistakeEditController.type = 1
            addMistakeEditController.areaName = insAreaItem.name
            addMistakeEditController.placeName = dataArea[areaIndex].places[section].name
            
            
            if dataArea[areaIndex].places[section].items[row].fkIdx != "" {
                addMistakeEditController.desEnable = false
                //addMistakeEditController.desName = dataArea[areaIndex].places[section].items[row].name
                addMistakeEditController.desName = ""
            } else {
                addMistakeEditController.desName = ""
            }
 
            addMistakeEditController.targetInsItem = dataArea[areaIndex].places[section].items[row]
            self.navigationController?.pushViewController(addMistakeEditController, animated: true)
        } catch {
            print(error)
        }
    }
	
	func longTapCamera(_ sender: UIGestureRecognizer){
		let button = sender.view as! UIButton
        let section = button.tag / 10000
        let row = button.tag % 10000
        let InsItem = dataArea[areaIndex].places[section].items[row]
		if InsItem.picUrl.count != 0 {
			let alertController = UIAlertController(
				title: "提醒",
				message: String.init(format: "是否刪除照片"),
				preferredStyle: .alert)
			
			let okAction = UIAlertAction(title: "確定", style: .default) { (alertController) in
				do {
					let fileManager = FileManager.default
					let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
					let fileURL = documentDirectory.appendingPathComponent(InsItem.picUrl)
					try fileManager.removeItem(at: fileURL)
				} catch {
					print(error)
				}
				InsItem.picUrl = ""
				self.tableViewItem.reloadData()
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
		saveLocalData()
	}
	
    @objc func clickCheck(button: UIButton) {
        let section = button.tag / 10000
        let row = button.tag % 10000
        let InsItem = dataArea[areaIndex].places[section].items[row]
        if InsItem.check == true && InsItem.result == 0 {
            InsItem.check = false
            InsItem.result = -1
            tableViewArea.reloadData()
            tableViewItem.reloadData()
            saveLocalData()
        } else {
           /* if InsItem.picUrl.count != 0 {
                let alertController = UIAlertController(
                    title: "提醒",
                    message: String.init(format: "是否刪除照片"),
                    preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "確定", style: .default) { (alertController) in
                    do {
                        let fileManager = FileManager.default
                        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                        let fileURL = documentDirectory.appendingPathComponent(InsItem.picUrl)
                        try fileManager.removeItem(at: fileURL)
                    } catch {
                        print(error)
                    }
                    InsItem.picUrl = ""
                    InsItem.check = true
                    InsItem.result = 0
                    InsItem.desId = ""
                    nsItem.inspRemark = ""
                    self.tableViewItem.reloadData()
                }
                
                let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (alertController) in
                }
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                self.present(
                    alertController,
                    animated: true,
                    completion: nil)
            } else {*/
                InsItem.check = true
                InsItem.result = 0
                //InsItem.desId = ""
                //InsItem.inspRemark = ""
                //InsItem.picUrl = ""
            tableViewArea.reloadData()
                tableViewItem.reloadData()
                saveLocalData()
            //}
        }
	}
	
    @objc func clickMiss(button: UIButton) {
        let section = button.tag / 10000
        let row = button.tag % 10000
        targetItem = dataArea[areaIndex].places[section].items[row]
        if targetItem.check == true && targetItem.result == 1 {
            targetItem.check = false
            targetItem.result = -1
            //targetItem.desId = ""
            //targetItem.inspRemark = ""
            //targetItem.picUrl = ""
            tableViewArea.reloadData()
            tableViewItem.reloadData()
            saveLocalData()
        } else {
            if targetItem.amount.count != 0 && targetItem.amount != "0" {
                //showPopMenu()
                self.targetItem.check = true
                self.targetItem.result = 1
                self.targetItem.status = 1
                tableViewArea.reloadData()
                self.tableViewItem.reloadData()
                self.saveLocalData()
            } else {
                targetItem.check = true
                targetItem.result = 1
                tableViewArea.reloadData()
                tableViewItem.reloadData()
                saveLocalData()
            }
        }
	}
	
    @objc func tapLabel(sender: UITapGestureRecognizer) {
		let lbl = sender.view as! UILabel
        let section = lbl.tag / 10000
        let row = lbl.tag % 10000
        targetItem = dataArea[areaIndex].places[section].items[row]
        targetItem.check = false
        targetItem.result = -1
        tableViewItem.reloadData()
        saveLocalData()
		
	}
	
	func showPopMenu()
	{
		let alertController = UIAlertController(
			title: "請選擇缺失",
			message: "",
			preferredStyle: .alert)
		
		let cancelAction = UIAlertAction(
			title: "取消",
			style: .cancel,
			handler: nil)
		
		alertController.addAction(cancelAction)
		
		let s0Action = UIAlertAction(
			title: "損壞",
			style: .default,
			handler: { action in
				self.targetItem.check = true
				self.targetItem.result = 1
				self.targetItem.status = 0
				self.tableViewItem.reloadData()
				self.saveLocalData()
		})
		
		alertController.addAction(s0Action)
		
		let s1Action = UIAlertAction(
			title: "缺少",
			style: .default,
			handler: { action in
				self.targetItem.check = true
				self.targetItem.result = 1
				self.targetItem.status = 1
				self.tableViewItem.reloadData()
				self.saveLocalData()
		})
		
		alertController.addAction(s1Action)
		
		self.present(alertController, animated: true, completion: nil)
	}
	
	func clickCamera(button: UIButton) {
		do {
            let section = button.tag / 10000
            let row = button.tag % 10000
            targetItem = dataArea[areaIndex].places[section].items[row]
			if targetItem.picUrl.count != 0 {
				let fileManager = FileManager.default
				let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
				let fileURL = documentDirectory.appendingPathComponent(targetItem.picUrl)
				print(targetItem.picUrl)
				let image = try UIImage.init(data: Data.init(contentsOf: fileURL), scale:1.0)
				var photos: [NYTPhoto] = []
                let title = NSAttributedString(string: targetItem.name, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
				let photo = Photo.init(image:image, attributedCaptionTitle: title)
				photos.append(photo)
				let photosViewController = NYTPhotosViewController(photos: photos)
				present(photosViewController, animated: true, completion: nil)
			} else {
				let cameraController = CameraController()
				cameraController.delegate = self
				self.navigationController?.pushViewController(cameraController, animated: true)
			}
		} catch {
			print(error)
		}
	}
	
	func didFinishPhoto(image:UIImage) {
		do {
			if let data = UIImagePNGRepresentation(image) {
				let fileManager = FileManager.default
				let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
				let userIdx = UserDefaults.standard.string(forKey: "UserIdx")
				let fileName = String.init(format: "%@_%.0f.png", userIdx!, NSDate().timeIntervalSince1970)
				let fileURL = documentDirectory.appendingPathComponent(fileName)
				try data.write(to: fileURL)
				targetItem.picUrl = fileName
				tableViewItem.reloadData()
			}
		} catch {
			print(error)
		}
		saveLocalData()
	}
	
    //MARK: Button Action
    @objc func btnBackPressed(sender: UIBarButtonItem) {
        if  ivBig.isHidden == true {
            if checkNotFinish(0) {
                btnAddMistake.isHidden = true
                btnSave.isHidden = true
                ivBig.isHidden = false
            }
            return
        }
        
        var vcs = self.navigationController!.viewControllers
        if vcs.count > 0 {
            vcs.remove(at: vcs.count - 1)
        }
        
        if vcs.count > 0 {
            vcs.remove(at: vcs.count - 1)
        }
        
        if UserDefaults.standard.object(forKey: "ISRECORD") != nil {
            
            self.navigationController?.popViewController(animated: true)
            //self.navigationController?.setViewControllers(vcs, animated: true)
            return
        }
        
        self.navigationController?.popViewController(animated: true)
        //self.navigationController?.setViewControllers(vcs, animated: true)
		
    }
    @IBAction func clickAddMistake(_ sender: Any) {
        let addMistakeController = AddMistakeController()
        addMistakeController.from = 1
        if dataArea.indices.contains(areaIndex) {
            addMistakeController.initialAreaId = dataArea[areaIndex].idx
        }
        self.navigationController?.pushViewController(addMistakeController, animated: true)
    }

    @IBAction func btnSavePressed(_ sender: Any) {
        let alertController = UIAlertController(
            title: "提醒",
            message: "是否儲存驗屋紀錄？",
            preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "確定", style: .default) { _ in
            self.saveLocalData()
            InsTmpDataManager.sharedInstance().saveData()
            InsTmpDataManager.sharedInstance().clearData()

            for viewController in self.navigationController?.viewControllers ?? [] {
                if viewController.isKind(of: InsDashboardController.self) {
                    self.navigationController?.popToViewController(viewController, animated: true)
                    break
                }
            }
        })
        present(alertController, animated: true, completion: nil)
    }
    
	@IBAction func btnNextPressed(_ sender: Any) {
        if checkNotFinish(1) {
			self.navigationController?.pushViewController(InsDetectListConfirmFinalController(), animated: true)
		}
	}
    
    func checkNotFinish(_ mode:Int) -> Bool {
        var sumNotCheck = 0
        for area in dataArea {
            for place in area.places {
                for item in place.items {
                    if item.check == false {
                        sumNotCheck += 1
                    }
                }
            }
        }
        
        if sumNotCheck > 0 {
            let alertController = UIAlertController(
                title: "提醒",
                message: String.init(format: "還有%d項目未驗，請驗收完再進行下一步", sumNotCheck),
                preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "確定", style: .default) { (alertController) in
                if mode == 0 {
                    self.ivBig.isHidden = false
                    self.btnAddMistake.isHidden = true
                    self.btnSave.isHidden = true
                    self.tableViewArea.reloadData()
                } else {
                self.navigationController?.pushViewController(InsDetectListConfirmFinalController(), animated: true)
                    
                }
                
                
            }
            
            alertController.addAction(okAction)
            self.present(
                alertController,
                animated: true,
                completion: nil)
            return false
        } else {
            return true
        }
    }
}

class RespectListTmpData: NSObject {
	var type: Int = -1
	var id: String = ""
	var seqNo: String = ""
	var areaId: String = ""
	var placeId: String = ""
	var descId: String = ""
	var remark: String = ""
	var isFixed: String = ""
    var remarkFixed: String = ""
    var checkFlowType: String = ""
}

class DetectListData: NSObject {
	
	var titles: NSArray?
	var data: NSArray?
	
	init(titles: NSArray, data: NSArray) {
		self.titles = titles
		self.data = data
		super.init()
	}
    
    
}
