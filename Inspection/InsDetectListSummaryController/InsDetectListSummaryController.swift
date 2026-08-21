//
//  ViewController.swift
//  Home-Maintenance
//
//  Created by Bani on 14/09/2017.
//  Copyright © 2017 Ultron mobile. All rights reserved.
//

import UIKit
import NYTPhotoViewer

class InsDetectListSummaryController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
	
	@IBOutlet weak var lblTitle: UILabel!
	@IBOutlet weak var tableView: UITableView!
	public var opName: String!
	public var caseName: String!
	public var projectName: String!
	var projectIndex:Int = 0
	var characterIndex:Int = 0
	var buildingIndex:Int = 0
	var catOpName:[String] = []
	var catOpId:[String] = []
	var catArea:[String] = []
	var catFilter = ["缺失項目", "通過項目", "全部項目"]
	var targetAreaData:[InsAreaItem] = []
    var tmpAreaItem:InsAreaItem = InsAreaItem.init()
	var opIndex = 0
	var areaIndex:Int = 0
	var catFilterIndex:Int = 0
	
	@IBOutlet weak var tfCat0: UITextField!
	@IBOutlet weak var tfCat1: UITextField!
	@IBOutlet weak var tfCat2: UITextField!
	// MARK: Life Circle
	override func viewDidLoad() {
		super.viewDidLoad()
		initLayaout()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        refreshLayout()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	

	// MARK: Custom Functions
	func initLayaout() {
		
        initData()
    
		//set title
		lblTitle.text = "驗屋缺失清單"
		
		//register nib
		tableView.register(UINib(nibName: "InsDetect0HeaderCell", bundle: nil), forCellReuseIdentifier: "InsDetect0HeaderCell")
		tableView.register(UINib(nibName: "InsDetect0ItemCell", bundle: nil), forCellReuseIdentifier: "InsDetect0ItemCell")
		
        //init back button
        let btnBack = NaviTool.initBtnBack()
        btnBack.addTarget(self, action: #selector(btnBackPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(btnBack)
	}
	
	func initData() {
		catOpName = InsTmpDataManager.sharedInstance().flowNameData
		catOpName.append("一般檢核項目")
		//catOpName.append("新增缺失")
		catOpId = InsTmpDataManager.sharedInstance().flowIdData
		catOpId.append("Ins")
		//catOpId.append("Add")
		//print(catOpId[opIndex] + "_DataArea")
		initAreaItem()
	}
	
	func initAreaItem() {
        let tmpAreaData = InsTmpDataManager.sharedInstance().dicArea[catOpId[opIndex] + "_DataArea"]!
        targetAreaData.removeAll()
        tmpAreaItem = InsAreaItem.init()
        for areaData in tmpAreaData {
            let aData = InsAreaItem.init()
            aData.name = areaData.name
            aData.type = areaData.type
            aData.places = []
            for place in areaData.places {
                let tmpPlace = InsPlaceItem.init()
                tmpPlace.name = place.name
                for item in place.items {
                    tmpPlace.items.append(item)
                }
                aData.places.append(tmpPlace)
            }
            aData.items = []
            for item in areaData.items {
                aData.items.append(item)
            }
            targetAreaData.append(aData)
        }
        if targetAreaData.count == 0 || areaIndex == -1 {
            return
        }
        tmpAreaItem = targetAreaData[areaIndex]
        if tmpAreaItem.type == 0 {
            tmpAreaItem.places.removeAll()
            let insPlaceItem = InsPlaceItem.init()
            insPlaceItem.name = "檢核項目"
            for insItem in tmpAreaItem.items {
                if catFilterIndex == 0 {
                    if insItem.result == 1 {
                        insPlaceItem.items.append(insItem)
                    }
                } else if catFilterIndex == 1 {
                    if insItem.result == 0 {
                       insPlaceItem.items.append(insItem)
                    }
                } else if catFilterIndex == 2 {
                    insPlaceItem.items.append(insItem)
                }
            }
            if insPlaceItem.items.count != 0 {
                tmpAreaItem.places.append(insPlaceItem)
            }
        } else {
            var tmpPlaces:[InsPlaceItem] = []
            for placeItem in tmpAreaItem.places {
                var tmpItems:[InsItem] = []
                for insItem in placeItem.items {
                    if catFilterIndex == 0 {
                        if insItem.result == 1 {
                            tmpItems.append(insItem)
                        }
                    } else if catFilterIndex == 1 {
                        if insItem.result == 0 {
                            tmpItems.append(insItem)
                        }
                    } else if catFilterIndex == 2 {
                         tmpItems.append(insItem)
                    }
                }
                if tmpItems.count != 0 {
                    placeItem.items = tmpItems
                    tmpPlaces.append(placeItem)
                }
            }
            tmpAreaItem.places = tmpPlaces
        }
	}
    
    func refreshLayout() {
        initTextField()
        initAreaItem()
        if targetAreaData.count > 0 {
            areaIndex = 0
            let insAreaItem = targetAreaData[areaIndex]
            tfCat1.text = insAreaItem.name
        } else {
            areaIndex = -1
            tfCat1.text = ""
        }
        tableView.reloadData()
    }
	
	func initTextField() {
		initTextField(textField: tfCat0, tag: 0)
		initTextField(textField: tfCat1, tag: 1)
		initTextField(textField: tfCat2, tag: 2)
        areaIndex = 0
        catFilterIndex = 0
        tfCat0.text = catOpName[opIndex]
        tfCat2.text = catFilter[catFilterIndex]
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
		
		let bgView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
		
		bgView.addSubview(picker)

		textField.inputView = bgView
	}
	
	// MARK: UIPickerViewDelegate
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if pickerView.tag == 0 {
			return catOpName.count
		} else if pickerView.tag == 1 {
			return targetAreaData.count
		} else {
			return catFilter.count
		}
		
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if pickerView.tag == 0 {
			return catOpName[row]
		} else if pickerView.tag == 1 {
			let insAreaItem = targetAreaData[row]
			return insAreaItem.name
		} else {
			return catFilter[row]
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if pickerView.tag == 0 {
			opIndex = row
			tfCat0.text = catOpName[opIndex]
            areaIndex = 0
			tfCat2.text = catFilter[catFilterIndex]
            initAreaItem()
			if targetAreaData.count > 0 {
				areaIndex = 0
				let insAreaItem = targetAreaData[areaIndex]
				tfCat1.text = insAreaItem.name
			} else {
				areaIndex = -1
				tfCat1.text = ""
			}
		} else if pickerView.tag == 1 {
			areaIndex = row
			tfCat1.text = targetAreaData[areaIndex].name
			tfCat2.text = catFilter[catFilterIndex]
            initAreaItem()
		} else {
			catFilterIndex = row
			tfCat2.text = catFilter[catFilterIndex]
            initAreaItem()
		}
		tableView.reloadData()
        if areaIndex >= 0 && areaIndex < tmpAreaItem.places.count && tmpAreaItem.places[areaIndex].items.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
	}
	
	//MARK: TableView Datasource and Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return tmpAreaItem.places.count
    }
    
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if areaIndex == -1 {
			return 0
		}
		return tmpAreaItem.places[section].items.count
	}
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 70.0
	}
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 0 {
            return nil
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InsDetect0HeaderCell") as! InsDetect0HeaderCell
            cell.lblTitle.text = tmpAreaItem.places[section].name
            return cell
        }
    }
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "InsDetect0ItemCell", for: indexPath) as! InsDetect0ItemCell
		cell.selectionStyle = .none
		let insItem = tmpAreaItem.places[indexPath.section].items[indexPath.row]
		cell.lblTitle.text = String(indexPath.row + 1) + "." + insItem.name
		cell.setCheck(InsItem: insItem)
		if insItem.picUrl.count != 0 {
			cell.btnCamera.isHidden = false
			cell.btnCamera.tag = indexPath.section * 10000 + indexPath.row
			cell.btnCamera.addTarget(self, action: #selector(clickCamera(button:)), for: UIControlEvents.touchUpInside)
		} else {
			cell.btnCamera.isHidden = true
		}
		
		return cell
	}
	
    @objc func clickCamera(button: UIButton) {
		do {
            let section = button.tag / 10000
            let row = button.tag % 10000
            let insItem = tmpAreaItem.places[section].items[row]
			let fileManager = FileManager.default
			let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
			let fileURL = documentDirectory.appendingPathComponent(insItem.picUrl)
			let image = try UIImage.init(data: Data.init(contentsOf: fileURL), scale:1.0)
			var photos: [NYTPhoto] = []
            let title = NSAttributedString(string: insItem.name, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
			let photo = Photo.init(image:image, attributedCaptionTitle: title)
			photos.append(photo)
			let photosViewController = NYTPhotosViewController(photos: photos)
			present(photosViewController, animated: true, completion: nil)
			
		} catch {
			print(error)
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if opIndex == catOpName.count - 1{
            let InsItemDelete = tmpAreaItem.places[indexPath.section].items[indexPath.row]
			let alert = UIAlertController(title: "提醒", message: "是否刪除新增資料？" + InsItemDelete.name, preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.destructive, handler:nil))
			alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
                let targetAreaData = InsTmpDataManager.sharedInstance().dicArea["Add_DataArea"]!
                targetAreaData[self.areaIndex].places[indexPath.section].items.remove(at: indexPath.row)
                InsTmpDataManager.sharedInstance().dicArea["Add_DataArea"] = targetAreaData
                self.tmpAreaItem.places[indexPath.section].items.remove(at: indexPath.row)
				self.tableView.reloadData()
			}))
			self.present(alert, animated: true, completion: nil)
		}
	}
	
    //MARK: Button Action
    @objc func btnBackPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
	
	@IBAction func btnAddPressed(_ sender: Any) {
		self.navigationController?.pushViewController(AddMistakeController(), animated: true)
	}
	
	@IBAction func btnNextPressed(_ sender: Any) {
		self.navigationController?.pushViewController(InsDetectListConfirmController(), animated: true)
	}
	
}


