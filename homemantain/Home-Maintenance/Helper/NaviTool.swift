//
//  NaviTool.swift
//  Home-Maintenance
//
//  Created by Yuchi Chen on 2017/9/29.
//  Copyright © 2017年 Ultron mobile. All rights reserved.
//

import UIKit

class NaviTool: NSObject {
    
    class func initBtnBack() -> UIButton {
        let button = UIButton(frame: CGRect(x: 8, y: 14, width: 40 * 0.8, height: 70 * 0.8))
        button.setImage(UIImage.init(named: "warrow_left"), for: .normal)
        button.setImage(UIImage.init(named: "warrow_left"), for: .highlighted)
        return button
    }
    
}
