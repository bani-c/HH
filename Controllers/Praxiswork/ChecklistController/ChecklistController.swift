
//
//  ChecklistController.swift
//  Home-Maintenance
//
//  Created by Yuchi Chen on 2017/9/18.
//  Copyright © 2017年 Ultron mobile. All rights reserved.
//

import UIKit
import SQLite

class ChecklistController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var sgIsFixed: UISegmentedControl!
    @IBOutlet var vwSegmentedBg: UIView!
    @IBOutlet var vwProgressFrame: UIView!
    @IBOutlet var tableView: UITableView!
	@IBOutlet weak var lblTitle: UILabel!
	
    let checklistTitleView = "ChecklistTitleView"
    let subtitleCellIdentifier = "ChecklistSubtitleCell"
    let itemCellIdentifier = "ChecklistItemCell"
    let photoViewIdentifier = "PhotoView"
    let popupViewIdentifier = "PopupView"

    var dataItem = NSMutableArray.init()
	var dataArea:[InsAreaItem] = []
    var flowIdData:[String] = []
    var flowNameData:[String] = []
    var catOpId:[String] = []
    var placeData:[InsPlaceItem] = []
    var catOpName:[String] = []
    var targetAreaData:[InsAreaItem] = []
    var targetItemData = NSMutableArray.init()
    var tmpAreaItem:InsAreaItem = InsAreaItem.init()
    var opIndex = 0
    var areaIndex:Int = 0
    var catFilterIndex:Int = 0
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Custom Functions
    func initLayout() {
		
		lblTitle.text = String.init(format: "%@_%@_%@", InsTargetData.sharedInstance().building, InsTargetData.sharedInstance().floor, InsTargetData.sharedInstance().room)
		
        //init back button
        let btnBack = NaviTool.initBtnBack()
        btnBack.addTarget(self, action: #selector(btnBackPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(btnBack)
        
        //init sgIsFixed layout
        let font = UIFont.systemFont(ofSize: 18.0)
        sgIsFixed.setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
        
        //init vwSegmentedBg layout
        vwSegmentedBg.layer.cornerRadius = 4.0
        vwSegmentedBg.layer.masksToBounds = true
        
        //init vwProgressFrame layout
        vwProgressFrame.layer.borderColor = UIColor(red:0.92, green:0.76, blue:0.50, alpha:1.00).cgColor
        vwProgressFrame.layer.borderWidth = 1.0
        
        //init tableView
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150.0
        
        //register nib
        tableView.register(UINib(nibName: subtitleCellIdentifier, bundle: nil), forCellReuseIdentifier: subtitleCellIdentifier)
        tableView.register(UINib(nibName: itemCellIdentifier, bundle: nil), forCellReuseIdentifier: itemCellIdentifier)
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
            let ModifyStatus = Expression<String?>("ModifyStatus")
            let ModifyRemark = Expression<String?>("ModifyRemark")
            
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

                let query = InspCheckFlowDetail.select(ChkInspIdx, Result, EquipFailType, InspDescItemId, EquipFailLessAmount, InspRemark, ModifyStatus, ModifyRemark).filter(CheckFlowItemId == opId && AreaId == insAreaItem.idx && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && Result == "N" && IsValid == "Y" && ChkNo == targetChkNo).order(Sorting.asc)
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
                        if insData[ModifyStatus] == nil {
                            insItem.isFixed = ""
                        } else {
                            insItem.isFixed = insData[ModifyStatus]!
                        }
                        if insData[ModifyRemark] == nil {
                            insItem.commentFixed = ""
                        } else {
                            insItem.commentFixed = insData[ModifyRemark]!
                        }
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
                            insItem.picUrl = dataImgName[FileName]!
                        }
                        
                        let queryImgA = InspCheckFlowUploadFile.select(FileName, FileUrl).filter(CheckFlowItemId == opId && AreaId == insAreaItem.idx && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && ChkNo == targetChkNo && ChkInspIdx == insItem.fkIdx && FileType == "A").order(Sorting.asc)
                        for dataImgName in try db.prepare(queryImgA) {
                            print("name: \(dataImgName[FileName]!)")
                            insItem.picUrlFixed = dataImgName[FileName]!
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
            let ModifyStatus = Expression<String?>("ModifyStatus")
            let ModifyRemark = Expression<String?>("ModifyRemark")
            
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
                    
                    let queryItem = InspDetail.select(InspDescItemId, InspRemark, SeqNo, ProjInspIdx, Result, CheckEquipType, EquipFailLessAmount, ModifyStatus, ModifyRemark).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && Result == "N" && IsValid == "Y" && ChkNo == targetChkNo && AreaId == insAreaItem.idx && InspPlaceId == insPlaceItem.idx).order(Sorting.asc)
                    for data in try db.prepare(queryItem) {
                        
                        let insItem = InsItem.init()
                        if data[ModifyStatus] == nil {
                            insItem.isFixed = ""
                        } else {
                            insItem.isFixed = data[ModifyStatus]!
                        }
                        if data[ModifyRemark] == nil {
                            insItem.commentFixed = ""
                        } else {
                            insItem.commentFixed = data[ModifyRemark]!
                        }
                        
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
                                insItem.picUrl = dataImgName[FileName]!
                            }
                        } else {
                            let queryImg = InspUploadFile.select(FileName, FileUrl).filter(AreaId == insAreaItem.idx && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && ChkNo == targetChkNo && FileType == "B" && InspPlaceId == insItem.placeId && SeqNo == insItem.seqNo).order(Sorting.asc)
                            for dataImgName in try db.prepare(queryImg) {
                                print("name: \(dataImgName[FileName]!)")
                                insItem.picUrl = dataImgName[FileName]!
                            }
                        }
                       
                        if insItem.seqNo == "" {
                            let queryImgA = InspUploadFile.select(FileName, FileUrl).filter(AreaId == insAreaItem.idx && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && ChkNo == targetChkNo && ProjInspIdx == insItem.fkIdx && FileType == "A" && InspPlaceId == insItem.placeId).order(Sorting.asc)
                            for dataImgName in try db.prepare(queryImgA) {
                                if dataImgName[FileName] != nil {
                                    print("name: \(dataImgName[FileName]!)")
                                    insItem.picUrlFixed = dataImgName[FileName]!
                                }
                                
                            }
                        } else {
                            let queryImgA = InspUploadFile.select(FileName, FileUrl).filter(AreaId == insAreaItem.idx && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && ChkNo == targetChkNo && FileType == "A" && InspPlaceId == insItem.placeId && SeqNo == insItem.seqNo).order(Sorting.asc)
                            for dataImgName in try db.prepare(queryImgA) {
                                if dataImgName[FileName] != nil {
                                    print("name: \(dataImgName[FileName]!)")
                                    insItem.picUrlFixed = dataImgName[FileName]!
                                }
                                
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
	
    //MARK: UITableViewDataSource
    //MARK: TableView Datasource and Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return placeData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeData[section].items.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	
        guard let itemCell = tableView.dequeueReusableCell(withIdentifier: itemCellIdentifier, for: indexPath) as? ChecklistItemCell else {
            fatalError("The dequeued cell is not an instance of ChecklistItemCell.")
        }
		
        let insItem = placeData[indexPath.section].items[indexPath.row]
        if insItem.amount.count != 0 && insItem.amount != "0"{
            if insItem.name == "" {
                insItem.name = "數量檢核"
            }
            
            itemCell.setTitle(String.init(format: "%d.%@  數量:%@", indexPath.row + 1, insItem.name, insItem.amount))
            
        } else {
            itemCell.setTitle(String(indexPath.row + 1) + "." + insItem.name)
        }
		itemCell.btnFile.indexPath = indexPath
		itemCell.btnFix.indexPath = indexPath
		itemCell.btnFixedBefore.indexPath = indexPath
		itemCell.btnFixedAfter.indexPath = indexPath
		//itemCell.setTitle(item.name)
        itemCell.setLayout(insItem)
		//itemCell.setIsFixed(insItem.isFixed == "Y")
		if itemCell.btnFile.allTargets.count == 0 {
			itemCell.btnFile.addTarget(self, action: #selector(btnFileRecordPressed(sender:)), for: .touchUpInside)
		}
		if itemCell.btnFix.allTargets.count == 0 {
			itemCell.btnFix.addTarget(self, action: #selector(btnFixPressed(sender:)), for: .touchUpInside)
		}
		if itemCell.btnFixedBefore.allTargets.count == 0 {
			itemCell.btnFixedBefore.addTarget(self, action: #selector(btnFixedPressed(sender:)), for: .touchUpInside)
		}
		if itemCell.btnFixedAfter.allTargets.count == 0 {
			itemCell.btnFixedAfter.addTarget(self, action: #selector(btnFixedPressed(sender:)), for: .touchUpInside)
		}
		return itemCell
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let place = placeData[section]
        let headerView = Bundle.main.loadNibNamed(checklistTitleView, owner: self, options: nil)?[0] as! ChecklistTitleView
        headerView.lblTitle.text = place.name
        headerView.btnToggle.tag = section
        if headerView.btnToggle.allTargets.count == 0 {
            //headerView.btnToggle.addTarget(self, action: #selector(btnTogglePressed(sender:)), for: .touchUpInside)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerView = Bundle.main.loadNibNamed(checklistTitleView, owner: self, options: nil)?[0] as! ChecklistTitleView
        return headerView.frame.size.height
    }
    
    //MARK: Button Action
    @IBAction func btnSavePressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "提醒", message: NSLocalizedString("save_send_result", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.destructive, handler:nil))
        alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.default, handler: { action in
          self.saveData()
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func saveData() {
        InsTmpDataManager.sharedInstance().saveFixData()
        
        
        
        /*
        do {
            let projectsNo = UserDefaults.standard.string(forKey: "PROJECT_NO")!
            let building = UserDefaults.standard.string(forKey: "BUILDING")!
            let floor = UserDefaults.standard.string(forKey: "FLOOR")!
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileNameUpload = String.init(format: SystemConstants.DBFileNameSubUpload, projectsNo, building)
            let fileURLUpload = documentDirectory.appendingPathComponent(fileNameUpload)
            let fileName = String.init(format: SystemConstants.DBFileNameSub, projectsNo, building)
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            
            
            let dbUpload = try Connection(fileURLUpload.absoluteString)
            let db = try Connection(fileURL.absoluteString)
            
            let InspCheckFlowDetail = Table("InspCheckFlowDetail")
            //let COP_NO = Expression<String?>("COP_NO")
            let PROJM_NO = Expression<String?>("PROJM_NO")
            //let PROJS_NO = Expression<String?>("PROJS_NO")
            let ELEVEL_2 = Expression<String?>("ELEVEL_2")
            let ELEVEL_1 = Expression<String?>("ELEVEL_1")
            let CheckFlowType = Expression<String?>("CheckFlowType")
            let CheckFlowItemId = Expression<String?>("CheckFlowItemId")
            let ChkNo = Expression<String?>("ChkNo")
            let AreaId = Expression<String?>("AreaId")
            let ChkInspIdx = Expression<String?>("ChkInspIdx")
            let Result = Expression<String?>("Result")
            
            let InspCheckFlowUploadFile = Table("InspCheckFlowUploadFile")
            let FileType = Expression<String?>("FileType")
            let FileName = Expression<String?>("FileName")
            
            let ProjInspIdx = Expression<String?>("ProjInspIdx")
            
            let EquipFailType = Expression<String?>("EquipFailType")
            let EquipFailLessAmount = Expression<String?>("EquipFailLessAmount")
            let IsValid = Expression<String?>("IsValid")
            
            let InspDetail = Table("InspDetail")
            let InspUploadFile = Table("InspUploadFile")
            let InspPlaceId = Expression<String?>("InspPlaceId")
            
            let InspRemark = Expression<String?>("InspRemark")
            let InspDescItemId = Expression<String?>("InspDescItemId")
            let SeqNo = Expression<String?>("SeqNo")
            let ModifyRemark = Expression<String?>("ModifyRemark")
            let ModifyStatus = Expression<String?>("ModifyStatus")
            let targetChkNo = String(Int(InsTargetData.sharedInstance().inspNo)!)
            var seqNo = 0
            

            for dataArea in dataItem {
                for data in dataArea {
                    if data.type == 0 {
                        let targetInsert = InspCheckFlowDetail.insert(ELEVEL_2 <- building, ELEVEL_1 <- floor, Result <- "N", IsValid <- "Y", ChkNo <- targetChkNo, ChkInspIdx <- data.fkIdx, AreaId <- data.areaId, CheckFlowType <- data.checkFlowType, CheckFlowItemId <- data.checkFlowItemId, ModifyStatus <- data.isFixed, ModifyRemark <- data.commentFixed)
                        
                        try dbUpload.run(targetInsert)
                        
                        let targetPicInsert = InspCheckFlowUploadFile.insert(PROJM_NO <- projectsNo, ELEVEL_2 <- building, ELEVEL_1 <- floor, IsValid <- "Y", ChkNo <- targetChkNo, ChkInspIdx <- data.fkIdx, AreaId <- data.areaId, CheckFlowType <- data.checkFlowType, CheckFlowItemId <- data.checkFlowItemId, FileType <- "A", FileName <- data.picUrlFixed)
                        
                        try dbUpload.run(targetPicInsert)
                        
                        let target = InspCheckFlowDetail.filter(ELEVEL_2 == building && ELEVEL_1 == floor && Result == "N" && IsValid == "Y" && ChkNo == targetChkNo && ChkInspIdx == data.fkIdx && AreaId == data.areaId && CheckFlowType == data.checkFlowType && CheckFlowItemId == data.checkFlowItemId)
                        try db.run(target.update(ModifyStatus <- data.isFixed, ModifyRemark <- data.commentFixed))
                        
                        let targetPic = InspCheckFlowUploadFile.filter(PROJM_NO == projectsNo && ELEVEL_2 == building && ELEVEL_1 == floor && IsValid == "Y" && ChkNo == targetChkNo && ChkInspIdx == data.fkIdx && AreaId == data.areaId && CheckFlowType == data.checkFlowType && CheckFlowItemId == data.checkFlowItemId && FileType == "A")
                        let count = try db.scalar(targetPic.count)
                        if count != 0 {
                            try db.run(targetPic.update(FileName <- data.picUrlFixed))
                        } else {
                            try db.run(targetPicInsert)
                        }
                    } else if data.type == 1 {
                        if data.fkIdx == "" {
                            let targetInsert = InspDetail.insert(ELEVEL_2 <- building, ELEVEL_1 <- floor, Result <- "N", IsValid <- "Y", ChkNo <- targetChkNo, ProjInspIdx <- data.fkIdx, SeqNo <- data.seqNo, AreaId <- data.areaId, ModifyStatus <- data.isFixed, ModifyRemark <- data.commentFixed)
                            
                            try dbUpload.run(targetInsert)
                            
                            let targetPicInsert = InspUploadFile.insert(PROJM_NO <- projectsNo, ELEVEL_2 <- building, ELEVEL_1 <- floor, IsValid <- "Y", ChkNo <- targetChkNo, ProjInspIdx <- data.fkIdx, SeqNo <- data.seqNo, AreaId <- data.areaId, FileType <- "A", FileName <- data.picUrlFixed)
                            
                            try dbUpload.run(targetPicInsert)
                            
                            let target = InspDetail.filter(ELEVEL_2 == building && ELEVEL_1 == floor && Result == "N" && IsValid == "Y" && ChkNo == targetChkNo && ProjInspIdx == data.fkIdx && SeqNo == data.seqNo && AreaId == data.areaId)
                            
                            try db.run(target.update(ModifyStatus <- data.isFixed, ModifyRemark <- data.commentFixed))
                            let targetPic = InspUploadFile.filter(PROJM_NO == projectsNo && ELEVEL_2 == building && ELEVEL_1 == floor && IsValid == "Y" && ChkNo == targetChkNo && ProjInspIdx == data.fkIdx && SeqNo == data.seqNo && AreaId == data.areaId && FileType == "A")
                            let count = try db.scalar(targetPic.count)
                            if count != 0 {
                                try db.run(targetPic.update(FileName <- data.picUrlFixed))
                            } else {
                                try db.run(targetPicInsert)
                            }
                        } else {
                            let targetInsert = InspDetail.insert(ELEVEL_2 <- building, ELEVEL_1 <- floor, Result <- "N", IsValid <- "Y", ChkNo <- targetChkNo, ProjInspIdx <- data.fkIdx, SeqNo <- data.seqNo, AreaId <- data.areaId, ModifyStatus <- data.isFixed, ModifyRemark <- data.commentFixed)
                            
                            try dbUpload.run(targetInsert)
                            
                            let targetPicInsert = InspUploadFile.insert(PROJM_NO <- projectsNo, ELEVEL_2 <- building, ELEVEL_1 <- floor, IsValid <- "Y", ChkNo <- targetChkNo, ProjInspIdx <- data.fkIdx, SeqNo <- data.seqNo, AreaId <- data.areaId, FileType <- "A", FileName <- data.picUrlFixed)
                            
                            try dbUpload.run(targetPicInsert)
                            
                            let target = InspDetail.filter(ELEVEL_2 == building && ELEVEL_1 == floor && Result == "N" && IsValid == "Y" && ChkNo == targetChkNo && ProjInspIdx == data.fkIdx && AreaId == data.areaId)
                            let count0 = try db.scalar(target.count)
                            try db.run(target.update(ModifyStatus <- data.isFixed, ModifyRemark <- data.commentFixed))
                            
                            let targetPic = InspUploadFile.filter(PROJM_NO == projectsNo && ELEVEL_2 == building && ELEVEL_1 == floor && IsValid == "Y" && ChkNo == targetChkNo && ProjInspIdx == data.fkIdx && AreaId == data.areaId && FileType == "A")
                            let count = try db.scalar(targetPic.count)
                            if count != 0 {
                                try db.run(targetPic.update(FileName <- data.picUrlFixed))
                            } else {
                                try db.run(targetPicInsert)
                            }
                        }
                    }
                }
            }
            
           
            
            
            
        } catch {
            print("Ooops! Something went wrong: \(error)")
        }
 */

    }
    
    @objc func btnFilePressed(sender: CustomButton) {
		let indexPath = sender.indexPath!
		let item = placeData[indexPath.section].items[indexPath.row]
		if item.picUrl.count != 0 {
			let photoView = Bundle.main.loadNibNamed(photoViewIdentifier, owner: self, options: nil)?[0] as! PhotoView
			photoView.titles = [NSLocalizedString("fixed_before", comment: "")]
			photoView.images = [item.picUrl]
			self.view.addSubview(photoView)
			photoView.frame = self.view.frame
		}
		
    }
    
    @objc func btnFileRecordPressed(sender: CustomButton) {
        let indexPath = sender.indexPath!
    
        let addMistakeEditController = AddMistakeEditPController()
        addMistakeEditController.type = 2
        addMistakeEditController.areaName = placeData[indexPath.section].areaName
        if placeData[indexPath.section].placeName == "" {
            addMistakeEditController.placeName = placeData[indexPath.section].items[indexPath.row].name
        } else {
            addMistakeEditController.placeName = placeData[indexPath.section].placeName
        }
        /*
        if placeData[indexPath.section].items[indexPath.row].desName == "" {
            addMistakeEditController.desName = placeData[indexPath.section].items[indexPath.row].name
        } else {
            addMistakeEditController.desName = placeData[indexPath.section].items[indexPath.row].desName
        }
 */
        addMistakeEditController.desName = placeData[indexPath.section].items[indexPath.row].desName
        addMistakeEditController.targetInsItem = placeData[indexPath.section].items[indexPath.row]
        self.navigationController?.pushViewController(addMistakeEditController, animated: true)
        
    }
    
    @objc func btnFixPressed(sender: CustomButton) {
        let indexPath = sender.indexPath!
		let place = placeData[indexPath.section]
		let item = placeData[indexPath.section].items[indexPath.row]
		let fixDetailController = FixDetailController()
		fixDetailController.headerTitle = place.name
		fixDetailController.subtitle = item.name
        fixDetailController.InsItem = item
		self.navigationController?.pushViewController(fixDetailController, animated: true)
    }
	
	@objc func btnFixedPressed(sender: CustomButton) {
		let indexPath = sender.indexPath!
		let item = placeData[indexPath.section].items[indexPath.row]
		
		if sender.tag == 0 {
			if item.picUrl.count != 0 {
				let photoView = Bundle.main.loadNibNamed(photoViewIdentifier, owner: self, options: nil)?[0] as! PhotoView
				photoView.titles = [NSLocalizedString("fixed_before", comment: "")]
				photoView.images = [item.picUrl]
				self.view.addSubview(photoView)
				photoView.frame = self.view.frame
			}
		}
		else {
			
			if item.picUrlFixed.count != 0 {
				let photoView = Bundle.main.loadNibNamed(photoViewIdentifier, owner: self, options: nil)?[0] as! PhotoView
				photoView.titles = [NSLocalizedString("fixed_after", comment: "")]
				photoView.images = [item.picUrlFixed]
				self.view.addSubview(photoView)
				photoView.frame = self.view.frame
			}
		}
	}
    
    @objc func btnBackPressed(sender: UIBarButtonItem) {
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
	
    
    @IBAction func headerSgIsFixedaValueChanged(_ sender: UISegmentedControl) {
        func btnBackPressed(sender: UIBarButtonItem) {
            self.navigationController?.popViewController(animated: true)
        }
    }
	
	
	
    
}
