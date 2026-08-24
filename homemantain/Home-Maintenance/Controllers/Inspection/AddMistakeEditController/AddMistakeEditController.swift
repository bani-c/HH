//
//  ViewController.swift
//  Home-Maintenance
//
//  Created by Bani on 14/09/2017.
//  Copyright © 2017 Ultron mobile. All rights reserved.
//

import UIKit
import SQLite
import NYTPhotoViewer


class AddMistakeEditController: UIViewController, CameraControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate {
	
	@IBOutlet weak var tvComment: UITextView!
	@IBOutlet weak var btnEditPhoto: UIButton!
	@IBOutlet weak var lblTitle: UILabel!
	public var opName: String!
	public var caseName: String!
	public var projectName: String!
    public var from = 0
    public var areaName: String!
    public var placeName: String!
    public var desName: String!
    public var desEnable = true
    public var targetInsItem:InsItem!
    public var type = 0
    
	let data0 = NSMutableArray.init()
	let data1 = NSMutableArray.init()
	var projectIndex:Int = 0
	var characterIndex:Int = 0
	var buildingIndex:Int = 0
    var changePhoto = false
	
    @IBOutlet weak var btnFinish: UIButton!
    @IBOutlet weak var ivPhoto: UIImageView!
	@IBOutlet weak var tfArea: UITextField!
	@IBOutlet weak var tfCat: UITextField!
	@IBOutlet weak var tfDes: UITextField!
    var desData:[InsAreaItem] = []
    public var desIndex:Int = 0

	@IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var vwAmount: UIView!
    
