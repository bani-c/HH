//
//  ViewController.swift
//  Home-Maintenance
//
//  Created by Bani on 14/09/2017.
//  Copyright © 2017 Ultron mobile. All rights reserved.
//

import UIKit
import SQLite

class DashboardController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

	// MARK: Variables
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var tfBuilding: UITextField!
	@IBOutlet weak var vwBuilding: UIView!
	@IBOutlet weak var lblProjectName: UILabel!
	var projectIndex:Int = 0
	var characterIndex:Int = 0
	var buildingIndex:Int = 0
	var buildings:[String] = []
	var floors:[String] = []
	var rooms:[[InsTargetData]] = []

	// MARK: Life Circle
	override func viewDidLoad() {
		super.viewDidLoad()
		initLayaout()
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initData()
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
		
        //init back button
        let btnBack = NaviTool.initBtnBack()
        btnBack.addTarget(self, action: #selector(btnBackPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(btnBack)
        
		//register nib
		collectionView.register(UINib(nibName: "HouseCell", bundle: nil), forCellWithReuseIdentifier:"HouseCell")
		collectionView.register(UINib(nibName: "HeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")

		//init project data
		lblProjectName.text = UserDefaults.standard.value(forKey: "PROJECT_NAME") as? String
		projectIndex = UserDefaults.standard.value(forKey: "PROJECT_INDEX") as! Int
		characterIndex = UserDefaults.standard.value(forKey: "CHARACTER_INDEX") as! Int

		//init building block
		vwBuilding.layer.borderColor = UIColor.init(red: 144.0 / 255.0, green: 33.0 / 255.0, blue: 38.0 / 255.0, alpha: 1.0).cgColor
		vwBuilding.layer.borderWidth = 1.5
	}
	
	func initData() {
		do {
            floors = []
            rooms = []
			let userDefaults = UserDefaults.standard
			let projectNo = userDefaults.string(forKey: "PROJECT_NO")
			if userDefaults.dictionary(forKey: "downloadSqlite") != nil {
				var downloadSqlite = [:] as [String:[String]]
				downloadSqlite = userDefaults.dictionary(forKey: "downloadSqlite") as! [String : [String]]
				for key in downloadSqlite.keys {
					if key == projectNo {
						buildings = downloadSqlite[key]!
						for building in buildings {
							let fileManager = FileManager.default
							let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
							let fileName = String.init(format: SystemConstants.DBFileNameSub, key, building)
							let fileURL = documentDirectory.appendingPathComponent(fileName)
							
							let db = try Connection(fileURL.absoluteString)
							
							let InspMaster = Table("InspMaster")
							let InspMstIdx = Expression<String?>("InspMstIdx")
							let BookingDate = Expression<String?>("BookingDate")
							let ELEVEL_1 = Expression<String?>("ELEVEL_1")
							let ELEVEL_2 = Expression<String?>("ELEVEL_2")
                            let ELEVEL_2_1 = Expression<String?>("ELEVEL_2_1")
                            let ELEVEL_2_2 = Expression<String?>("ELEVEL_2_2")
							let Subject = Expression<String?>("Subject")
							let RepairStatus = Expression<String?>("RepairStatus")
							let RecordType = Expression<String?>("RecordType")
							let Reinspection = Expression<String?>("Reinspection")
							let InspNo = Expression<String?>("InspNo")
							let IsValid = Expression<String?>("IsValid")
							let INSP_DATE = Expression<String?>("INSP_DATE")
							
							let query = InspMaster.select(distinct: ELEVEL_1).filter(ELEVEL_2_1 == building && IsValid == "Y" && RepairStatus == "Y").order(ELEVEL_1.asc)
							for data in try db.prepare(query) {
								print("name: \(String(describing: data[ELEVEL_1]))")
								floors.append(data[ELEVEL_1]!)
								let query = InspMaster.select(BookingDate, Subject, InspNo, InspMstIdx, RepairStatus, RecordType, Reinspection, INSP_DATE, ELEVEL_2_2, ELEVEL_1).filter(ELEVEL_2_1 == building && ELEVEL_1 == data[ELEVEL_1]!  && IsValid == "Y" && RepairStatus == "Y").order(ELEVEL_2_2.asc)
								var floor_room:[InsTargetData] = []
								for data in try db.prepare(query) {
									print("name: \(String(describing: data[ELEVEL_2_2])), date: \(String(describing: data[BookingDate]))")
									let insData = InsTargetData()
									insData.inspMstIdx = data[InspMstIdx]!
									insData.date = data[BookingDate]!
									insData.building = building
									insData.floor = data[ELEVEL_1]!
                                    insData.room = data[ELEVEL_2_2]!
									insData.inspDate = data[INSP_DATE]!
									insData.inspNo = data[InspNo]!
									insData.RepairStatus = data[RepairStatus]!
									insData.recordType = data[RecordType]!
                                    
                                    insData.recordType = "0"
                                    if data[Subject] != nil {
                                        insData.reinspection = data[Reinspection]!
                                    }
									if data[Subject] == nil {
										insData.subject = ""
									} else {
										insData.subject = data[Subject]!
									}
									
									let InspCheckFlowDetail = Table("InspCheckFlowDetail")
									
									let Result = Expression<String?>("Result")
									let ModifyStatus = Expression<String?>("ModifyStatus")
									let ChkNo = Expression<String?>("ChkNo")
									
									//Flow Data
									var query = InspCheckFlowDetail.filter(ELEVEL_2_2 == insData.room && ELEVEL_2_1 == building && ELEVEL_1 == insData.floor && Result == "N" && IsValid == "Y" && ChkNo == insData.inspNo && ModifyStatus == "Y")
									var count = try db.scalar(query.count)
									insData.repairCount += count
									
									query = InspCheckFlowDetail.filter(ELEVEL_2_2 == insData.room  && ELEVEL_2_1 == building && ELEVEL_1 == insData.floor && Result == "N" && IsValid == "Y" && ChkNo == insData.inspNo && (ModifyStatus != "Y" || ModifyStatus == nil))
									count = try db.scalar(query.count)
									insData.unRepairCount += count
									
									
									//General Data
									let InspDetail = Table("InspDetail")
									query = InspDetail.filter(ELEVEL_2_2 == insData.room  && ELEVEL_2_1 == building && ELEVEL_1 == insData.floor && Result == "N" && IsValid == "Y" && ChkNo == insData.inspNo && ModifyStatus == "Y")
									count = try db.scalar(query.count)
									insData.repairCount += count
									
									query = InspDetail.filter(ELEVEL_2_2 == insData.room  && ELEVEL_2_1 == building && ELEVEL_1 == insData.floor && Result == "N" && IsValid == "Y" && ChkNo == insData.inspNo && (ModifyStatus != "Y" || ModifyStatus == nil))
									count = try db.scalar(query.count)
									insData.unRepairCount += count
									if (insData.unRepairCount + insData.repairCount) != 0{
										floor_room.append(insData)
									}
								}
								rooms.append(floor_room)
							}
						}
					}
				}
			}
		} catch {
			//handle error
			print(error)
		}
		collectionView.reloadData()
	}
	
	func initTextField() {
		//init tfBuilding
		if buildings.count != 0 {
			buildingIndex = 0
			tfBuilding.text = buildings[buildingIndex]
		} else {
			buildingIndex = -1
		}
		tfBuilding.tintColor = .clear
		initTextField(textField: tfBuilding, tag: 0)
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

		let bgView = UIView(frame: CGRect(x: 0, y: 0, width:view.frame.width, height: 300))

		bgView.addSubview(picker)
		
		textField.inputView = bgView
	}

	// MARK: UIPickerViewDelegate
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return buildings.count
	}

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return buildings[row]
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		buildingIndex = row
		tfBuilding.text = buildings[buildingIndex]
		collectionView.reloadData()
	}

	// MARK: UICollectionViewDelegate
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return rooms[section].count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let room = rooms[indexPath.section][indexPath.row]
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"HouseCell", for: indexPath) as! HouseCell
		cell.setRoom(name: room.room)
		cell.isStartPair(start: false)
		cell.setProgress(rate: Float(room.repairCount) / Float(room.repairCount + room.unRepairCount))
		cell.setRepair(no: room.repairCount)
		cell.setUnrepair(no: room.unRepairCount)
		return cell
	}

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return floors.count
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let room = rooms[indexPath.section][indexPath.row]
        UserDefaults.standard.setValue(room.building, forKey: "BUILDING")
        UserDefaults.standard.setValue(room.floor, forKey: "FLOOR")
        UserDefaults.standard.setValue(room.room, forKey: "ROOM")
		InsTargetData.setSharedInstance(_instance: room)
        self.navigationController?.pushViewController(ChecklistController(), animated: true)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 145, height: 145);
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsetsMake(0, 0, 0, 0);
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 0.0;
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		return CGSize(width: 200, height: 80)
	}

	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

			if kind == UICollectionElementKindSectionHeader {
				let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", for: indexPath) as! HeaderView
				reusableView.setBuilding(name:floors[indexPath.section])
				return reusableView;

			}
			abort()
	}

    //MARK: Button Action
    @objc func btnBackPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func clickUpload(_ sender: Any) {
        let alert = UIAlertController(title: "提醒", message: "維修資料即將上傳雲端", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.destructive, handler:nil))
        alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.default, handler: { action in
            
            
            let projectsNo = UserDefaults.standard.string(forKey: "PROJECT_NO")
            let building = UserDefaults.standard.string(forKey: "BUILDING")
            
            let fileName = String.init(format: SystemConstants.DBFileNameSubUpload, projectsNo!, building!)
            InsTmpDataManager.sharedInstance().uploadSqlDBUpdate(fileName, view: self.view)
            
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
}

