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


class AddMistakeController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CameraControllerDelegate, UITextViewDelegate {
	
	@IBOutlet weak var tvComment: UITextView!
	@IBOutlet weak var btnEditPhoto: UIButton!
	@IBOutlet weak var lblTitle: UILabel!
	public var opName: String!
	public var caseName: String!
	public var projectName: String!
    public var from = 0
	let data0 = NSMutableArray.init()
	let data1 = NSMutableArray.init()
	var projectIndex:Int = 0
	var characterIndex:Int = 0
	var buildingIndex:Int = 0
	var areaData:[InsAreaItem] = []
	var placeData:[InsPlaceItem] = []
	var placeDataAll = NSMutableArray.init()
	var desData:[InsAreaItem] = []
	var areaIndex:Int = 0
	var placeIndex:Int = 0
	var desIndex:Int = 0
    var pickerViewArea = UIPickerView()
    var pickerViewPlace = UIPickerView()
    var pickerViewDes = UIPickerView()
    
	
	@IBOutlet weak var ivPhoto: UIImageView!
	@IBOutlet weak var tfArea: UITextField!
	@IBOutlet weak var tfCat: UITextField!
	@IBOutlet weak var tfDes: UITextField!

	@IBOutlet weak var btnCamera: UIButton!
	// MARK: Life Circle
	override func viewDidLoad() {
		super.viewDidLoad()
		initLayaout()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		initTextField()
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
		
		tfArea.text = areaData[areaIndex].name
		placeData = placeDataAll[areaIndex] as! [InsPlaceItem]
		
		if(placeData.count > 0) {
			placeIndex = 0
			tfCat.text = placeData[placeIndex].name
		} else {
			placeIndex = -1
			tfCat.text = ""
		}
    
		tfDes.text = desData[desIndex].name
	}
	
	func initData() {
		do {
			let fileManager = FileManager.default
			let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
			let mainFileURL = documentDirectory.appendingPathComponent(SystemConstants.DBFileName)
			let projectsNo = UserDefaults.standard.string(forKey: "PROJECT_NO")
			let building = UserDefaults.standard.string(forKey: "BUILDING")
            let floor = UserDefaults.standard.string(forKey: "FLOOR")
            let room = UserDefaults.standard.string(forKey: "ROOM")
			let subFileURL = documentDirectory.appendingPathComponent(String.init(format: SystemConstants.DBFileNameSub, projectsNo!, building!))
			var db = try Connection(subFileURL.absoluteString)
			
            let InspPlaceItem_InspItem = Table("InspPlaceItem_InspItem")
            let ProjInspIdx = Expression<String?>("ProjInspIdx")
            let ELEVEL_2_1 = Expression<String?>("ELEVEL_2_1")
            let ELEVEL_2_2 = Expression<String?>("ELEVEL_2_2")
            let ELEVEL_1 = Expression<String?>("ELEVEL_1")
            let AreaId = Expression<String?>("AreaId")
            let InspPlaceId = Expression<String?>("InspPlaceId")
            let Sorting = Expression<String?>("Sorting")
            
            var query = InspPlaceItem_InspItem.select(distinct:AreaId).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && (ELEVEL_1 == floor || ELEVEL_1 == "")).order(Sorting.asc)
            let dbMain = try Connection(mainFileURL.absoluteString)
            for data in try db.prepare(query) {
                print("name: \(data[AreaId]!)")
                let insAreaItem = InsAreaItem.init()
                insAreaItem.type = 1
                insAreaItem.idx = data[AreaId]!
                areaData.append(insAreaItem)
            }
            
            let AreaItem = Table("AreaItem")
            let AreaName = Expression<String?>("AreaName")
            let InspPlaceItem = Table("InspPlaceItem")
            let InspPlaceName = Expression<String?>("InspPlaceName")
            
            for insAreaItem in areaData {
                let queryAreaName = AreaItem.select(AreaName).filter(AreaId == insAreaItem.idx).order(Sorting.asc)
                for data in try dbMain.prepare(queryAreaName) {
                    print("*name: \(data[AreaName]!)")
                    insAreaItem.name = data[AreaName]!
                }
                
                let queryPlace = InspPlaceItem_InspItem.select(distinct:InspPlaceId).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && (ELEVEL_1 == floor || ELEVEL_1 == nil) && AreaId == insAreaItem.idx).order(Sorting.asc)
                for data in try db.prepare(queryPlace) {
                    print("  name: \(data[InspPlaceId]!)")
                    let insPlaceItem = InsPlaceItem.init()
                    insPlaceItem.idx = data[InspPlaceId]!
                    insAreaItem.places.append(insPlaceItem)
                }
                placeDataAll.add(insAreaItem.places)
                
                for insPlaceItem in insAreaItem.places {
                    let queryPlaceName = InspPlaceItem.select(InspPlaceName).filter(InspPlaceId == insPlaceItem.idx).order(Sorting.asc)
                    for data in try dbMain.prepare(queryPlaceName) {
                        print("*name: \(data[InspPlaceName]!)")
                        insPlaceItem.name = data[InspPlaceName]!
                    }
                }
            }
			
			if placeDataAll.count >= 1 {
				placeData = placeDataAll[0] as! [InsPlaceItem]
			}
			
