//
//  InsTmpDataManager.swift
//  Home-Maintenance
//
//  Created by Bani on 2018/4/9.
//  Copyright © 2018 Ultron mobile. All rights reserved.
//

import Foundation
import SQLite
import JGProgressHUD
import VeloxDownloader

class InsTmpDataManager {
	public var dicArea: [String:[InsAreaItem]] = [:]
	public var dicItem: [String:NSMutableArray] = [:]
	public var dicFlowFinish: [String:Bool] = [:]
	public var flowIdData = [] as [String]
	public var flowNameData = [] as [String]
	private static var mInstance:InsTmpDataManager?
	public var sign0UrlStr = ""
	public var sign1UrlStr = ""
	public var sign2UrlStr = ""
    public var areaPicName:String = ""
    public var planePicName:String = ""
    var hud:JGProgressHUD?
    var upPicArr:[String] = []
	var upPicIndex = 0
    var fileIdStr = ""
    var updateUrls = [] as [String]
    var updateFileNames = [] as [String]
    var updateFileNamesUpload = [] as [String]
    var dlPicArr:[PicData] = []
    var dlIndex = 0
    var dlPicTimer = Timer()
    var updateIndex = 0
    var keepGoUpdate = false
    
	static func sharedInstance() -> InsTmpDataManager {
		if mInstance == nil {
			mInstance = InsTmpDataManager()
			
		}
		return mInstance!
	}
	
	func clearData() {
		dicArea = [:]
		dicItem = [:]
		dicFlowFinish = [:]
		flowIdData = []
		flowNameData = []
		sign0UrlStr = ""
		sign1UrlStr = ""
		sign2UrlStr = ""
	}
    
