//
//  DBHelper.swift
//  Home-Maintenance
//
//  Created by Bani on 2018/4/16.
//  Copyright © 2018 Ultron mobile. All rights reserved.
//

import Foundation
class DBHelper: NSObject {
	static public let DeleteTables = [
	"AreaItem_InspPlaceItem",
	"CheckFlowItem_InspItem",
	"HomePlanAreaUploadFile",
	"HomeProject_AreaItem",
	"HomeProject_CheckFlowAreaItem",
	"HomeProject_CheckFlowItem",
	"InspPlaceItem_InspItem",
	"InspPlaceItem_InspOtherItem",
	"InspMasterMsg",
	"InspMaster_BookingTime"]
	
	static public let ClearTables = [
		"InspBuilderCheckFlowDetail",
		"InspBuilderCheckFlowUploadFile",
		"InspBuilderDetail",
		"InspBuilderSignUploadFile",
		"InspBuilderUploadFile",
		"InspCheckFlowDetail",
		"InspCheckFlowUploadFile",
		"InspDetail",
		"InspSignUploadFile",
		"InspUploadFile",
        "InspMaster"]
    
    static public let DLPicTables = [
        "InspUploadFile",
        "InspBuilderUploadFile",
        "InspCheckFlowUploadFile",
        "InspBuilderCheckFlowUploadFile",
        "InspSignUploadFile",
        "InspBuilderSignUploadFile"]
	
}
