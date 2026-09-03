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

class InsDetectListRecordController: UIViewController, UITableViewDelegate, UITableViewDataSource, EPSignatureDelegate {
	
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
    var flowIdData:[String] = []
    var flowNameData:[String] = []
	
	// MARK: Life Circle
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
		lblTitle.text = InsTargetData.sharedInstance().displayTitle
		
		//register nib
		tableView.register(UINib(nibName: "InsDetect0HeaderCell", bundle: nil), forCellReuseIdentifier: "InsDetect0HeaderCell")
		tableView.register(UINib(nibName: "InsDetect0ItemCell", bundle: nil), forCellReuseIdentifier: "InsDetect0ItemCell")
		
        //init back button
        let btnBack = NaviTool.initBtnBack()
        btnBack.addTarget(self, action: #selector(btnBackPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(btnBack)
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
                print("name: \(data[table_id]!)")
                flowIdDataTmp.append(data[table_id]!)
            }
            
            let dbMain = try Connection(fileURL.absoluteString)
            
            let table1 = Table("CheckFlowItem")
            let table_name = Expression<String?>("CheckFlowItemName")
            query = table1.select(table_name, table_id).order(table_sorting.asc)
            for data in try dbMain.prepare(query) {
                print("name: \(data[table_name]!)")
                for id in flowIdDataTmp {
                    if id == data[table_id]! {
                        catOpId.append(data[table_id]!)
                        catOpName.append(data[table_name]!)
                        break
                    }
                }
            }
            
           
        } catch {
            //handle error
            print(error)
        }
        catOpName.append("一般檢核項目")
        catOpId.append("Ins")
        initFlowData()
        initRecordInsData()
        initAreaItem()
        initDisplayData()
    }
	
	
    
    func initFlowData() {
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
            
            for data in try db.prepare(query) {
                print("name: \(data[table_id]!)")
                flowIdData.append(data[table_id]!)
            }
            
            let dbMain = try Connection(fileURL.absoluteString)
            
            for id in flowIdData {
                let table1 = Table("CheckFlowItem")
                let table_name = Expression<String?>("CheckFlowItemName")
                query = table1.select(table_name).filter(table_id == id)
                    .order(table_sorting.asc)
                for data in try dbMain.prepare(query) {
                    print("name: \(data[table_name]!)")
                    flowNameData.append(data[table_name]!)
                }
            }
            InsTmpDataManager.sharedInstance().flowIdData = flowIdData
            InsTmpDataManager.sharedInstance().flowNameData = flowNameData          
        } catch {
            //handle error
            print(error)
        }
        
        for opId in flowIdData {
            initRecordFlowData(opId)
        }
        
    }
    
    func initRecordFlowData(_ opId:String) {
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
            
            
            let query = InspCheckFlowDetail.select(distinct:AreaId).filter(CheckFlowItemId == opId && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && Result == "N" && IsValid == "Y" && ChkNo == targetChkNo)
            for data in try db.prepare(query) {
                print("name: \(data[AreaId]!)")
                let insAreaItem = InsAreaItem.init()
                insAreaItem.idx = data[AreaId]!
                dataArea.append(insAreaItem)
            }
            
            for insAreaItem in dataArea {
                let queryAreaName = AreaItem.select(AreaName).filter(AreaId == insAreaItem.idx).order(Sorting.asc)
                for data in try dbMain.prepare(queryAreaName) {
                    print("*name: \(data[AreaName]!)")
                    insAreaItem.name = data[AreaName]!
                }
                
                let query = InspCheckFlowDetail.select(ChkInspIdx, Result, EquipFailType, InspDescItemId, EquipFailLessAmount, InspRemark).filter(CheckFlowItemId == opId && AreaId == insAreaItem.idx && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && Result == "N" && IsValid == "Y" && ChkNo == targetChkNo).order(Sorting.asc)
                for insData in try db.prepare(query) {
                    print("id: \(insData[ChkInspIdx]!)")
                    
                    let queryItemId = CheckFlowItem_InspItem.select(InspItemId, EquipAmount).filter(ChkInspIdx == insData[ChkInspIdx]).order(Sorting.asc)
                    for data in try db.prepare(queryItemId) {
                        print("name: \(data[InspItemId]!)")
                        let insItem = InsItem.init()
                        insItem.fkIdx = insData[ChkInspIdx]!
                        insItem.amount = data[EquipAmount]!
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
                        insItem.check = true
                        if insData[Result] != nil {
                            if insData[Result] == "N" {
                                insItem.result = 1
                            } else if insData[Result] == "Y" {
                                insItem.result = 0
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
                            if insItem.picUrls.count < 2 { insItem.picUrls.append(dataImgName[FileName]!) }
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
    
    func initRecordInsData() {
        var dataArea:[InsAreaItem] = []
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
            let targetChkNo = InsTargetData.sharedInstance().inspNo
            
            //general data
            let InspDetail = Table("InspDetail")
            let InspPlaceId = Expression<String?>("InspPlaceId")
            let ProjInspIdx = Expression<String?>("ProjInspIdx")
            
            let query = InspDetail.select(distinct:AreaId).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && Result == "N" && IsValid == "Y" && ChkNo == targetChkNo)
            for data in try db.prepare(query) {
                print("name: \(data[AreaId]!)")
                let insAreaItem = InsAreaItem.init()
                insAreaItem.type = 1
                insAreaItem.idx = data[AreaId]!
                dataArea.append(insAreaItem)
            }
            
            let AreaItem = Table("AreaItem")
            let AreaName = Expression<String?>("AreaName")
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
                    
                    let queryItem = InspDetail.select(InspDescItemId, InspRemark, SeqNo, ProjInspIdx, Result, CheckEquipType, EquipFailLessAmount).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && Result == "N" && IsValid == "Y" && ChkNo == targetChkNo && AreaId == insAreaItem.idx && InspPlaceId == insPlaceItem.idx).order(Sorting.asc)
                    for data in try db.prepare(queryItem) {
                       
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
                            insItem.detect_amount = 0
                        }
                        
                        insItem.check = true
                        if data[Result] != nil {
                            if data[Result] == "N" {
                                insItem.result = 1
                            } else if data[Result] == "Y" {
                                insItem.result = 0
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
                        
                        if insItem.seqNo == "" {
                            let queryImg = InspUploadFile.select(FileName, FileUrl).filter(AreaId == insAreaItem.idx && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && ChkNo == targetChkNo && ProjInspIdx == insItem.fkIdx && FileType == "B" && InspPlaceId == insItem.placeId).order(Sorting.asc)
                            for dataImgName in try db.prepare(queryImg) {
                                print("name: \(dataImgName[FileName]!)")
                                if insItem.picUrls.count < 2 { insItem.picUrls.append(dataImgName[FileName]!) }
                            }
                        } else {
                            let queryImg = InspUploadFile.select(FileName, FileUrl).filter(AreaId == insAreaItem.idx && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && ChkNo == targetChkNo && FileType == "B" && InspPlaceId == insItem.placeId && SeqNo == insItem.seqNo).order(Sorting.asc)
                            for dataImgName in try db.prepare(queryImg) {
                                print("name: \(dataImgName[FileName]!)")
                                if insItem.picUrls.count < 2 { insItem.picUrls.append(dataImgName[FileName]!) }
                            }
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
      
        InsTmpDataManager.sharedInstance().dicArea["Ins_DataArea"] = dataArea
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
	
	
	
	//MARK: TableView Datasource and Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return placeData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeData[section].items.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 0 {
            return nil
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InsDetect0HeaderCell") as! InsDetect0HeaderCell
            cell.lblTitle.text = placeData[section].name
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InsDetect0ItemCell", for: indexPath) as! InsDetect0ItemCell
        cell.selectionStyle = .none
        let insItem = placeData[indexPath.section].items[indexPath.row]
        if insItem.amount.count != 0 && insItem.amount != "0"{
            if insItem.name == "" {
                insItem.name = "數量檢核"
            }
            
            cell.lblTitle.text = String.init(format: "%d.%@  數量:%@", indexPath.row + 1, insItem.name, insItem.amount)
            
        } else {
            cell.lblTitle.text = String(indexPath.row + 1) + "." + insItem.name
        }
        cell.isRecord = true
        cell.setCheck(InsItem: insItem)
        if insItem.desId != "" || insItem.inspRemark != "" || insItem.picUrl != "" {
            cell.btnCamera.isHidden = false
            cell.btnCamera.tag = indexPath.section * 10000 + indexPath.row
            cell.btnCamera.addTarget(self, action: #selector(clickEdit(button:)), for: UIControlEvents.touchUpInside)
        } else {
            cell.btnCamera.isHidden = true
        }
        
        return cell
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
	
    @IBAction func btnListPressed(sender: AnyObject) {
        let button = sender as! UIButton
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "列印驗屋紀錄", style: .default) { _ in
            
            
            self.clickPrint()
            
            
            
            
        })
        
        
        alert.addAction(UIAlertAction(title: "離開驗屋紀錄", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        
      
        let popPresenter = alert.popoverPresentationController
        popPresenter?.sourceView = button
        popPresenter?.sourceRect = button.bounds
        present(alert, animated: true)
    }
    
    func clickPrint() {
       
        let pdfURL = PDFGenerator().createPDF(placeData)
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary : nil)
        printInfo.duplex = .longEdge
        printInfo.outputType = .grayscale
        printInfo.jobName = "列印驗屋確認單"
        printController.printInfo = printInfo
        printController.printingItem = pdfURL
        printController.present(animated : true, completionHandler : nil)
        
    }

	
}
