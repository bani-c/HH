//
//  ViewController.swift
//  Home-Maintenance
//
//  Created by Bani on 14/09/2017.
//  Copyright © 2017 Ultron mobile. All rights reserved.
//

import UIKit
import SQLite

class InsDashboardRecordController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
	// MARK: Variables
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblProjectName: UILabel!
    @IBOutlet weak var lblBuilding: UILabel!
    @IBOutlet weak var lblFloor: UILabel!
	var projectIndex:Int = 0
	var characterIndex:Int = 0
	var buildingIndex:Int = 0
    var floorData:[String] = []
    var buildingData:[String] = []
	var listData = [] as [InsTargetData]
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var tfBuilding: UITextField!
	 @IBOutlet weak var tfFloor: UITextField!
    var targetBuilding = "全部"
    var targetFloor = "全部"

	// MARK: Life Circle
	override func viewDidLoad() {
		super.viewDidLoad()
		initLayaout()
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
		
		//register nib
		tableview.register(UINib(nibName: "InsHouseCell", bundle: nil), forCellReuseIdentifier: "InsHouseCell")

		//init project data
        if UserDefaults.standard.object(forKey: "RECORDHASTARGET") != nil {
            lblTitle.text = "驗屋紀錄_" + InsTargetData.sharedInstance().building + "_" + InsTargetData.sharedInstance().floor + "_" + InsTargetData.sharedInstance().room;
        } else {
            lblTitle.text = "驗屋紀錄";
        }
		lblProjectName.text = UserDefaults.standard.value(forKey: "PROJECT_NAME") as? String
		projectIndex = UserDefaults.standard.value(forKey: "PROJECT_INDEX") as! Int
		characterIndex = UserDefaults.standard.value(forKey: "CHARACTER_INDEX") as! Int
        
        initTextField()
	}
    
    func initTextField() {
        initTextField(textField: tfBuilding, tag: 0)
        initTextField(textField: tfFloor, tag: 1)
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
    
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		InsTmpDataManager.sharedInstance().clearData()
	}
	
	func initData() {
        buildingData.removeAll()
        buildingData.append("全部")
        floorData.removeAll()
        floorData.append("全部")
		do {
			//check if data is download
			let userDefaults = UserDefaults.standard
			//let projectNo = userDefaults.string(forKey: "PROJECT_NO")
            //let building = UserDefaults.standard.string(forKey: "BUILDING")
			if userDefaults.dictionary(forKey: "downloadSqlite") != nil {
								listData = []
                let data = InsTargetData.sharedInstance()
                var no = Int(data.inspNo) ?? 0
                if data.RepairStatus == "Y" {
                    no += 1
                } 
                if no < 2 {
                    return
                }
                for i in 1...no - 1 {
                    let insData = InsTargetData()
                    insData.inspMstIdx = data.inspMstIdx
                    insData.date = data.date
                    insData.building = data.building
                    insData.floor = data.floor
                    insData.room = data.room
                    insData.inspDate = data.inspDate
                    insData.inspNo = String(i)
                    insData.RepairStatus = data.RepairStatus
                    insData.recordType = data.recordType
                    listData.append(insData)
                }
                tableview.reloadData()
                /*
				for key in downloadSqlite.keys {
					if key == projectNo {
						let buildings = downloadSqlite[key]
						for building in buildings! {
                            if UserDefaults.standard.object(forKey: "RECORDHASTARGET") != nil {
                                let data = InsTargetData.sharedInstance()
                                if building != data.building {
                                    break
                                }
                            }
							let fileManager = FileManager.default
							let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
							let fileName = String.init(format: SystemConstants.DBFileNameSub, key, building)
							let fileURL = documentDirectory.appendingPathComponent(fileName)
							
							let db = try Connection(fileURL.absoluteString)
							
							let InspMaster = Table("InspMaster")
							let InspMstIdx = Expression<String?>("InspMstIdx")
							let table_date = Expression<String?>("BookingDate")
							let table_elv_1 = Expression<String?>("ELEVEL_1")
							let table_elv_2 = Expression<String?>("ELEVEL_2")
                            let ELEVEL_2_1 = Expression<String?>("ELEVEL_2_1")
                            let ELEVEL_2_2 = Expression<String?>("ELEVEL_2_2")
							let table_RepairStatus = Expression<String?>("RepairStatus")
							let table_recordType = Expression<String?>("RecordType")
							let table_reinspection = Expression<String?>("Reinspection")
							let table_inspNo = Expression<String?>("InspNo")
							let table_isValid = Expression<String?>("IsValid")
							let INSP_DATE = Expression<String?>("INSP_DATE")
                            let RepairStatus = Expression<String?>("RepairStatus")
                            
                            
                            
                            var query = InspMaster.select(InspMstIdx, table_date, table_inspNo, table_elv_1, table_elv_2, ELEVEL_2_2, ELEVEL_2_1, table_RepairStatus, table_recordType, table_reinspection, INSP_DATE).filter(ELEVEL_2_1 == building && RepairStatus == "Y").order(table_inspNo.desc)
                            
							if UserDefaults.standard.object(forKey: "RECORDHASTARGET") != nil {
                                let data = InsTargetData.sharedInstance()
                                query = InspMaster.select(InspMstIdx, table_date, table_inspNo, table_elv_1, table_elv_2, ELEVEL_2_2, ELEVEL_2_1, table_RepairStatus, table_recordType, table_reinspection, INSP_DATE).filter(ELEVEL_2_1 == building && RepairStatus == "Y" && table_elv_1 == data.floor && ELEVEL_2_2 == data.room).order(table_inspNo.desc)
                            }
							
							for data in try db.prepare(query) {
								print("name: \(String(describing: data[table_elv_1])), date: \(String(describing: data[table_date]))")
								let insData = InsTargetData()
								insData.inspMstIdx = data[InspMstIdx]!
								insData.date = data[table_date]!
								insData.building = building
								insData.floor = data[table_elv_1]!
                                insData.room = data[ELEVEL_2_2]!
								insData.inspDate = data[INSP_DATE]!
								insData.inspNo = data[table_inspNo]!
								insData.RepairStatus = data[table_RepairStatus]!
								insData.recordType = data[table_recordType]!
                                
                                insData.recordType = "0"
                                if data[table_reinspection] != nil {
                                    insData.reinspection = data[table_reinspection]!
                                }
								
                                if targetBuilding != "全部" || targetFloor != "全部" {
                                    if targetBuilding != "全部" && targetFloor != "全部" {
                                        if insData.building == targetBuilding && insData.floor == targetFloor {
                                            listData.append(insData)
                                        }
                                    } else if targetBuilding != "全部" {
                                        if insData.building == targetBuilding {
                                            listData.append(insData)
                                        }
                                    } else if targetFloor != "全部" {
                                        if insData.floor == targetFloor {
                                            listData.append(insData)
                                        }
                                    }
                                } else {
                                    listData.append(insData)
                                }
                                if !buildingData.contains(data[ELEVEL_2_1]!) {
                                    buildingData.append(data[ELEVEL_2_1]!)
                                }
                                if !floorData.contains(data[table_elv_1]!) {
                                    floorData.append(data[table_elv_1]!)
                                }
							}
                        
						}
					}
					tableview.reloadData()
				}*/
			}
		} catch {
			//handle error
			print(error)
		}
	}
    
    // MARK: UIPickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return buildingData.count
        } else if pickerView.tag == 1 {
            return floorData.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return buildingData[row]
        } else if pickerView.tag == 1 {
            return floorData[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            targetBuilding = buildingData[row]
            if row == 0 {
                lblBuilding.text = "棟"
            } else {
                lblBuilding.text = String.init(format: "棟(%@)",  targetBuilding)
            }
            initData()
        } else if pickerView.tag == 1 {
            targetFloor = floorData[row]
            if row == 0 {
                lblFloor.text = "樓"
            } else {
                lblFloor.text = String.init(format: "樓(%@)",  targetFloor)
            }
            initData()
        }
    }
    

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return listData.count
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 70.0;//Choose your custom row height
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "InsHouseCell", for: indexPath) as! InsHouseCell
		let data = listData[indexPath.row]
		cell.lblNo.text = String(indexPath.row + 1) + "."
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: data.date)
        let dateFormatterNew = DateFormatter()
        dateFormatterNew.dateFormat = "yyyy-MM-dd HH:mm"
        cell.lblTime.text = dateFormatterNew.string(from: date!)

        //cell.lblTime.text = data.date
		cell.lblBuild.text = data.building
		cell.lblFloor.text = data.floor
        cell.lblRoom.text = data.room
		cell.lblProgress.text = data.inspNo
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let inspData = listData[indexPath.row]
        //inspData.inspNo = String(Int(inspData.inspNo)! - 1)
		InsTargetData.setSharedInstance(_instance: inspData)
        UserDefaults.standard.setValue(inspData.building, forKey: "BUILDING")
        UserDefaults.standard.setValue(inspData.floor, forKey: "FLOOR")
        UserDefaults.standard.setValue(inspData.room, forKey: "ROOM")
		UserDefaults.standard.setValue(true, forKey: "ISRECORD")
        self.navigationController?.pushViewController(InsDetectListRecordController(), animated: true)
	}

    //MARK: Button Action
    @objc func btnBackPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
	
	@IBAction func btnListPressed(sender: AnyObject) {
		let button = sender as! UIButton
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		alert.addAction(UIAlertAction(title: NSLocalizedString("InsMenu_Sync", comment: ""), style: .default) { _ in
			
		})
	
		alert.addAction(UIAlertAction(title: NSLocalizedString("InsMenu_Record", comment: ""), style: .default) { _ in
			
		})
		
		let popPresenter = alert.popoverPresentationController
		popPresenter?.sourceView = button
		popPresenter?.sourceRect = button.bounds
		present(alert, animated: true)
	}
}