    @IBOutlet weak var tfAmount: UITextField!
    @IBOutlet weak var tfLessAmount: UITextField!
    
    
    // MARK: Life Circle
	override func viewDidLoad() {
		super.viewDidLoad()
		initLayaout()
        
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        if type == 1 {
            lblTitle.text = "編輯缺失"
            initTextField()
        } else if type == 2 {
            lblTitle.text = "缺失紀錄"
            //btnCamera.isEnabled = false
            btnFinish.isHidden = true
            btnEditPhoto.isEnabled = false
            btnEditPhoto.isHidden = true
            tvComment.isEditable = false
            tfLessAmount.isEnabled = false
        }
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	// MARK: Custom Functions
	func initLayaout() {
		initData()
        //init back button
        let btnBack = NaviTool.initBtnBack()
        btnBack.addTarget(self, action: #selector(btnBackPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(btnBack)
		
		self.tvComment.layer.borderColor = UIColor.gray.cgColor
		self.tvComment.layer.borderWidth = 1
        
        if targetInsItem.amount != "" && targetInsItem.amount != "0" {
            vwAmount.isHidden = false
            tfAmount.text = targetInsItem.amount
            tfLessAmount.text = String.init(format: "%d", targetInsItem.detect_amount)
        }
		
		
	}
    
    func initTextField() {
        //if desEnable {
            tfDes.isEnabled = true
            tfDes.text = desData[desIndex].name
            initTextField(textField: tfDes, tag: 0)
        //}
    }
    
    func initTextField(textField: UITextField, tag: Int) {
        textField.tintColor = UIColor.clear
        //setup picker
        let picker: UIPickerView
        picker = UIPickerView(frame: CGRect(x:0, y:0, width:view.frame.width, height:300))
        picker.backgroundColor = .white
        
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        picker.tag = tag
        
        let bgView = UIView(frame: CGRect(x: 0, y: 200, width:view.frame.width, height: 300))
        
        bgView.addSubview(picker)
        
        textField.inputView = bgView
    }
    
    // MARK: UIPickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return desData.count
        }
       return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            let insAreaItem = desData[row]
            return insAreaItem.name
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            desIndex = row
            tfDes.text = desData[desIndex].name
        }
    }
	
	func initData() {
        tfArea.text = areaName
        tfCat.text = placeName
        tfDes.text = desName
        self.tvComment.text = targetInsItem.inspRemark
        do {
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let mainFileURL = documentDirectory.appendingPathComponent(SystemConstants.DBFileName)
            let dbMain = try Connection(mainFileURL.absoluteString)
            let table = Table("InspDescItem")
            let table_inspDescItemId = Expression<String?>("InspDescItemId")
            let table_inspDescItemName = Expression<String?>("InspDescItemName")
            let Sorting = Expression<String?>("Sorting")
            let project_no = Expression<String?>("PROJM_NO")
            let userDefaults = UserDefaults.standard
            let projectNo = userDefaults.string(forKey: "PROJECT_NO")
            let query = table.select(table_inspDescItemId, table_inspDescItemName).filter(project_no == projectNo).order(Sorting.asc)
            var index = 0
            for data in try dbMain.prepare(query) {
                print("name: \(data[table_inspDescItemId]!)")
                let insAreaItem = InsAreaItem()
                insAreaItem.idx = data[table_inspDescItemId]!
                insAreaItem.name = data[table_inspDescItemName]!
                desData.append(insAreaItem)
                if targetInsItem != nil && targetInsItem.desId == insAreaItem.idx{
                    desIndex = index;
                }
                index += 1
            }
            if targetInsItem.picUrl.count != 0 {
                let fileManager = FileManager.default
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURL = documentDirectory.appendingPathComponent(targetInsItem.picUrl)
                print(targetInsItem.picUrl)
                let image = try UIImage.init(data: Data.init(contentsOf: fileURL), scale:1.0)
                self.ivPhoto.image = image
                self.ivPhoto.isHidden = false
                self.btnEditPhoto.isHidden = false
            }
        } catch {
            
        }
	}
	
    //MARK: Button Action
    @objc func btnBackPressed(sender: UIBarButtonItem) {
        if type == 2 {
           self.navigationController?.popViewController(animated: true)
        } else {
            let alertController = UIAlertController(
                title: "提醒",
                message: "是否儲存？",
                preferredStyle: .alert)
            
            
            let cancelAction = UIAlertAction(title: "離開", style: .default) { (alertController) in
                self.navigationController?.popViewController(animated: true)
                
            }
            alertController.addAction(cancelAction)
            let okAction = UIAlertAction(title: "存檔", style: .default) { (alertController) in
                self.btnFinishPressed(self.btnCamera)
                
            }
            
            alertController.addAction(okAction)
            
            self.present(
                alertController,
                animated: true,
                completion: nil)
            
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxLength = 7
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length >= maxLength {
            return false
        }
        
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField.text?.count == 0) {
            let alert = UIAlertController(title: "提醒", message: "缺少數量不可為空值", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
            
            textField.text = "0"
        }
        if Int(textField.text!)! > Int(targetInsItem.amount)! {
            let alert = UIAlertController(title: "提醒", message: "缺少數量不可大於應有數量", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
            textField.text = "0"
        }
        
        
        
    }
    
    //MARK: UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //50 chars restriction
        return textView.text.count + (text.count - range.length) <= 50
    }
    
	
	@IBAction func btnFinishPressed(_ sender: Any) {
        targetInsItem.inspRemark = tvComment.text
        targetInsItem.desId = desData[desIndex].idx
        targetInsItem.desName = desData[desIndex].name
        if desEnable {
            targetInsItem.name = desData[desIndex].name
        }
        if targetInsItem.amount != "" && targetInsItem.amount != "0" {
            targetInsItem.detect_amount = Int(tfLessAmount.text!)!
        }
        if self.ivPhoto.image != nil && changePhoto {
            do {
                if let data = UIImagePNGRepresentation(self.ivPhoto.image!) {
                    let fileManager = FileManager.default
                    let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                    let userIdx = UserDefaults.standard.string(forKey: "UserIdx")
                    let fileName = String.init(format: "%@_%.0f.png", userIdx!, NSDate().timeIntervalSince1970)
                    targetInsItem.picUrl = fileName
                    let fileURL = documentDirectory.appendingPathComponent(fileName)
                    try data.write(to: fileURL)
                }
            } catch {
                print(error)
            }
        }
        
      
		self.navigationController?.popViewController(animated: true)
	}
	
	@IBAction func btnCameraPressed(_ sender: Any) {
        if targetInsItem.picUrl.count != 0 {
            do {
                let fileManager = FileManager.default
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURL = documentDirectory.appendingPathComponent(targetInsItem.picUrl)
                print(targetInsItem.picUrl)
                let image = try UIImage.init(data: Data.init(contentsOf: fileURL), scale:1.0)
                var photos: [NYTPhoto] = []
                let title = NSAttributedString(string: targetInsItem.name, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
                let photo = Photo.init(image:image, attributedCaptionTitle: title)
                photos.append(photo)
                let photosViewController = NYTPhotosViewController(photos: photos)
                present(photosViewController, animated: true, completion: nil)
            } catch {
                
            }
            
        } else if self.ivPhoto.image != nil {
            var photos: [NYTPhoto] = []
            let title = NSAttributedString(string: targetInsItem.name, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
            let photo = Photo.init(image:self.ivPhoto.image, attributedCaptionTitle: title)
            photos.append(photo)
            let photosViewController = NYTPhotosViewController(photos: photos)
            present(photosViewController, animated: true, completion: nil)
        } else {
            if type != 2 {
                let cameraController = CameraController()
                cameraController.delegate = self
                self.navigationController?.pushViewController(cameraController, animated: true)
            }
        }
		
	}
	
	@IBAction func btnEditPhotoPressed(_ sender: Any) {
		let cameraController = CameraController()
		cameraController.delegate = self
		self.navigationController?.pushViewController(cameraController, animated: true)
	}
	
	func didFinishPhoto(image:UIImage) {
        changePhoto = true
		self.ivPhoto.image = image
		self.ivPhoto.isHidden = false
		self.btnEditPhoto.isHidden = false
	}
    
}


