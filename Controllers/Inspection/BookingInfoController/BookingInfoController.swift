//
//  ViewController.swift
//  NxtPos
//
//  Created by Bani on 2018/6/3.
//  Copyright © 2018 Bani. All rights reserved.
//

import UIKit

class BookingInfoController: UIViewController  {
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var btnCancel: UIButton!
  
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
   
    public var name = ""
    public var time = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        initLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initLayout() {
        lblName.text = name
        lblTime.text = time
       
       
        
    }
    
    
    @IBAction func clickBackground(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
   
    @IBAction func clickCancel(_ sender: Any) {
        clickBackground(btnCancel)
    }
    
   
}

