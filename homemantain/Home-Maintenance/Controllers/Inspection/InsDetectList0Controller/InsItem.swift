//
//  InsItem.swift
//  Home-Maintenance
//
//  Created by Bani on 2018/4/8.
//  Copyright © 2018 Ultron mobile. All rights reserved.
//

import Foundation
class InsItem {
	var fkIdx:String = ""
	var name:String = ""
    var desName:String = ""
	var idx:String = ""
	var areaId:String = ""
	var placeId:String = ""
	var checkFlowType:String = ""
	var checkFlowItemId:String = ""
	var inspItemId:String = ""
	var check:Bool = false
	var result:Int = -1
	// A defect may have up to two before-repair photos. Keep picUrl as a
	// compatibility facade for older screens that still display the first one.
    var picUrls:[String] = []
    var picUrl:String {
        get { return picUrls.first ?? "" }
        set {
            if newValue.isEmpty {
                picUrls.removeAll()
            } else if picUrls.isEmpty {
                picUrls = [newValue]
            } else {
                picUrls[0] = newValue
            }
        }
    }
	var picUrlFixed:String = ""
	var comment:String = ""
	var desId:String = ""
	var amount:String = ""
	var status:Int = -1
	var seqNo:String = ""
	var detect_amount:Int = 0
	var type:Int = -1
	var isFixed:String = ""
    var commentFixed:String = ""
    var inspDescItemId:String = ""
    var inspRemark:String = ""
    var CheckEquipType:String = "1"
    
    
}
