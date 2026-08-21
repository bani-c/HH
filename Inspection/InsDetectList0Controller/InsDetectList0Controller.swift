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

class InsDetectList0Controller: UIViewController, UITableViewDelegate, UITableViewDataSource, CameraControllerDelegate, UITextFieldDelegate {
	
	@IBOutlet weak var lblTitle: UILabel!
	@IBOutlet weak var lblProjectName: UILabel!
	@IBOutlet weak var tableViewArea: UITableView!
	@IBOutlet weak var tableViewItem: UITableView!
    @IBOutlet weak var ivMap: UIImageView!
	public var opName: String!
	public var opId: String!
	public var caseName: String!
	public var projectName: String!
	var dataArea = [] as [InsAreaItem]
    //var dataArea0 = [] as [InsAreaItem]
	var dataItem = NSMutableArray.init()
	var areaIndex = 0
	var targetItem:InsItem!
	
	// MARK: Life Circle
	override func viewDidLoad() {
		super.viewDidLoad()
		initLayaout()
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableViewItem.reloadData()
    }
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: Custom Functions
	func initLayaout() {
		getLocalData()
		
		//set title
        if UserDefaults.standard.object(forKey: "ISRECORD") != nil {
            lblTitle.text = "驗屋紀錄_" + InsTargetData.sharedInstance().building + "_" + InsTargetData.sharedInstance().floor + "_" + InsTargetData.sharedInstance().room;
        } else {
            lblTitle.text = InsTargetData.sharedInstance().building + "_" + InsTargetData.sharedInstance().floor + "_" + InsTargetData.sharedInstance().room;
        }
		lblProjectName.text = projectName
		
		//register nib
		tableViewArea.register(UINib(nibName: "InsDetect0CategoryCell", bundle: nil), forCellReuseIdentifier: "InsDetect0CategoryCell")
		tableViewItem.register(UINib(nibName: "InsDetect0HeaderCell", bundle: nil), forCellReuseIdentifier: "InsDetect0HeaderCell")
		tableViewItem.register(UINib(nibName: "InsDetect0ItemCell", bundle: nil), forCellReuseIdentifier: "InsDetect0ItemCell")
		
        //init back button
        let btnBack = NaviTool.initBtnBack()
        btnBack.addTarget(self, action: #selector(btnBackPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(btnBack)
        
        if InsTmpDataManager.sharedInstance().areaPicName  != "" {
            do {
                let fileManager = FileManager.default
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURL = documentDirectory.appendingPathComponent(InsTmpDataManager.sharedInstance().areaPicName)
                ivMap.image = UIImage(contentsOfFile: fileURL.path)
            } catch {
                
            }
        }
		
	}
	
    @IBAction func clickMap(_ sender: Any) {
        if InsTmpDataManager.sharedInstance().planePicName != "" {
            do {
                let fileManager = FileManager.default
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURLPlane = documentDirectory.appendingPathComponent(InsTmpDataManager.sharedInstance().areaPicName)
                let imageArea = UIImage(contentsOfFile: fileURLPlane.path)
                var photos: [NYTPhoto] = []
                let titleArea = NSAttributedString(string: "", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
                let photoArea = Photo.init(image:imageArea, attributedCaptionTitle: titleArea)
                photos.append(photoArea)
                let photosViewController = NYTPhotosViewController(photos: photos)
                self.present(photosViewController, animated: true, completion: nil)
            } catch {
                
            }
        }
    }
    
    
	func saveLocalData() {
		InsTmpDataManager.sharedInstance().dicArea[opId + "_DataArea"] = dataArea
		//InsTmpDataManager.sharedInstance().dicItem[opId + "_DataItem"] = dataItem
	}
	
	func getLocalData() {
        dataArea = InsTmpDataManager.sharedInstance().dicArea[opId + "_DataArea"]!
       // dataArea0 = InsTmpDataManager.sharedInstance().dicArea[opId + "_DataArea0"] ?? []
	}

	//MARK: TableView Datasource and Delegate
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableView.tag == 0 {
			return dataArea.count
		} else {
            if areaIndex >= dataArea.count {
                return 0
            } else {
                return dataArea[areaIndex].items.count
            }
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if tableView.tag == 0 {
			return 90.0
		} else {
			return 70.0
		}
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if tableView.tag == 0 {
			return 0.0
		} else {
			return 50.0
		}
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if tableView.tag == 0 {
			return nil
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "InsDetect0HeaderCell") as! InsDetect0HeaderCell
			cell.lblTitle.text = opName
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if tableView.tag == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "InsDetect0CategoryCell", for: indexPath) as! InsDetect0CategoryCell
			let insAreaItem = dataArea[indexPath.row]
			cell.lblTitle.text = String(indexPath.row + 1) + "." + insAreaItem.name
            
            var sumMiss = 0
           
            for item in insAreaItem.items {
                if item.check == true && item.result == 1 {
                    sumMiss += 1
                }
            }
            
            cell.lblCount.text = String(format: "%d", sumMiss)
            
			if areaIndex == indexPath.row {
				cell.backgroundColor = UIColor.init(red: 144.0 / 255.0, green: 33.0 / 255.0, blue: 38.0 / 255.0, alpha: 1.0)
			} else {
				cell.backgroundColor = UIColor.clear
			}
			return cell
		} else {
            let InsItem = dataArea[areaIndex].items[indexPath.row]
			let cell = tableView.dequeueReusableCell(withIdentifier: "InsDetect0ItemCell", for: indexPath) as! InsDetect0ItemCell
			cell.selectionStyle = .none
			if InsItem.amount.count != 0 && InsItem.amount != "0"{
               
                cell.lblTitle.text = String.init(format: "%d.%@  數量:%@", indexPath.row + 1, InsItem.name, InsItem.amount)
                
                
			} else {
				cell.lblTitle.text = String(indexPath.row + 1) + "." + InsItem.name
			}
			
			cell.setCheck(InsItem: InsItem)
            if UserDefaults.standard.object(forKey: "ISRECORD") != nil {
                if InsItem.picUrl == "" {
                    cell.btnCamera.isHidden = true
                }
            } else {
                cell.btnCheck.tag = indexPath.row
                cell.btnCheck.addTarget(self, action: #selector(clickCheck(button:)), for: UIControlEvents.touchUpInside)
                cell.btnMiss.tag = indexPath.row
                cell.btnMiss.addTarget(self, action: #selector(clickMiss(button:)), for: UIControlEvents.touchUpInside)
                cell.btnCamera.tag = indexPath.row
                cell.btnCamera.addTarget(self, action: #selector(clickEdit(button:)), for: UIControlEvents.touchUpInside)
                cell.lblStatus.tag = indexPath.row
                cell.lblStatus.isUserInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapLabel(sender:)))
                cell.lblStatus.addGestureRecognizer(tapGesture)
                cell.tfNumber.tag = indexPath.row
                cell.tfNumber.text = String(InsItem.detect_amount)
                cell.tfNumber.delegate = self
                //let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTapCamera(_:)))
                //cell.btnCamera.addGestureRecognizer(longGesture)
            }
			
			return cell
		}
	}
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0 {
            areaIndex = indexPath.row
            tableViewArea.reloadData()
            tableViewItem.reloadData()
        } else {
            if InsTargetData.sharedInstance().reinspection == "Y" {
                btnFileRecordPressed(indexPath: indexPath)
            }
            /*
            targetItem = dataArea[areaIndex].items[indexPath.row]
            if targetItem.amount.count != 0 && targetItem.amount != "0" {
                    showPopupCount()
            }
 */
        }
    }
    
    
    func btnFileRecordPressed(indexPath: IndexPath) {
        
        let addMistakeEditController = AddMistakeEditController()
        addMistakeEditController.type = 2
        let insAreaItem = dataArea[areaIndex]

        addMistakeEditController.areaName = insAreaItem.name
        addMistakeEditController.placeName = dataArea[areaIndex].items[indexPath.row].name

        addMistakeEditController.desName = dataArea[areaIndex].items[indexPath.row].desName
        addMistakeEditController.targetInsItem = dataArea[areaIndex].items[indexPath.row]
        self.navigationController?.pushViewController(addMistakeEditController, animated: true)
    }
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		textField.text = ""
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
		let compSepByCharInSet = string.components(separatedBy: aSet)
		let numberFiltered = compSepByCharInSet.joined(separator: "")
		return string == numberFiltered
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
        let InsItem = dataArea[areaIndex].items[textField.tag]
		if(textField.text?.count == 0 || textField.text == "0") {
            let alert = UIAlertController(title: "提醒", message: "缺少數量不可為0或空值", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)

			textField.text = "1"
		}
        if Int(textField.text!)! > Int(InsItem.amount)! {
            let alert = UIAlertController(title: "提醒", message: "缺少數量不可大於應有數量", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
            textField.text = "1"
        }
        
		InsItem.detect_amount = Int(textField.text!)!

	}
    
