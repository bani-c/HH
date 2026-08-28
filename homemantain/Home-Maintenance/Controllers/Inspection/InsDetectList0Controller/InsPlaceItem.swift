//
//  InsAreaItem.swift
//  Home-Maintenance
//
//  Created by Bani on 2018/4/9.
//  Copyright © 2018 Ultron mobile. All rights reserved.
//

import Foundation
class InsPlaceItem {
    var areaName:String = ""
    var placeName:String = ""
	var name:String = ""
	var idx:String = ""
    var items:[InsItem] = []
}

enum InspectionPrintOrder {
    static func sorted(_ placeData: [InsPlaceItem]) -> [InsPlaceItem] {
        return placeData.enumerated().sorted { lhs, rhs in
            let lhsPriority = priority(for: lhs.element.areaName)
            let rhsPriority = priority(for: rhs.element.areaName)

            if lhsPriority == rhsPriority {
                return lhs.offset < rhs.offset
            }
            return lhsPriority < rhsPriority
        }.map { $0.element }
    }

    private static func priority(for areaName: String) -> Int {
        switch areaName {
        case "客廳", "客餐廳":
            return 0
        case "餐廳":
            return 10
        case "主臥室":
            return 20
        case "主浴室":
            return 30
        case "次臥室", "臥室一", "臥室ㄧ", "臥室1":
            return 40
        case "臥室二", "臥室2":
            return 41
        case "臥室三", "臥室3":
            return 42
        case "次浴室", "客浴室":
            return 50
        case "廚房":
            return 60
        case "陽台", "前陽台":
            return 70
        case "後陽台":
            return 71
        default:
            return Int.max
        }
    }
}
