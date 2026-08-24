//
//  PopupView.swift
//  Home-Maintenance
//
//  Created by Yuchi Chen on 2017/9/28.
//  Copyright © 2017年 Ultron mobile. All rights reserved.
//

import UIKit

class PopupView: UIView {

    @IBOutlet var vwBackground: UIView!
    @IBOutlet var lblTtitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initLayout()
    }
    
    func initLayout() {
        //init vwBackground
        vwBackground.backgroundColor = UIColor.init(white: 0.0, alpha: 0.5)
    }
    
    func setTitle(_ title:String) {
        lblTtitle.text = title
    }
    
    //MARK: Button Action
    @IBAction func btnCancelPressed(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    @IBAction func btnDonePressed(_ sender: UIButton) {
        self.removeFromSuperview()
    }
}