    @objc func clickEdit(button: UIButton) {
        
        let row = button.tag
        let addMistakeEditController = AddMistakeEditController()
        let insAreaItem = dataArea[areaIndex]
        addMistakeEditController.type = 1
        addMistakeEditController.desEnable = false
        addMistakeEditController.areaName = insAreaItem.name
        addMistakeEditController.placeName = dataArea[areaIndex].items[row].name
        addMistakeEditController.desName = ""
        addMistakeEditController.targetInsItem = dataArea[areaIndex].items[row]
        self.navigationController?.pushViewController(addMistakeEditController, animated: true)
        
    }
	
	func longTapCamera(_ sender: UIGestureRecognizer){
		let button = sender.view as! UIButton
        let InsItem = dataArea[areaIndex].items[button.tag]
		if InsItem.picUrl.count != 0 {
			let alertController = UIAlertController(
				title: "提醒",
				message: String.init(format: "是否刪除照片"),
				preferredStyle: .alert)
			
			let okAction = UIAlertAction(title: "確定", style: .default) { (alertController) in
				do {
					let fileManager = FileManager.default
					let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
					let fileURL = documentDirectory.appendingPathComponent(InsItem.picUrl)
					try fileManager.removeItem(at: fileURL)
				} catch {
					print(error)
				}
				InsItem.picUrl = ""
				self.tableViewItem.reloadData()
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
		saveLocalData()
	}
	
    @objc func clickCheck(button: UIButton) {
		let InsItem = dataArea[areaIndex].items[button.tag]
        if InsItem.check == true && InsItem.result == 0 {
            InsItem.check = false
            InsItem.result = -1
            tableViewItem.reloadData()
            tableViewArea.reloadData()
            saveLocalData()
        } else {
            /*if InsItem.picUrl.count != 0 {
                let alertController = UIAlertController(
                    title: "提醒",
                    message: String.init(format: "是否刪除照片"),
                    preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "確定", style: .default) { (alertController) in
                    do {
                        let fileManager = FileManager.default
                        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                        let fileURL = documentDirectory.appendingPathComponent(InsItem.picUrl)
                        try fileManager.removeItem(at: fileURL)
                    } catch {
                        print(error)
                    }
                    InsItem.picUrl = ""
                    InsItem.check = true
                    InsItem.result = 0
                    InsItem.desId = ""
                    InsItem.inspRemark = ""
                    InsItem.picUrl = ""
                    self.tableViewItem.reloadData()
                }
                
                let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (alertController) in
                }
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                self.present(
                    alertController,
                    animated: true,
                    completion: nil)
            } else {*/
                InsItem.check = true
                InsItem.result = 0
                //InsItem.desId = ""
                //InsItem.inspRemark = ""
                //InsItem.picUrl = ""
                //InsItem.detect_amount = 0
                tableViewArea.reloadData()
                tableViewItem.reloadData()
                
            //}
            saveLocalData()
        }
	}
	
    @objc func tapLabel(sender: UITapGestureRecognizer) {
		let lbl = sender.view as! UILabel
		targetItem = dataArea[areaIndex].items[lbl.tag]
		showPopMenu()
	}
	
    @objc func clickMiss(button: UIButton) {
        targetItem = dataArea[areaIndex].items[button.tag]
        if targetItem.check == true && targetItem.result == 1 {
            targetItem.check = false
            targetItem.result = -1
            //targetItem.detect_amount = 0
            //targetItem.desId = ""
            //targetItem.inspRemark = ""
            //targetItem.picUrl = ""
            tableViewArea.reloadData()
            tableViewItem.reloadData()
            saveLocalData()
        } else {
            if targetItem.amount.count != 0 && targetItem.amount != "0" {
                //showPopupCount()
                self.targetItem.check = true
                self.targetItem.result = 1
                self.targetItem.status = 1
                tableViewArea.reloadData()
                self.tableViewItem.reloadData()
                self.saveLocalData()
            } else {
                targetItem.check = true
                targetItem.result = 1
                tableViewArea.reloadData()
                tableViewItem.reloadData()
                saveLocalData()
            }
        }
	}
    func showPopupCount() {
        let alertController = UIAlertController(title: "請輸入缺少數量", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "確定", style: .default, handler: { alert -> Void in
            let textField = alertController.textFields![0] as UITextField
            var num = Int(textField.text!)
            
            if num == nil {
                num = 0
                let alert = UIAlertController(title: "提醒", message: "缺少數量錯誤", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
                    
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                if num! > Int(self.targetItem.amount)! {
                    let alert = UIAlertController(title: "提醒", message: "缺少數量不可大於應有數量", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.targetItem.check = true
                    self.targetItem.result = 1
                    self.targetItem.status = 1
                    self.targetItem.detect_amount = num!
                    self.tableViewItem.reloadData()
                    self.saveLocalData()
                }
            }
        })
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler: { (action : UIAlertAction!) -> Void in })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.keyboardType = .numberPad
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
	
	func showPopMenu()
	{
		let alertController = UIAlertController(
			title: "請選擇缺失",
			message: "",
			preferredStyle: .alert)
		
		let cancelAction = UIAlertAction(
			title: "取消",
			style: .cancel,
			handler: nil)
		
		alertController.addAction(cancelAction)
		
		let s0Action = UIAlertAction(
			title: "損壞",
			style: .default,
			handler: { action in
				self.targetItem.check = true
				self.targetItem.result = 1
				self.targetItem.status = 0
				self.tableViewItem.reloadData()
				self.saveLocalData()
		})
		
		alertController.addAction(s0Action)
		
		let s1Action = UIAlertAction(
			title: "缺少",
			style: .default,
			handler: { action in
				self.targetItem.check = true
				self.targetItem.result = 1
				self.targetItem.status = 1
				self.tableViewItem.reloadData()
				self.saveLocalData()
		})
		
		alertController.addAction(s1Action)
		
		self.present(alertController, animated: true, completion: nil)
	}
	
	func clickCamera(button: UIButton) {
		do {
			targetItem = dataArea[areaIndex].items[button.tag]
			if targetItem.picUrl.count != 0 {
				let fileManager = FileManager.default
				let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
				let fileURL = documentDirectory.appendingPathComponent(targetItem.picUrl)
				print(targetItem.picUrl)
				let image = try UIImage.init(data: Data.init(contentsOf: fileURL), scale:1.0)
				var photos: [NYTPhoto] = []
                let title = NSAttributedString(string: targetItem.name, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
				let photo = Photo.init(image:image, attributedCaptionTitle: title)
				photos.append(photo)
				let photosViewController = NYTPhotosViewController(photos: photos)
				present(photosViewController, animated: true, completion: nil)
			} else {
				let cameraController = CameraController()
				cameraController.delegate = self
				self.navigationController?.pushViewController(cameraController, animated: true)
			}
		} catch {
			print(error)
		}
	}
	
	func didFinishPhoto(image:UIImage) {
		do {
			if let data = UIImagePNGRepresentation(image) {
				let fileManager = FileManager.default
				let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
				let userIdx = UserDefaults.standard.string(forKey: "UserIdx")
				let fileName = String.init(format: "%@_%.0f.png", userIdx!, NSDate().timeIntervalSince1970)
				let fileURL = documentDirectory.appendingPathComponent(fileName)
				try data.write(to: fileURL)
				targetItem.picUrl = fileName
				tableViewItem.reloadData()
			}
		} catch {
			print(error)
		}
		saveLocalData()
	}

    //MARK: Button Action
    @objc func btnBackPressed(sender: UIBarButtonItem) {
        if UserDefaults.standard.object(forKey: "ISRECORD") != nil {
            self.navigationController?.popViewController(animated: true)
            return
        }
        if checkNotFinish(0) {
			self.navigationController?.popViewController(animated: true)
		}
    }
    
    func checkNotFinish(_ mode:Int) -> Bool {
        var sumNotCheck = 0
        for area in dataArea {
            for item in area.items {
                if item.check == false {
                    sumNotCheck += 1
                }
            }
        }
        
        if sumNotCheck > 0 {
            let alertController = UIAlertController(
                title: "提醒",
                message: String.init(format: "還有%d項目未驗，請驗收完再進行下一步", sumNotCheck),
                preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "確定", style: .default) { (alertController) in
                if mode == 0 {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.navigationController?.pushViewController(InsDetectListSummaryController(), animated: true)
                }
                
            }
            
            alertController.addAction(okAction)
            self.present(
                alertController,
                animated: true,
                completion: nil)
            return false
        } else {
            return true
        }
    }
}