    func saveFixData() {
        do {
            UserDefaults.standard.set("Y", forKey: "NeedUpdate")
            var NeedUpdateArr:[String] = []
            if UserDefaults.standard.object(forKey: "NeedUpdateArr") != nil {
                NeedUpdateArr = UserDefaults.standard.object(forKey: "NeedUpdateArr") as! [String]
            }
            let projectsNo = UserDefaults.standard.string(forKey: "PROJECT_NO")!
            let building = UserDefaults.standard.string(forKey: "BUILDING")!
            let fileNameUpload = String.init(format: SystemConstants.DBFileNameSubUpload, projectsNo, building)
            NeedUpdateArr.append(fileNameUpload)
            UserDefaults.standard.setValue(NeedUpdateArr, forKey: "NeedUpdateArr")
            let floor = UserDefaults.standard.string(forKey: "FLOOR")!
            let copNo = UserDefaults.standard.string(forKey: "COP_NO")!
            
            let room = UserDefaults.standard.string(forKey: "ROOM")!
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
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
            let ELEVEL_2_1 = Expression<String?>("ELEVEL_2_1")
            let ELEVEL_2_2 = Expression<String?>("ELEVEL_2_2")
            let ELEVEL_1 = Expression<String?>("ELEVEL_1")
            let CheckFlowType = Expression<String?>("CheckFlowType")
            let CheckFlowItemId = Expression<String?>("CheckFlowItemId")
            let ChkNo = Expression<String?>("ChkNo")
            let AreaId = Expression<String?>("AreaId")
            let ChkInspIdx = Expression<String?>("ChkInspIdx")
       
            let COP_NO = Expression<String?>("COP_NO")
            let InspCheckFlowUploadFile = Table("InspCheckFlowUploadFile")
            let FileType = Expression<String?>("FileType")
            let FileName = Expression<String?>("FileName")
            let InspChkDtlIdx = Expression<String?>("InspChkDtlIdx")
            
            
            
            let ProjInspIdx = Expression<String?>("ProjInspIdx")
            

            let IsValid = Expression<String?>("IsValid")
            let CreateUser = Expression<String?>("CreateUser")
            let CreateTime = Expression<String?>("CreateTime")
            
            let ModifyDate = Expression<String?>("ModifyDate")
            let ModifyStatus = Expression<String?>("ModifyStatus")
            let ModifyRemark = Expression<String?>("ModifyRemark")
            let EquipFailType = Expression<String?>("EquipFailType")
            
            
            let CheckEquipType = Expression<String?>("CheckEquipType")
            let InspRemark = Expression<String?>("InspRemark")
            let EquipFailLessAmount = Expression<String?>("EquipFailLessAmount")
            let InspDescItemId = Expression<String?>("InspDescItemId")
            let Result = Expression<String?>("Result")
            
            
            
            let userId = UserDefaults.standard.string(forKey: "UserId")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSSS"
            let dateString = dateFormatter.string(from: Date())
            
            if flowIdData.count > 0 {
                for i in 1 ... flowIdData.count {
                    let flowId = flowIdData[i - 1]
                    if dicArea[flowId + "_DataArea"] == nil {
                        break
                    }
                    let areaData = dicArea[flowId + "_DataArea"]!
                    
                    for insAreaItem in areaData {
                        for item in insAreaItem.items {
                            var result = ""
                            if item.result == 0 {
                                result = "Y"
                            } else if item.result == 1 {
                                result = "N"
                            }
                  
                                
                            let target = InspCheckFlowDetail.filter(PROJM_NO == projectsNo && ELEVEL_2 == building + room && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && ChkNo == InsTargetData.sharedInstance().inspNo && CheckFlowItemId == flowId && AreaId == item.areaId && ChkInspIdx == item.fkIdx)
                            
                            try db.run(target.update(ModifyStatus <- item.isFixed, ModifyRemark <- item.commentFixed, ModifyDate <- dateString))
                            let count = try dbUpload.scalar(target.count)
                            if count != 0 {
                                try dbUpload.run(target.update(ModifyStatus <- item.isFixed, ModifyRemark <- item.commentFixed, ModifyDate <- dateString))
                            } else {
                                
                                
                                if item.amount.count != 0 && item.amount != "0"{
                                    if item.status == 0 {
                                        let insert = InspCheckFlowDetail.insert(COP_NO <- copNo, PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                                                                ChkNo <- InsTargetData.sharedInstance().inspNo, CheckFlowType <- String(i),
                                                                                CheckFlowItemId <- flowId, AreaId <- item.areaId, ChkInspIdx <- item.fkIdx,
                                                                                Result <- result, InspRemark <- item.inspRemark,
                                                                                InspDescItemId <- item.desId, EquipFailType <- "2", IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString, ModifyStatus <- item.isFixed, ModifyRemark <- item.commentFixed, ModifyDate <- dateString)
                                        try dbUpload.run(insert)
                                  
                                    } else {
                                        let insert = InspCheckFlowDetail.insert(COP_NO <- copNo, PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                                                                ChkNo <- InsTargetData.sharedInstance().inspNo, CheckFlowType <- String(i),
                                                                                CheckFlowItemId <- flowId, AreaId <- item.areaId, ChkInspIdx <- item.fkIdx,
                                                                                Result <- result, InspRemark <- item.inspRemark,
                                                                                InspDescItemId <- item.desId, EquipFailType <- "1",
                                                                                EquipFailLessAmount <- String(item.detect_amount) , IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString, ModifyStatus <- item.isFixed, ModifyRemark <- item.commentFixed, ModifyDate <- dateString)
                                        try dbUpload.run(insert)
                                      
                                    }
                                    
                                } else {
                                    let insert = InspCheckFlowDetail.insert(COP_NO <- copNo, PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                                                            ChkNo <- InsTargetData.sharedInstance().inspNo, CheckFlowType <- String(i), InspRemark <- item.inspRemark,
                                                                            InspDescItemId <- item.desId,
                                                                            CheckFlowItemId <- flowId, AreaId <- item.areaId, ChkInspIdx <- item.fkIdx,
                                                                            Result <- result , IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString, ModifyStatus <- item.isFixed, ModifyRemark <- item.commentFixed, ModifyDate <- dateString)
                                    try dbUpload.run(insert)
                                  
                                }
                                
                                
                                
                                
                            }
                            
                            
                            if item.picUrlFixed.count > 0 {
                                let query = InspCheckFlowUploadFile.filter(PROJM_NO == projectsNo && ELEVEL_2 == building + room && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor &&
                                                                           ChkNo == InsTargetData.sharedInstance().inspNo &&
                                                                           CheckFlowItemId == flowId && AreaId == item.areaId &&
                                                                           ChkInspIdx == item.fkIdx && FileType == "A")
                                let count = try db.scalar(query.count)
                                let countUp = try dbUpload.scalar(query.count)
                                if count != 0 {
                                    let target = InspCheckFlowUploadFile.filter(PROJM_NO == projectsNo && ELEVEL_2 == building + room && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor &&
                                        ChkNo == InsTargetData.sharedInstance().inspNo &&
                                        CheckFlowItemId == flowId && AreaId == item.areaId &&
                                        ChkInspIdx == item.fkIdx && FileType == "A")
                                    
                                    try db.run(target.update(FileName <- item.picUrlFixed, IsValid <- "Y"))
                                } else {
                                    let insertImg = InspCheckFlowUploadFile.insert(PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                                                                   ChkNo <- InsTargetData.sharedInstance().inspNo, CheckFlowType <- String(i),
                                                                                   CheckFlowItemId <- flowId, AreaId <- item.areaId,
                                                                                   ChkInspIdx <- item.fkIdx, FileType <- "A", FileName <- item.picUrlFixed , IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString)
                                    
                                    try db.run(insertImg)
                                }
                                if countUp != 0 {
                                    let target = InspCheckFlowUploadFile.filter(PROJM_NO == projectsNo && ELEVEL_2 == building + room && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor &&
                                        ChkNo == InsTargetData.sharedInstance().inspNo &&
                                        CheckFlowItemId == flowId && AreaId == item.areaId &&
                                        ChkInspIdx == item.fkIdx && FileType == "A")
                                    try dbUpload.run(target.update(FileName <- item.picUrlFixed, IsValid <- "Y"))
                                  
                                } else {
                                    let insertImg = InspCheckFlowUploadFile.insert(PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                                                                   ChkNo <- InsTargetData.sharedInstance().inspNo, CheckFlowType <- String(i),
                                                                                   CheckFlowItemId <- flowId, AreaId <- item.areaId,
                                                                                   ChkInspIdx <- item.fkIdx, FileType <- "A", FileName <- item.picUrlFixed , IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString)
                                    try dbUpload.run(insertImg)
                            
                                }
                                
                                
                            }
                        }
                    }
                }
            }
            
            
            
            
            let InspDetail = Table("InspDetail")
            let InspUploadFile = Table("InspUploadFile")
            let InspPlaceId = Expression<String?>("InspPlaceId")
           
            let SeqNo = Expression<String?>("SeqNo")
            
            let areaData = dicArea["Ins_DataArea"]!
            for insAreaItem in areaData {
                for insPlaceItem in insAreaItem.places {
                    for item in insPlaceItem.items {
                        var result = ""
                        if item.result == 0 {
                            result = "Y"
                        } else if item.result == 1 {
                            result = "N"
                        }
                        
                        var target = InspDetail.filter(PROJM_NO == projectsNo && ELEVEL_2 == building + room && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor &&
                            ChkNo == InsTargetData.sharedInstance().inspNo && AreaId == item.areaId &&
                            ProjInspIdx == (item.fkIdx == "" ? nil : item.fkIdx) && SeqNo == (item.seqNo == "" ? nil : item.seqNo))
                        if item.seqNo == "" {
                            target = InspDetail.filter(PROJM_NO == projectsNo && ELEVEL_2 == building + room && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor &&
                                ChkNo == InsTargetData.sharedInstance().inspNo && AreaId == item.areaId &&
                                ProjInspIdx == item.fkIdx)
                        } else {
                            target = InspDetail.filter(PROJM_NO == projectsNo && ELEVEL_2 == building + room && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor &&
                                ChkNo == InsTargetData.sharedInstance().inspNo && AreaId == item.areaId && SeqNo == item.seqNo)
                        }
                        try db.run(target.update(ModifyStatus <- item.isFixed, ModifyRemark <- item.commentFixed, ModifyDate <- dateString))
                        let count = try dbUpload.scalar(target.count)
                        if count != 0 {
                             try dbUpload.run(target.update(ModifyStatus <- item.isFixed, ModifyRemark <- item.commentFixed, ModifyDate <- dateString))
                        } else {
                            
                            if item.fkIdx != "" {
                                let insert = InspDetail.insert(COP_NO <- copNo, PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                                               ChkNo <- InsTargetData.sharedInstance().inspNo,
                                                               AreaId <- item.areaId, ProjInspIdx <- item.fkIdx,
                                                               Result <- result, InspRemark <- item.inspRemark,
                                                               CheckEquipType <- item.CheckEquipType, EquipFailLessAmount <- String(item.detect_amount),
                                                               InspDescItemId <- item.desId, InspPlaceId <- item.placeId , IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString, ModifyStatus <- item.isFixed, ModifyRemark <- item.commentFixed, ModifyDate <- dateString)
                                
                                try dbUpload.run(insert)
                            } else {
                                let insert = InspDetail.insert(COP_NO <- copNo, PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                                               ChkNo <- InsTargetData.sharedInstance().inspNo,
                                                               AreaId <- item.areaId, SeqNo <- item.seqNo,
                                                               Result <- result, InspPlaceId <- item.placeId, InspRemark <- item.inspRemark,
                                                               InspDescItemId <- item.desId, IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString, ModifyStatus <- item.isFixed, ModifyRemark <- item.commentFixed, ModifyDate <- dateString)
                                try dbUpload.run(insert)
                            }
                            
                           
                            
                        }

                        
                       
                        
                        
                        if item.picUrlFixed.count > 0 {
                            
                            let query = InspUploadFile.filter(PROJM_NO == projectsNo && ELEVEL_2 == building + room && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor &&
                                                              ChkNo == InsTargetData.sharedInstance().inspNo &&
                                                              AreaId == item.areaId && ProjInspIdx == item.fkIdx && InspPlaceId == item.placeId && FileType == "A")
                            let count = try db.scalar(query.count)
                            let countUp = try dbUpload.scalar(query.count)
                            if count != 0 {
                                let target = InspUploadFile.filter(PROJM_NO == projectsNo && ELEVEL_2 == building + room && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor &&
                                    ChkNo == InsTargetData.sharedInstance().inspNo &&
                                    AreaId == item.areaId && ProjInspIdx == item.fkIdx && InspPlaceId == item.placeId && FileType == "A")
                                
                                try db.run(target.update(FileName <- item.picUrlFixed, IsValid <- "Y"))
                                
                            } else {
                                if item.fkIdx != "" {
                                    let insertImg = InspUploadFile.insert(PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                                                          ChkNo <- InsTargetData.sharedInstance().inspNo,
                                                                          AreaId <- item.areaId, ProjInspIdx <- item.fkIdx, InspPlaceId <- item.placeId,
                                                                          FileType <- "A", FileName <- item.picUrlFixed, IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString)
                                    
                                    try db.run(insertImg)
                                } else {
                                    let insertImg = InspUploadFile.insert(PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                                                          ChkNo <- InsTargetData.sharedInstance().inspNo,
                                                                          AreaId <- item.areaId, InspPlaceId <- item.placeId,
                                                                          FileType <- "A", FileName <- item.picUrlFixed, IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString, SeqNo <- item.seqNo)
                                    
                                    try db.run(insertImg)
                                    
                                    
                                }
                                
                            }
                            if countUp != 0 {
                                let target = InspUploadFile.filter(PROJM_NO == projectsNo && ELEVEL_2 == building + room && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor &&
                                    ChkNo == InsTargetData.sharedInstance().inspNo &&
                                    AreaId == item.areaId && ProjInspIdx == item.fkIdx && InspPlaceId == item.placeId && FileType == "A")
                                try dbUpload.run(target.update(FileName <- item.picUrlFixed, IsValid <- "Y"))
                              
                                
                            } else {
                                let insertImg = InspUploadFile.insert(PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                                                      ChkNo <- InsTargetData.sharedInstance().inspNo,
                                                                      AreaId <- item.areaId, ProjInspIdx <- item.fkIdx, InspPlaceId <- item.placeId,
                                                                      FileType <- "A", FileName <- item.picUrlFixed, IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString, SeqNo <- item.seqNo)
                                try dbUpload.run(insertImg)
                             
                            }
                        }
                    }
                }
            }
            
            
            
            
            let InspMaster = Table("InspMaster")
            let InspMstIdx = Expression<String?>("InspMstIdx")
            
            let InspNo = Expression<String?>("InspNo")
        
            let RepairsDate = Expression<String?>("RepairsDate")
            
           
            
            let query = InspMaster.select(ELEVEL_2_1).filter(PROJM_NO == projectsNo && ELEVEL_2 == building + room && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && InspNo == InsTargetData.sharedInstance().inspNo)
            let count = try db.scalar(query.count)
            let countUp = try dbUpload.scalar(query.count)
            if count != 0 {
                let target = InspMaster.filter(InspMstIdx == InsTargetData.sharedInstance().inspMstIdx)
                try db.run(target.update(RepairsDate <- dateString))

                
            }
            
            if countUp != 0 {
                let target = InspMaster.filter(InspMstIdx == InsTargetData.sharedInstance().inspMstIdx)

                try dbUpload.run(target.update(RepairsDate <- dateString))
                
            }
            
            
        } catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
	
	func saveData() {
		do {
            
            UserDefaults.standard.set("Y", forKey: "NeedUpdate")
            var NeedUpdateArr:[String] = []
            if UserDefaults.standard.object(forKey: "NeedUpdateArr") != nil {
                NeedUpdateArr = UserDefaults.standard.object(forKey: "NeedUpdateArr") as! [String]
            }
            let recordType = UserDefaults.standard.integer(forKey: "CHARACTER_INDEX")
            let recordTypeStr = String(format: "%d", recordType)
			let projectsNo = UserDefaults.standard.string(forKey: "PROJECT_NO")!
            let copNo = UserDefaults.standard.string(forKey: "COP_NO")!
			let building = UserDefaults.standard.string(forKey: "BUILDING")!
            let fileNameUpload = String.init(format: SystemConstants.DBFileNameSubUpload, projectsNo, building)
            NeedUpdateArr.append(fileNameUpload)
            UserDefaults.standard.setValue(NeedUpdateArr, forKey: "NeedUpdateArr")
            let floor = UserDefaults.standard.string(forKey: "FLOOR")!
            
            
            let room = UserDefaults.standard.string(forKey: "ROOM")!
			let fileManager = FileManager.default
			let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
			let fileURLUpload = documentDirectory.appendingPathComponent(fileNameUpload)
			let fileName = String.init(format: SystemConstants.DBFileNameSub, projectsNo, building)
			let fileURL = documentDirectory.appendingPathComponent(fileName)
			
			
			let dbUpload = try Connection(fileURLUpload.absoluteString)
			let db = try Connection(fileURL.absoluteString)
			
			let InspCheckFlowDetail = Table("InspCheckFlowDetail")
			let COP_NO = Expression<String?>("COP_NO")
			let PROJM_NO = Expression<String?>("PROJM_NO")
			//let PROJS_NO = Expression<String?>("PROJS_NO")
			let ELEVEL_2 = Expression<String?>("ELEVEL_2")
            let ELEVEL_2_1 = Expression<String?>("ELEVEL_2_1")
            let ELEVEL_2_2 = Expression<String?>("ELEVEL_2_2")
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
            let CreateUser = Expression<String?>("CreateUser")
            let CreateTime = Expression<String?>("CreateTime")
            let InspRemark = Expression<String?>("InspRemark")
            let InspDescItemId = Expression<String?>("InspDescItemId")
			
            let userId = UserDefaults.standard.string(forKey: "UserId")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSSS"
            let dateString = dateFormatter.string(from: Date())
			let InspDetail = Table("InspDetail")
            
            if InsTargetData.sharedInstance().reinspection == "ALL" || InsTargetData.sharedInstance().reinspection == "Y" {
                let target = InspCheckFlowDetail.filter(COP_NO == copNo && PROJM_NO == projectsNo && ELEVEL_2 == building + room && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor &&
                                                        ChkNo == InsTargetData.sharedInstance().inspNo)
                try dbUpload.run(target.delete())
                try db.run(target.delete())
                let targetIns = InspDetail.filter(COP_NO == copNo && PROJM_NO == projectsNo && ELEVEL_2 == building + room && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor &&
                    ChkNo == InsTargetData.sharedInstance().inspNo)
                try db.run(targetIns.delete())
                try dbUpload.run(targetIns.delete())
                
            }
            
            
            if flowIdData.count > 0 {
                for i in 1 ... flowIdData.count {
                    let flowId = flowIdData[i - 1]
                    if dicArea[flowId + "_DataArea"] == nil {
                        break
                    }
                    let areaData = dicArea[flowId + "_DataArea"]!
                    
                    for insAreaItem in areaData {
                        for item in insAreaItem.items {
                            var result = ""
                            if item.result == 0 {
                                result = "Y"
                            } else if item.result == 1 {
                                result = "N"
                            }
                            if item.amount.count != 0 && item.amount != "0"{
                                if item.status == 0 {
                                    let insert = InspCheckFlowDetail.insert(COP_NO <- copNo, PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                                                            ChkNo <- InsTargetData.sharedInstance().inspNo, CheckFlowType <- String(i),
                                                                            CheckFlowItemId <- flowId, AreaId <- item.areaId, ChkInspIdx <- item.fkIdx,
                                                                            Result <- result, InspRemark <- item.inspRemark,
                                                                            InspDescItemId <- item.desId, EquipFailType <- "2", IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString)
                                    try dbUpload.run(insert)
                                    try db.run(insert)
                                } else {
                                    let insert = InspCheckFlowDetail.insert(COP_NO <- copNo, PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                                                            ChkNo <- InsTargetData.sharedInstance().inspNo, CheckFlowType <- String(i),
                                                                            CheckFlowItemId <- flowId, AreaId <- item.areaId, ChkInspIdx <- item.fkIdx,
                                                                            Result <- result, InspRemark <- item.inspRemark,
                                                                            InspDescItemId <- item.desId, EquipFailType <- "1",
                                                                            EquipFailLessAmount <- String(item.detect_amount) , IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString)
                                    try dbUpload.run(insert)
                                    try db.run(insert)
                                }
                                
                            } else {
                                let insert = InspCheckFlowDetail.insert(COP_NO <- copNo, PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                                                        ChkNo <- InsTargetData.sharedInstance().inspNo, CheckFlowType <- String(i), InspRemark <- item.inspRemark,
                                                                        InspDescItemId <- item.desId, 
                                                                        CheckFlowItemId <- flowId, AreaId <- item.areaId, ChkInspIdx <- item.fkIdx,
                                                                        Result <- result , IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString)
                                try dbUpload.run(insert)
                                try db.run(insert)
                            }
                            
                            
                            if item.picUrl.count > 0 {
                                let insertImg = InspCheckFlowUploadFile.insert(COP_NO <- copNo, PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                                                               ChkNo <- InsTargetData.sharedInstance().inspNo, CheckFlowType <- String(i),
                                                                               CheckFlowItemId <- flowId, AreaId <- item.areaId,
                                                                               ChkInspIdx <- item.fkIdx, FileType <- "B", FileName <- item.picUrl , IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString)
                                try dbUpload.run(insertImg)
                                try db.run(insertImg)
                            }
                        }
                    }
                }
            }
            
			
			
			
			
			let InspUploadFile = Table("InspUploadFile")
			let InspPlaceId = Expression<String?>("InspPlaceId")
            let CheckEquipType = Expression<String?>("CheckEquipType")
            
            let SeqNo = Expression<String?>("SeqNo")
			
            var areaData = dicArea["Ins_DataArea"]!
            var i = 0
            for insAreaItem in areaData {
                for insPlaceItem in insAreaItem.places {
                    for item in insPlaceItem.items {
                        var result = ""
                        if item.result == 0 {
                            result = "Y"
                        } else if item.result == 1 {
                            result = "N"
                        }
                        if item.fkIdx != "" {
                            let insert = InspDetail.insert(COP_NO <- copNo, PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                                           ChkNo <- InsTargetData.sharedInstance().inspNo,
                                                           AreaId <- item.areaId, ProjInspIdx <- item.fkIdx,
                                                           Result <- result, InspRemark <- item.inspRemark,
                                                           CheckEquipType <- item.CheckEquipType, EquipFailLessAmount <- String(item.detect_amount), 
                                                           InspDescItemId <- item.desId, InspPlaceId <- item.placeId , IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString)
                            
                            try dbUpload.run(insert)
                            try db.run(insert)
                            if item.picUrl.count > 0 {
                                let insertImg = InspUploadFile.insert(COP_NO <- copNo, PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                                                      ChkNo <- InsTargetData.sharedInstance().inspNo,
                                                                      AreaId <- item.areaId, ProjInspIdx <- item.fkIdx, InspPlaceId <- item.placeId,
                                                                      FileType <- "B", FileName <- item.picUrl, IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString, SeqNo <- item.seqNo)
                                try dbUpload.run(insertImg)
                                try db.run(insertImg)
                            }
                        } else {
                            let insert = InspDetail.insert(COP_NO <- copNo, PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                                           ChkNo <- InsTargetData.sharedInstance().inspNo,
                                                           AreaId <- item.areaId, SeqNo <- String(i),
                                                           Result <- result, InspPlaceId <- item.placeId, InspRemark <- item.inspRemark,
                                                           InspDescItemId <- item.desId, IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString)
                            try dbUpload.run(insert)
                            try db.run(insert)
                            
                            if item.picUrl.count > 0 {
                                let insertImg = InspUploadFile.insert(COP_NO <- copNo, PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                                                      ChkNo <- InsTargetData.sharedInstance().inspNo,
                                                                      AreaId <- item.areaId, InspPlaceId <- item.placeId,
                                                                      ProjInspIdx <- "", SeqNo <- String(i), FileType <- "B",
                                                                      FileName <- item.picUrl, IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString)
                                try dbUpload.run(insertImg)
                                try db.run(insertImg)
                            }
                            i += 1
                        }
                        
                    }
                }
            }
			
			
            if dicArea["Add_DataArea"] != nil {
                areaData = dicArea["Add_DataArea"]!
                
                for insAreaItem in areaData {
                    for insPlaceItem in insAreaItem.places {
                        for item in insPlaceItem.items {
                            var result = ""
                            if item.result == 0 {
                                result = "Y"
                            } else if item.result == 1 {
                                result = "N"
                            }
                            let insert = InspDetail.insert(COP_NO <- copNo, PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                                           ChkNo <- InsTargetData.sharedInstance().inspNo,
                                                           AreaId <- item.areaId, SeqNo <- String(i),
                                                           Result <- result, InspPlaceId <- item.placeId, InspRemark <- item.inspRemark,
                                                           InspDescItemId <- item.desId, IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString)
                            try dbUpload.run(insert)
                            try db.run(insert)
                            
                            if item.picUrl.count > 0 {
                                let insertImg = InspUploadFile.insert(COP_NO <- copNo, PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                                                      ChkNo <- InsTargetData.sharedInstance().inspNo,
                                                                      AreaId <- item.areaId, InspPlaceId <- item.placeId,
                                                                      ProjInspIdx <- "", SeqNo <- String(i), FileType <- "B",
                                                                      FileName <- item.picUrl, IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString)
                                try dbUpload.run(insertImg)
                                try db.run(insertImg)
                            }
                            i += 1
                        }
                    }
                }
            }
			
			let InspSignUploadFile = Table("InspSignUploadFile")
			let INSP_DATE = Expression<String?>("INSP_DATE")
			
			if sign0UrlStr.count != 0 {
				
				let insertSign = InspSignUploadFile.insert(COP_NO <- copNo, PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
														ChkNo <- InsTargetData.sharedInstance().inspNo,
														FileType <- "0", FileName <- sign0UrlStr, INSP_DATE <- InsTargetData.sharedInstance().inspDate, IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString)
				try dbUpload.run(insertSign)
				try db.run(insertSign)
			}
			
			if sign1UrlStr.count != 0 {
				
				let insertSign = InspSignUploadFile.insert(COP_NO <- copNo, PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
														   ChkNo <- InsTargetData.sharedInstance().inspNo,
														   FileType <- "1", FileName <- sign1UrlStr, INSP_DATE <- InsTargetData.sharedInstance().inspDate, IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString)
				try dbUpload.run(insertSign)
				try db.run(insertSign)
			}
			
			if sign2UrlStr.count != 0 {
				
				let insertSign = InspSignUploadFile.insert(COP_NO <- copNo, PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
														   ChkNo <- InsTargetData.sharedInstance().inspNo,
														   FileType <- "2", FileName <- sign2UrlStr, INSP_DATE <- InsTargetData.sharedInstance().inspDate, IsValid <- "Y", CreateUser <- userId, CreateTime <- dateString)
				try dbUpload.run(insertSign)
				try db.run(insertSign)
			}
            
			
            let InspMaster = Table("InspMaster")
            let InspMstIdx = Expression<String?>("InspMstIdx")
            let RepairStatus = Expression<String?>("RepairStatus")
            let RecordType = Expression<String?>("RecordType")
            let InspNo = Expression<String?>("InspNo")
            let UpdateUser = Expression<String?>("UpdateUser")
            let UpdateTime = Expression<String?>("UpdateTime")
            let BookingDate = Expression<String?>("BookingDate")
            
            let insertUploadPre = InspMaster.insert(COP_NO <- copNo, PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                                 InspNo <- String(Int(InsTargetData.sharedInstance().inspNo)! - 1), RepairStatus <- "Y",
                                                 InspMstIdx <- InsTargetData.sharedInstance().inspMstIdx, IsValid <- "N",
                                                 UpdateUser <- userId, UpdateTime <- dateString, INSP_DATE <- InsTargetData.sharedInstance().inspDate, RecordType <- recordTypeStr , BookingDate <- InsTargetData.sharedInstance().date)
            
            let insertUpload = InspMaster.insert(COP_NO <- copNo, PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                           InspNo <- InsTargetData.sharedInstance().inspNo, RepairStatus <- "Y",
                                            InspMstIdx <- InsTargetData.sharedInstance().inspMstIdx, IsValid <- "Y",
                                           UpdateUser <- userId, UpdateTime <- dateString, INSP_DATE <- InsTargetData.sharedInstance().inspDate, RecordType <- recordTypeStr , BookingDate <- InsTargetData.sharedInstance().date)
            
            let insertUploadNew = InspMaster.insert(COP_NO <- copNo, PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                                 InspNo <- InsTargetData.sharedInstance().inspNo, RepairStatus <- "Y",
                                                 InspMstIdx <- "", IsValid <- "Y",
                                                 UpdateUser <- userId, UpdateTime <- dateString, INSP_DATE <- InsTargetData.sharedInstance().inspDate, RecordType <- recordTypeStr , BookingDate <- InsTargetData.sharedInstance().date)
            
            
            
            
            let insert = InspMaster.insert(COP_NO <- copNo, PROJM_NO <- projectsNo, ELEVEL_2 <- building + room, ELEVEL_2_1 <- building, ELEVEL_2_2 <- room, ELEVEL_1 <- floor,
                                           InspNo <- InsTargetData.sharedInstance().inspNo, RepairStatus <- "Y",
                                           InspMstIdx <- InsTargetData.sharedInstance().inspMstIdx, IsValid <- "Y",
                                           UpdateUser <- userId, UpdateTime <- dateString, INSP_DATE <- InsTargetData.sharedInstance().inspDate, RecordType <- recordTypeStr , BookingDate <- InsTargetData.sharedInstance().date)
            InspMstIdx
            
            if Int(InsTargetData.sharedInstance().inspNo)! > 1{
                let inspNo = Int(InsTargetData.sharedInstance().inspNo)! - 1
                let query = InspMaster.select(ELEVEL_2_1).filter(PROJM_NO == projectsNo && ELEVEL_2 == building + room && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && InspNo == String(inspNo))
                let count = try dbUpload.scalar(query.count)
                if count != 0 {
                    let target = InspMaster.filter(PROJM_NO == projectsNo && ELEVEL_2 == building + room && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && InspNo == String(inspNo))
                    try dbUpload.run(target.update(IsValid <- "N"))
                    
                } else {
                    try dbUpload.run(insertUploadPre)
                    
                }
            }
            
            let query = InspMaster.select(ELEVEL_2_1).filter(PROJM_NO == projectsNo && ELEVEL_2 == building + room && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && InspNo == InsTargetData.sharedInstance().inspNo)
            let count = try db.scalar(query.count)
            if count != 0 {
                let target = InspMaster.filter(InspMstIdx == InsTargetData.sharedInstance().inspMstIdx)
                try db.run(target.update(RepairStatus <- "Y", InspNo <- InsTargetData.sharedInstance().inspNo, UpdateUser <- userId, UpdateTime <- dateString))
                //try dbUpload.run(target.update(RepairStatus <- "Y", InspNo <- InsTargetData.sharedInstance().inspNo, UpdateUser <- userId, UpdateTime <- dateString))
                let countUp = try dbUpload.scalar(query.count)
                if countUp != 0 {
                    let target = InspMaster.filter(InspMstIdx == InsTargetData.sharedInstance().inspMstIdx)
                    
                    try dbUpload.run(target.update(RepairStatus <- "Y", InspNo <- InsTargetData.sharedInstance().inspNo, UpdateUser <- userId, UpdateTime <- dateString))
                    
                } else {
                    try dbUpload.run(insertUpload)
                    
                }
                
            } else {
                //try dbUpload.run(insertUploadNew)
                if Int(InsTargetData.sharedInstance().inspNo)! > 1{
                    let inspNo = Int(InsTargetData.sharedInstance().inspNo)! - 1
                    let query = InspMaster.select(ELEVEL_2_1).filter(PROJM_NO == projectsNo && ELEVEL_2 == building + room && ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && InspNo == String(inspNo))
                    let count = try db.scalar(query.count)
                    if count != 0 {
                        let target = InspMaster.filter(InspMstIdx == InsTargetData.sharedInstance().inspMstIdx)
                        try db.run(target.update(IsValid <- "N"))
                        
                    }
                }
                try db.run(insert)
            }
            
           
          
            
			
		} catch let error as NSError {
			print("Ooops! Something went wrong: \(error)")
		}
	}
    
    func clearUploadDBIndex() {
        do {
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileName = updateFileNamesUpload[updateIndex]
            let fileURLUpload = documentDirectory.appendingPathComponent(fileName)
            let db = try Connection(fileURLUpload.absoluteString)
            for tableName in DBHelper.ClearTables {
                let clear_table = Table(tableName)
                try db.run(clear_table.delete())
            }
        } catch {
            print(error)
        }
    }
    
    func clearUploadDB() {
        do {
            UserDefaults.standard.removeObject(forKey: "NeedUpdate")
            UserDefaults.standard.removeObject(forKey: "NeedUpdateArr")
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let projectsNo = UserDefaults.standard.string(forKey: "PROJECT_NO")!
            let building = UserDefaults.standard.string(forKey: "BUILDING")!
            let fileName = String.init(format: SystemConstants.DBFileNameSub, projectsNo, building)
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            
            let fileNameUpload = String.init(format: SystemConstants.DBFileNameSubUpload, projectsNo, building)
            let fileURLUpload = documentDirectory.appendingPathComponent(fileNameUpload)
            do {
                try fileManager.removeItem(at: fileURLUpload)
                print("Existing file deleted.")
            } catch {
                print("Failed to delete existing file:\n\((error as NSError).description)")
            }
            try fileManager.copyItem(at: fileURL, to: fileURLUpload)
            
            let db = try Connection(fileURLUpload.absoluteString)
            for tableName in DBHelper.DeleteTables {
                let drop_table = Table(tableName)
                try db.run(drop_table.drop(ifExists: true))
            }
            for tableName in DBHelper.ClearTables {
                let clear_table = Table(tableName)
                try db.run(clear_table.delete())
            }
        } catch {
            print(error)
        }
    }
    
    func uploadSqlDBUpdate(_ fileName:String, view:UIView) {
        keepGoUpdate = true
        uploadSqlDB(fileName, view:view)
    }
    
    func uploadSqlDB(_ fileName:String, view:UIView) {
        
            hud = JGProgressHUD(style: .dark)
            hud?.vibrancyEnabled = true
            hud?.textLabel.text = "上傳檔案準備中..."
            hud?.detailTextLabel.text = fileName
            hud?.show(in: view)
            hud?.dismiss(afterDelay: 2)
        
        let myUrl = URL.init(string: URLConstants.UploadSqlite)
        let request = NSMutableURLRequest(url:myUrl!)
        request.httpMethod = "POST"
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let param:[String:String] = [:]
        
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            let dbData = FileManager.default.contents(atPath: fileURL.path)
            
            


            request.httpBody = createBodyWithParameters(fileName: "upload.db", fileType: 0, parameters: param, filePathKey: "db", imageDataKey: NSData.init(data: dbData!), boundary: boundary) as Data
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                data, response, error in
                
                
                if error != nil {
                    
                    print("error=\(error)")
                    return
                }
                
                // You can print out response object
                print("******* response = \(response)")
                
                // Print out reponse body
                let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                if responseString != nil {
                    print("****** response data = \(responseString!)")
                }
                

                DispatchQueue.main.sync {
                    if self.hud != nil {
                        self.hud?.dismiss()
                    }
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                        print(json)
                        let idStr = json?.object(forKey: "id") as? String
                        
                        if idStr == nil {
                            if self.hud != nil {
                                self.hud?.dismiss()
                            }
                            return
                        }
                        self.fileIdStr = idStr!
                        print(idStr)
                        
                        let status = json?.object(forKey: "status") as? String
                        if status == "3000" {
                            if self.hud != nil {
                                self.hud?.dismiss()
                            }
                            //2019/12/07
                            /*if(self.keepGoUpdate) {
                                self.keepGoUpdate = false
                                self.goUpdate()
                                return
                            }*/
                            var NeedUpdateArr:[String] = []
                            if UserDefaults.standard.object(forKey: "NeedUpdateArr") != nil {
                                NeedUpdateArr = UserDefaults.standard.object(forKey: "NeedUpdateArr") as! [String]
                            }
                            var NeedUpdateArrIndex = UserDefaults.standard.integer(forKey: "NeedUpdateArrIndex")
                            NeedUpdateArrIndex += 1
                            if NeedUpdateArrIndex >= NeedUpdateArr.count {
                                UserDefaults.standard.set(0, forKey: "NeedUpdateArrIndex")
                                let alert = UIAlertController(title: "", message: "上傳完成", preferredStyle: UIAlertControllerStyle.alert)
                                
                                alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
                                    
                                }))
                                //2019/12/07
                                //self.clearUploadDB()
                                let delegate = UIApplication.shared.delegate as? AppDelegate
                                delegate?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                                
                            } else {
                                UserDefaults.standard.set(NeedUpdateArrIndex, forKey: "NeedUpdateArrIndex")
                                self.uploadSqlDB(NeedUpdateArr[NeedUpdateArrIndex], view: view)
                            }
                            return
                            
                        } else if status == "0000" {
                            let fileInfo = json!["fileInfo"] as? NSDictionary
                            let fileAll = fileInfo!["fileAll"] as? Int
                            if fileAll == 0 {
                                if self.hud != nil {
                                    self.hud?.dismiss()
                                }
                                //2019/12/07
                                /*if(self.keepGoUpdate) {
                                    self.keepGoUpdate = false
                                    self.goUpdate()
                                    return
                                }*/
                                var NeedUpdateArr:[String] = []
                                if UserDefaults.standard.object(forKey: "NeedUpdateArr") != nil {
                                    NeedUpdateArr = UserDefaults.standard.object(forKey: "NeedUpdateArr") as! [String]
                                }
                                var NeedUpdateArrIndex = UserDefaults.standard.integer(forKey: "NeedUpdateArrIndex")
                                NeedUpdateArrIndex += 1
                                if NeedUpdateArrIndex >= NeedUpdateArr.count {
                                    UserDefaults.standard.set(0, forKey: "NeedUpdateArrIndex")
                                    let alert = UIAlertController(title: "", message: "上傳完成", preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
                                        
                                    }))
                                    //2019/12/07
                                    //self.clearUploadDB()
                                    let delegate = UIApplication.shared.delegate as? AppDelegate
                                    delegate?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                                    
                                } else {
                                    UserDefaults.standard.set(NeedUpdateArrIndex, forKey: "NeedUpdateArrIndex")
                                    self.uploadSqlDB(NeedUpdateArr[NeedUpdateArrIndex], view: view)
                                }
                                return
                            }
                            let fileNotUploaded = fileInfo!["fileNotUploaded"] as? [NSDictionary]
                            self.upPicArr = []
                            self.upPicIndex = 0
                            for file in fileNotUploaded! {
                                print(file["FileName"]!)
                                self.upPicArr.append(file["FileName"]! as! String)
                            }
                            
                            if self.hud != nil {
                                self.hud?.dismiss()
                                self.hud = JGProgressHUD(style: .dark)
                                self.hud?.indicatorView = JGProgressHUDPieIndicatorView()
                                self.hud?.detailTextLabel.text = String.init(format: "%d/%d", self.upPicIndex, self.upPicArr.count)
                                self.hud?.textLabel.text = "圖片上傳中..."
                                self.hud?.show(in: view)
                            }
                            if self.upPicIndex < self.upPicArr.count {
                                self.uploadPic(self.upPicArr[self.upPicIndex], dbId: idStr!, view: view)
                            }
                        } else {
                            if self.hud != nil {
                                self.hud?.dismiss()
                            }
                            if(self.keepGoUpdate) {
                                self.keepGoUpdate = false
                             
                            }
                            let alert = UIAlertController(title: "", message: "上傳發生錯誤", preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
                                
                            }))
                            let delegate = UIApplication.shared.delegate as? AppDelegate
                            delegate?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                        }
                    } catch {
                        print(error)
                        if self.hud != nil {
                            self.hud?.dismiss()
                        }
                        if(self.keepGoUpdate) {
                           self.keepGoUpdate = false
                            
                        }
                        let alert = UIAlertController(title: "", message: "上傳發生錯誤", preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
                            
                        }))
                        let delegate = UIApplication.shared.delegate as? AppDelegate
                        delegate?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }
                
            }
            task.resume()
        }catch {
            if self.hud != nil {
                self.hud?.dismiss()
            }
        }
    }
    
    func uploadPic(_ fileName:String, dbId:String, view:UIView) {
        
       print(fileName)
        let myUrl = URL.init(string: URLConstants.UploadPic + dbId)
        let request = NSMutableURLRequest(url:myUrl!)
        request.httpMethod = "POST"
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let param:[String:String] = [:]
        
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            if fileManager.fileExists(atPath: fileURL.path) {
                let imageData = NSData.init(contentsOf: fileURL)
                request.httpBody = createBodyWithParameters(fileName: fileName, fileType: 1, parameters: param, filePathKey: "pic", imageDataKey: imageData!, boundary: boundary) as Data
            } else {
                return
            }
 
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                data, response, error in
                
                if error != nil {
                    //print("error=\(error)")
                    return
                }
                
                // You can print out response object
                //print("******* response = \(response)")
                
                // Print out reponse body
                DispatchQueue.main.sync {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                         print(json)
                        let status = json?.object(forKey: "status") as? String
                        if status == "3000" {
                            if self.hud != nil {
                                self.hud?.dismiss()
                            }
                            //2019/12/07
                            /*if(self.keepGoUpdate) {
                                self.keepGoUpdate = false
                                self.goUpdate()
                                return
                            }*/
                            var NeedUpdateArr:[String] = []
                            if UserDefaults.standard.object(forKey: "NeedUpdateArr") != nil {
                                NeedUpdateArr = UserDefaults.standard.object(forKey: "NeedUpdateArr") as! [String]
                            }
                            var NeedUpdateArrIndex = UserDefaults.standard.integer(forKey: "NeedUpdateArrIndex")
                            NeedUpdateArrIndex += 1
                            if NeedUpdateArrIndex >= NeedUpdateArr.count {
                                UserDefaults.standard.set(0, forKey: "NeedUpdateArrIndex")
                                let alert = UIAlertController(title: "", message: "上傳完成", preferredStyle: UIAlertControllerStyle.alert)
                                
                                alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
                                    
                                }))
                                //2019/12/07
                                //self.clearUploadDB()
                                let delegate = UIApplication.shared.delegate as? AppDelegate
                                delegate?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                                
                            } else {
                                UserDefaults.standard.set(NeedUpdateArrIndex, forKey: "NeedUpdateArrIndex")
                                self.uploadSqlDB(NeedUpdateArr[NeedUpdateArrIndex], view: view)
                            }
                            return
                        } else if status == "0000" {
                            
                            self.upPicIndex += 1
                            self.hud?.indicatorView = JGProgressHUDPieIndicatorView()
                            self.hud?.detailTextLabel.text = String.init(format: "%d/%d", self.upPicIndex, self.upPicArr.count)
                            self.hud?.textLabel.text = "圖片上傳中..."
                            if self.upPicIndex < self.upPicArr.count {
                                self.uploadPic(self.upPicArr[self.upPicIndex], dbId: self.fileIdStr, view: view)
                            }
                            
                        } else {
                            if self.hud != nil {
                                self.hud?.dismiss()
                            }
                            if(self.keepGoUpdate) {
                                self.keepGoUpdate = false
                            
                            }
                            //let alert = UIAlertController(title: "", message: "上傳發生錯誤", preferredStyle: UIAlertControllerStyle.alert)
                            let alert = UIAlertController(title: "", message: String(format: "上傳結束(%@)", status!), preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
                                
                            }))
                            let delegate = UIApplication.shared.delegate as? AppDelegate
                            delegate?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                        }
                        
                    } catch {
                        if self.hud != nil {
                            self.hud?.dismiss()
                        }
                        print(error)
                        if(self.keepGoUpdate) {
                            self.keepGoUpdate = false
                        }
                        //let alert = UIAlertController(title: "", message: "上傳發生錯誤", preferredStyle: UIAlertControllerStyle.alert)
                        let alert = UIAlertController(title: "", message: "上傳結束!", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
                            
                        }))
                        let delegate = UIApplication.shared.delegate as? AppDelegate
                        delegate?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }
               
                
            }
            task.resume()
        }catch {
            if self.hud != nil {
                self.hud?.dismiss()
            }
            let alert = UIAlertController(title: "", message: "上傳結束!!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
                
            }))
        }
    }
    
    func createBodyWithParameters(fileName: String?, fileType: Int, parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        var mimetype = "application/x-sqlite3"
        if fileType == 1 {
            mimetype = "image/png"
        }
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(fileName!)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    
    
    func goUpdate() {
        UserDefaults.standard.removeObject(forKey: "NeedUpdate")
        let userDefaults = UserDefaults.standard
        if userDefaults.dictionary(forKey: "downloadSqlite") != nil {
            var downloadSqlite = [:] as [String:[String]]
            downloadSqlite = userDefaults.dictionary(forKey: "downloadSqlite") as! [String : [String]]
            updateUrls = []
            updateFileNames = []
            updateFileNamesUpload = []
            dlPicArr = []
            dlIndex = 0
            updateIndex = 0
            for key in downloadSqlite.keys {
                let buildings = downloadSqlite[key]
                for building in buildings! {
                    let urlString = String.init(format: "%@?PROJM_NO=%@&ELEVEL_2=%@&ELEVEL_1=%@", URLConstants.DownloadDBSub, key, building, "all")
                    let fileName = String.init(format: SystemConstants.DBFileNameSub, key, building)
                    let fileNameUpload = String.init(format: SystemConstants.DBFileNameSubUpload, key, building)
                    updateUrls.append(urlString)
                    updateFileNames.append(fileName)
                    
                    updateFileNamesUpload.append(fileNameUpload)
                }
                
            }
            print(updateUrls)
            if updateUrls.count > 0 {
                loadDB()
            }
        }
    }
    
    func loadPic(_ dbName:String) {
        
        dlIndex = 0
        do {
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let subFileURL = documentDirectory.appendingPathComponent(dbName)
            let db = try Connection(subFileURL.absoluteString)
            let ProjectAreaMst = Table("ProjectAreaMst")
            let FileUrl = Expression<String?>("FileUrl")
            let FileName = Expression<String?>("FileName")
            let AreaFileUrl = Expression<String?>("AreaFileUrl")
            let AreaFileName = Expression<String?>("AreaFileName")
            let PlaneFileUrl = Expression<String?>("PlaneFileUrl")
            let PlaneFileName = Expression<String?>("PlaneFileName")
            
            var query = ProjectAreaMst.select(AreaFileUrl, AreaFileName, PlaneFileUrl, PlaneFileName)
            for data in try db.prepare(query) {
                if data[AreaFileUrl] != nil && data[AreaFileName] != nil && data[AreaFileUrl] != "" && data[AreaFileName] != "" {
                    print("*name: \(data[AreaFileUrl]!) \(data[AreaFileName]!)")
                    
                    let fileURL = documentDirectory.appendingPathComponent(data[AreaFileName]!)
                    if fileManager.fileExists(atPath: fileURL.path) {
                        print("FILE Exist")
                    } else {
                        let picData = PicData()
                        picData.fileName = data[AreaFileName]!
                        picData.fileUrl = URLConstants.ImagePrefixURL + data[AreaFileUrl]!
                        dlPicArr.append(picData)
                    }
                }
                if data[PlaneFileUrl] != nil && data[PlaneFileName] != nil && data[PlaneFileUrl] != "" && data[PlaneFileName] != "" {
                    print("*name: \(data[PlaneFileUrl]!) \(data[PlaneFileName]!)")
                    let fileManager = FileManager.default
                    let fileURL = documentDirectory.appendingPathComponent(data[PlaneFileName]!)
                    if fileManager.fileExists(atPath: fileURL.path) {
                        print("FILE Exist")
                    } else {
                        let picData = PicData()
                        picData.fileName = data[PlaneFileName]!
                        picData.fileUrl = URLConstants.ImagePrefixURL + data[PlaneFileUrl]!
                        dlPicArr.append(picData)
                    }
                }
            }
            for tableName in DBHelper.DLPicTables {
                let dl_table = Table(tableName)
                query = dl_table.select(FileUrl, FileName)
                for data in try db.prepare(query) {
                    if data[FileUrl] != nil && data[FileName] != nil && data[FileUrl] != "" && data[FileName] != "" {
                        print("*name: \(data[FileUrl]!) \(data[FileName]!)")
                        
                        let fileURL = documentDirectory.appendingPathComponent(data[FileName]!)
                        if fileManager.fileExists(atPath: fileURL.path) {
                            print("FILE Exist")
                        } else {
                            let picData = PicData()
                            picData.fileName = data[FileName]!
                            picData.fileUrl = URLConstants.ImagePrefixURL + data[FileUrl]!
                            dlPicArr.append(picData)
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    func downloadPic() {
        let progressClosure : (CGFloat, VeloxDownloadInstance) -> (Void)
        let remainingTimeClosure : (CGFloat) -> Void
        let completionClosure : (Bool) -> Void
        
        progressClosure = {(progress,downloadInstace) in
            print("Progress of File : \(downloadInstace.filename) is \(Float(progress))")
            
        }
        
        remainingTimeClosure = {(timeRemaning) in
            print("Remaining Time is : \(timeRemaning)")
        }
        
        completionClosure = {(status) in
            print("is Download completed : \(status)")
            self.dlIndex += 1
            DispatchQueue.main.async {
                self.hud?.progress = (Float)(self.dlIndex) / (Float)(self.dlPicArr.count)
                self.hud?.detailTextLabel.text = String.init(format: "%d/%d", self.dlIndex, self.dlPicArr.count)
                if self.dlIndex < self.dlPicArr.count {
                    self.downloadPic()
                } else {
                    DispatchQueue.main.async {
                        self.hud?.dismiss(animated: false)
                        let alertController = UIAlertController(
                            title: "提醒",
                            message: "上傳完成",
                            preferredStyle: .alert)
                        
                        let okAction = UIAlertAction(title: "確定", style: .default) { (alertController) in
                            
                        }
                        alertController.addAction(okAction)
                        let delegate = UIApplication.shared.delegate as? AppDelegate
                        delegate?.window?.rootViewController?.present(
                            alertController,
                            animated: true,
                            completion: nil)
                    }
                }
            }
            
        }
        
        
        
        do {
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileName = dlPicArr[dlIndex].fileName
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            let veloxDownloader = VeloxDownloadManager.sharedInstance
            let url = URL(string: dlPicArr[dlIndex].fileUrl.urlEncoded())
            
            dlPicTimer = Timer.scheduledTimer(timeInterval: TimeInterval(5), target: self, selector: #selector(InsTmpDataManager.timerStop), userInfo: nil, repeats: false)
            veloxDownloader.downloadFile(
                withURL: url!,
                name: fileName,
                directoryName: fileURL.absoluteString,
                friendlyName: nil,
                progressClosure: progressClosure,
                remainigtTimeClosure: remainingTimeClosure,
                completionClosure: completionClosure,
                backgroundingMode: false)
        } catch {
            print(error)
        }
    }
    
    @objc func timerStop() {
        
        
        do {
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            if dlIndex >= dlPicArr.count {
                return
            }
            let fileName = dlPicArr[dlIndex].fileName
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            try fileManager.removeItem(at: fileURL)
            print("Existing file deleted.")
        } catch {
            print("Failed to delete existing file:\n\((error as NSError).description)")
        }
        self.hud?.dismiss(animated: false)
        let alert = UIAlertController(title: "提醒", message: "無法下載圖片\n" + self.dlPicArr[self.dlIndex].fileUrl, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
            
        }))
        //let delegate = UIApplication.shared.delegate as? AppDelegate
        //delegate?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    func loadDB() {
        if self.hud != nil {
            self.hud?.dismiss()
        }
        self.hud = JGProgressHUD(style: .dark)
        self.hud?.vibrancyEnabled = true
        self.hud?.detailTextLabel.text = String.init(format: "%d / %d", self.updateIndex, self.updateUrls.count)
        self.hud?.textLabel.text = "上傳中"
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        self.hud?.show(in: (delegate?.window?.rootViewController?.view)!)
        
        let veloxDownloader = VeloxDownloadManager.sharedInstance
        let urlString = updateUrls[updateIndex]
        
        let url = URL(string: urlString)
        
        let progressClosure : (CGFloat, VeloxDownloadInstance) -> (Void)
        let remainingTimeClosure : (CGFloat) -> Void
        let completionClosure : (Bool) -> Void
        
        progressClosure = {(progress,downloadInstace) in
            print("Progress of File : \(downloadInstace.filename) is \(Float(progress))")
            
            DispatchQueue.main.async {
                //self.incrementHUD(hud, progress: Float(progress))
            }
            
        }
        
        remainingTimeClosure = {(timeRemaning) in
            print("Remaining Time is : \(timeRemaning)")
        }
        
        completionClosure = {(status) in
            print("is Download completed : \(status)")
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                
                self.loadPic(self.updateFileNames[self.updateIndex])
                self.clearUploadDBIndex()
                self.updateIndex += 1;
                if self.updateIndex >= self.updateUrls.count {
                    if self.dlPicArr.count > 0 {
                        self.hud?.vibrancyEnabled = true
                        self.hud?.indicatorView = JGProgressHUDPieIndicatorView()
                        self.hud?.detailTextLabel.text = String.init(format: "%d/%d", 0, self.dlPicArr.count)
                        self.hud?.textLabel.text = "資料同步中..."
                        let delegate = UIApplication.shared.delegate as? AppDelegate
                        
                        self.hud?.show(in: (delegate?.window?.rootViewController?.view)!)
                        self.downloadPic()
                    } else {
                        DispatchQueue.main.async {
                            if self.hud != nil {
                                self.hud?.dismiss(animated: false)
                            }
                            let alertController = UIAlertController(
                                title: "提醒",
                                message: "上傳完成",
                                preferredStyle: .alert)
                            
                            let okAction = UIAlertAction(title: "確定", style: .default) { (alertController) in
                                
                            }
                            
                            alertController.addAction(okAction)
                            
                            let delegate = UIApplication.shared.delegate as? AppDelegate
                            
                            delegate?.window?.rootViewController?.present(
                                alertController,
                                animated: true,
                                completion: nil)
                        }
                    }
                    
                } else {
                    self.loadDB()
                }
            }
        }
        
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileName = updateFileNames[updateIndex]
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            veloxDownloader.downloadFile(
                withURL: url!,
                name: fileName,
                directoryName: fileURL.absoluteString,
                friendlyName: nil,
                progressClosure: progressClosure,
                remainigtTimeClosure: remainingTimeClosure,
                completionClosure: completionClosure,
                backgroundingMode: false)
        } catch {
            print(error)
        }
        
    }
    
}
