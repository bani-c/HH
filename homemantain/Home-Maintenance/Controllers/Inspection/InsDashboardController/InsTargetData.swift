//
//  InsTargetData.swift
//  Home-Maintenance
//
//  Created by Bani on 2018/4/16.
//  Copyright © 2018 Ultron mobile. All rights reserved.
//

import Foundation
class InsTargetData {
	var date:String = ""
	var building:String = ""
	var floor:String = ""
    var room:String = ""
	var inspNo:String = ""
	var inspMstIdx:String = ""
	var RepairStatus:String = ""
	var recordType:String = "0"
	var reinspection:String = ""
	var inspDate:String = ""
	var subject:String = ""
	var repairCount:Int = 0
	var unRepairCount:Int = 0

    var displayTitle:String {
        let buildingTitle = building.hasSuffix("棟") ? building : building + "棟"
        let floorNumber = floor.uppercased().hasSuffix("F") ? String(floor.dropLast()) : floor
        let floorTitle = floorNumber.hasSuffix("樓") ? floorNumber : floorNumber + "樓"
        return buildingTitle + room + " - " + floorTitle
    }
    
	private static var mInstance:InsTargetData?
	static func setSharedInstance(_instance:InsTargetData) {
		mInstance = _instance
	}
	static func sharedInstance() -> InsTargetData {
		if mInstance == nil {
			mInstance = InsTargetData()
		}
		return mInstance!
	}
}