			let table = Table("InspDescItem")
			let table_inspDescItemId = Expression<String?>("InspDescItemId")
			let table_inspDescItemName = Expression<String?>("InspDescItemName")
            let project_no = Expression<String?>("PROJM_NO")
            let userDefaults = UserDefaults.standard
            let projectNo = userDefaults.string(forKey: "PROJECT_NO")
            query = table.select(table_inspDescItemId, table_inspDescItemName).filter(project_no == projectNo).order(Sorting.asc)
			for data in try dbMain.prepare(query) {
				print("name: \(data[table_inspDescItemId]!)")
				let insAreaItem = InsAreaItem()
				insAreaItem.idx = data[table_inspDescItemId]!
				insAreaItem.name = data[table_inspDescItemName]!
				desData.append(insAreaItem)
			}
			
		} catch {
			//handle error
			print(error)
		}
	}
	
	func initTextField() {
        pickerViewArea = initTextField(textField: tfArea, tag: 0)
		pickerViewPlace = initTextField(textField: tfCat, tag: 1)
		pickerViewDes = initTextField(textField: tfDes, tag: 2)
	}
	
	func initTextField(textField: UITextField, tag: Int) -> UIPickerView {
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
        
        return picker
	}
	
	// MARK: UIPickerViewDelegate
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if pickerView.tag == 0 {
			return areaData.count
		} else if pickerView.tag == 1 {
			return placeData.count
		} else {
			return desData.count
		}
		
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if pickerView.tag == 0 {
			let insAreaItem = areaData[row]
			return insAreaItem.name
		} else if pickerView.tag == 1 {
			let insPlaceItem = placeData[row]
			return insPlaceItem.name
		} else {
			let insAreaItem = desData[row]
			return insAreaItem.name
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if pickerView.tag == 0 {
			areaIndex = row
			tfArea.text = areaData[areaIndex].name
			placeData = placeDataAll[areaIndex] as! [InsPlaceItem]
			
			if(placeData.count > 0) {
				placeIndex = 0
                pickerViewPlace.reloadAllComponents()
                pickerViewPlace.selectRow(0, inComponent: 0, animated: false)
				tfCat.text = placeData[placeIndex].name
			} else {
				placeIndex = -1
				tfCat.text = ""
			}
		} else if pickerView.tag == 1 {
			placeIndex = row
			tfCat.text = placeData[placeIndex].name
		} else {
			desIndex = row
			tfDes.text = desData[desIndex].name
		}
	}
	
    //MARK: Button Action
    @objc func btnBackPressed(sender: UIBarButtonItem) {
        let alertController = UIAlertController(
            title: "提醒",
            message: "是否儲存",
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
	
	@IBAction func btnFinishPressed(_ sender: Any) {
		if areaIndex == -1 {
			let alert = UIAlertController(title: "提醒", message: "請選擇地點", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
			}))
			self.present(alert, animated: true, completion: nil)
			return
		}
        
        if placeIndex == -1 {
            let alert = UIAlertController(title: "提醒", message: "請選擇位置", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if desIndex == -1 {
            let alert = UIAlertController(title: "提醒", message: "請選擇敘述", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
		
		let targetAreaItem = areaData[areaIndex]
        let targetPlaceItem = placeData[placeIndex]
        var addDBTmp = "Add_DataArea"
        if from != 0 {
            addDBTmp = "Ins_DataArea"
        }
		var areaDataStore = InsTmpDataManager.sharedInstance().dicArea[addDBTmp]!
        var saveAreaItem:InsAreaItem?
        var savePlaceItem:InsPlaceItem?
		if areaDataStore.count > 0 {
			for insAreaItem in areaDataStore {
				if insAreaItem.idx == targetAreaItem.idx {
					saveAreaItem = insAreaItem
                    for insPlaceItem in insAreaItem.places {
                        if insPlaceItem.idx == targetPlaceItem.idx {
                            savePlaceItem = insPlaceItem
                            break
                        }
                    }
					break
				}
			}
		}
		
		let insItem = InsItem.init()
		insItem.areaId = targetAreaItem.idx
        insItem.fkIdx = ""
		insItem.check = true
        insItem.placeId = placeData[placeIndex].idx
        insItem.desId = desData[desIndex].idx
        insItem.desName = desData[desIndex].name
		insItem.result = 1
		insItem.name = desData[desIndex].name
        insItem.inspRemark = tvComment.text
        
        if self.ivPhoto.image != nil {
            do {
                if let data = UIImagePNGRepresentation(self.ivPhoto.image!) {
                    let fileManager = FileManager.default
                    let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                    let userIdx = UserDefaults.standard.string(forKey: "UserIdx")
                    let fileName = String.init(format: "%@_%.0f.png", userIdx!, NSDate().timeIntervalSince1970)
                    insItem.picUrl = fileName
                    let fileURL = documentDirectory.appendingPathComponent(fileName)
                    try data.write(to: fileURL)
                }
            } catch {
                print(error)
            }
        }
        
        targetAreaItem.places = [targetPlaceItem]
        targetPlaceItem.items.append(insItem)
		
		if saveAreaItem == nil {
			areaDataStore.append(targetAreaItem)
		} else {
            if savePlaceItem == nil {
                saveAreaItem?.places.append(targetPlaceItem)
            } else {
                savePlaceItem?.items.append(insItem)
            }
		}
		
		InsTmpDataManager.sharedInstance().dicArea[addDBTmp] = areaDataStore
		self.navigationController?.popViewController(animated: true)
	}
    
    //MARK: UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //50 chars restriction
        return textView.text.count + (text.count - range.length) <= 50
    }
	
	@IBAction func btnCameraPressed(_ sender: Any) {
		let cameraController = CameraController()
		cameraController.delegate = self
		self.navigationController?.pushViewController(cameraController, animated: true)
	}
	
	@IBAction func btnEditPhotoPressed(_ sender: Any) {
		let cameraController = CameraController()
		cameraController.delegate = self
		self.navigationController?.pushViewController(cameraController, animated: true)
	}
	
	func didFinishPhoto(image:UIImage) {
		self.ivPhoto.image = image
		self.ivPhoto.isHidden = false
		self.btnEditPhoto.isHidden = false
	}
    
   
    
}


