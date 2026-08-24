//
//  FixDetailController.swift
//  Home-Maintenance
//
//  Created by Yuchi Chen on 2017/9/28.
//  Copyright © 2017年 Ultron mobile. All rights reserved.
//

import UIKit

class FixDetailController: UIViewController, CameraControllerDelegate, UITextViewDelegate {

    @IBOutlet var vwContentBackgroung: UIView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubtitle: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var tvComment: UITextView!
    
    var headerTitle: String = ""
    var subtitle: String = ""
    var InsItem: InsItem?
    
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Custom Functions
    func initLayout() {
        //init back button
        let btnBack = NaviTool.initBtnBack()
        btnBack.addTarget(self, action: #selector(btnBackPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(btnBack)
        
        //init vwTextBackground
        vwContentBackgroung.layer.borderColor = UIColor(red:0.64, green:0.20, blue:0.20, alpha:1.00).cgColor
        vwContentBackgroung.layer.borderWidth = 1.0
        
        //init lblTitle
        lblTitle.text = headerTitle
        
        //init lblSubtitle
        lblSubtitle.text = subtitle
        
        //init UI
        tvComment.text = InsItem?.commentFixed
        
        do {
            if InsItem?.picUrlFixed.count != 0 {
                let fileManager = FileManager.default
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURL = documentDirectory.appendingPathComponent((InsItem?.picUrlFixed)!)
                print(InsItem?.picUrl)
                let image = try UIImage.init(data: Data.init(contentsOf: fileURL), scale:1.0)
                self.imageView.image = image
            }
        } catch {
            print(error)
        }
    }
    
    //MARK: Button Action
    @IBAction func btnCreatePhotoPressed(_ sender: UIButton) {
		let cameraController = CameraController()
		cameraController.delegate = self
		self.navigationController?.pushViewController(cameraController, animated: true)
    }
    
    @IBAction func btnDonePressed(_ sender: UIButton) {
        
        if self.imageView.image != nil {
            InsItem?.commentFixed = tvComment.text
            do {
                if let data = UIImagePNGRepresentation(self.imageView.image!) {
                    let fileManager = FileManager.default
                    let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                    let userIdx = UserDefaults.standard.string(forKey: "UserIdx")
                    let fileName = String.init(format: "%@_%.0f.png", userIdx!, NSDate().timeIntervalSince1970)
                    let fileURL = documentDirectory.appendingPathComponent(fileName)
                    try data.write(to: fileURL)
                    InsItem?.picUrlFixed = fileName
                }
            } catch {
                print(error)
            }
            InsItem?.isFixed = "Y"
            self.navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "提醒", message: "請拍攝照片!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
            }))
            self.present(alert, animated: true, completion: nil)
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
	
	func didFinishPhoto(image:UIImage) {
		self.imageView.image = image
	}
    
    //MARK: UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //50 chars restriction
        return textView.text.count + (text.count - range.length) <= 50
    }
    
}
