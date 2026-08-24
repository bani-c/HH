//
//  ViewController.swift
//  Home-Maintenance
//
//  Created by Bani on 14/09/2017.
//  Copyright © 2017 Ultron mobile. All rights reserved.
//

import UIKit
import SQLite

class InsDashboardController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var lblBuilding: UILabel!
    @IBOutlet weak var lblFloor: UILabel!
    var floorData:[String] = []
    var buildingData:[String] = []
    // MARK: Variables
	@IBOutlet weak var lblProjectName: UILabel!
	var projectIndex:Int = 0
	var characterIndex:Int = 0
	var buildingIndex:Int = 0
    var targetBuilding = "全部"
    var targetFloor = "全部"
	var listData = [] as [InsTargetData]
	@IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var tfBuilding: UITextField!
    var verticalContentOffset:CGFloat  = 0
    var seletedIndex = 0
    // MARK: Life Circle
    @IBOutlet weak var tfFloor: UITextField!
    override func viewDidLoad() {
		super.viewDidLoad()
		
	}
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
    }

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: Custom Functions
	func initLayaout() {
		initData()
        initTextField()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(longPressGestureRecognizer:)))
        self.tableview.addGestureRecognizer(longPressRecognizer)
        
        //init back button
        let btnBack = NaviTool.initBtnBack()
        btnBack.addTarget(self, action: #selector(btnBackPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(btnBack)
		
		//register nib
		tableview.register(UINib(nibName: "InsHouseCell", bundle: nil), forCellReuseIdentifier: "InsHouseCell")

		//init project data
		lblProjectName.text = UserDefaults.standard.value(forKey: "PROJECT_NAME") as? String
		projectIndex = UserDefaults.standard.value(forKey: "PROJECT_INDEX") as! Int
		characterIndex = UserDefaults.standard.value(forKey: "CHARACTER_INDEX") as! Int
        
        
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
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.tableview)
            if let indexPath = self.tableview.indexPathForRow(at: touchPoint) {
                let data = listData[indexPath.row]
                let alert = UIAlertController(title: nil, message: data.displayTitle, preferredStyle: .alert)
                if data.reinspection == "Y" || data.RepairStatus == "Y" {
                    alert.addAction(UIAlertAction(title: NSLocalizedString("重新驗屋", comment: ""), style: .default) { _ in
                        UserDefaults.standard.removeObject(forKey: "ISRECORD")
                        data.reinspection = "N"
                        data.inspNo = String(Int(data.inspNo)! + 1)
                        InsTargetData.setSharedInstance(_instance: data)
                        UserDefaults.standard.setValue(data.building, forKey: "BUILDING")
                        UserDefaults.standard.setValue(data.floor, forKey: "FLOOR")
                        UserDefaults.standard.setValue(data.room, forKey: "ROOM")
                        let insDetectFlowController = InsDetectFlowController()
                        insDetectFlowController.projectName = self.lblProjectName.text
                        insDetectFlowController.caseName = data.inspMstIdx
                    self.navigationController?.pushViewController(insDetectFlowController, animated: true)
                    })
                }
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("查看驗屋紀錄", comment: ""), style: .default) { _ in
                    UserDefaults.standard.setValue(true, forKey: "RECORDHASTARGET")
                    InsTargetData.setSharedInstance(_instance: data)
                    self.navigationController?.pushViewController(InsDashboardRecordController.init(), animated: true)
                })
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .default) { _ in
                    
                })

                self.present(alert, animated: true, completion: nil)
               
            }
        }
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		InsTmpDataManager.sharedInstance().clearData()
        initLayaout()
        tableview.scrollToRow(at: IndexPath(row: seletedIndex, section: 0), at: .middle, animated: false)
	}
	
	func initData() {
        buildingData.removeAll()
        buildingData.append("全部")
        floorData.removeAll()
        floorData.append("全部")
		do {
			//check if data is download
			let userDefaults = UserDefaults.standard
			let projectNo = userDefaults.string(forKey: "PROJECT_NO")
			if userDefaults.dictionary(forKey: "downloadSqlite") != nil {
				var downloadSqlite = [:] as [String:[String]]
				downloadSqlite = userDefaults.dictionary(forKey: "downloadSqlite") as! [String : [String]]
				listData = []
				for key in downloadSqlite.keys {
					if key == projectNo {
						let buildings = downloadSqlite[key]
						for building in buildings! {
							let fileManager = FileManager.default
							let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
							let fileName = String.init(format: SystemConstants.DBFileNameSub, key, building)
							let fileURL = documentDirectory.appendingPathComponent(fileName)
							
							let db = try Connection(fileURL.absoluteString)
							
							let table = Table("InspMaster")
							let table_inspMstIdx = Expression<String?>("InspMstIdx")
							let table_date = Expression<String?>("BookingDate")
							let table_elv_1 = Expression<String?>("ELEVEL_1")
							let table_elv_2_1 = Expression<String?>("ELEVEL_2_1")
                            let table_elv_2_2 = Expression<String?>("ELEVEL_2_2")
							let table_RepairStatus = Expression<String?>("RepairStatus")
							let table_recordType = Expression<String?>("RecordType")
							let table_reinspection = Expression<String?>("Reinspection")
							let table_inspNo = Expression<String?>("InspNo")
							let table_isValid = Expression<String?>("IsValid")
							let INSP_DATE = Expression<String?>("INSP_DATE")
							
							let query = table.select(table_inspMstIdx, table_date, table_inspNo, table_elv_1, table_elv_2_2, table_elv_2_1, table_RepairStatus, table_recordType, table_reinspection, INSP_DATE).filter(table_elv_2_1 == building && table_isValid == "Y").order(table_date.desc, table_elv_2_1.asc, table_elv_1.asc, table_elv_2_2.asc)
                            
                            for data in try db.prepare(query) {
                               
                                print("name: \(String(describing: data[table_elv_1])), date: \(String(describing: data[table_date]))")
                                let insData = InsTargetData()
                                insData.inspMstIdx = data[table_inspMstIdx]!
                                if data[table_date] != nil {
                                    insData.date = data[table_date]!
                                }
                                insData.building = building
                                insData.floor = data[table_elv_1]!
                                insData.room = data[table_elv_2_2]!
                                if data[INSP_DATE] != nil {
                                   insData.inspDate = data[INSP_DATE]!
                                }
                                
                                insData.inspNo = data[table_inspNo]!
                                insData.RepairStatus = data[table_RepairStatus]!
                                if data[table_recordType] != nil {
                                    insData.recordType = data[table_recordType]!
                                }
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
                                
                                if !buildingData.contains(data[table_elv_2_1]!) {
                                    buildingData.append(data[table_elv_2_1]!)
                                }
                                if !floorData.contains(data[table_elv_1]!) {
                                    floorData.append(data[table_elv_1]!)
                                }
                            }
						}
						
					}
					tableview.reloadData()
				}
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
        if data.RepairStatus == "Y" {
            cell.ivCheck.isHidden = false
        } else {
            cell.ivCheck.isHidden = true
        }
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let inspData = listData[indexPath.row]
		InsTargetData.setSharedInstance(_instance: inspData)
		UserDefaults.standard.removeObject(forKey: "ISRECORD")
        
        if inspData.RepairStatus != "Y" {
            if Int(InsTargetData.sharedInstance().inspNo)! > 1 {
                InsTargetData.sharedInstance().reinspection = "Y"
            }
            verticalContentOffset = tableview.contentOffset.y
            seletedIndex = indexPath.row
            UserDefaults.standard.setValue(inspData.building, forKey: "BUILDING")
            UserDefaults.standard.setValue(inspData.floor, forKey: "FLOOR")
            UserDefaults.standard.setValue(inspData.room, forKey: "ROOM")
            let insDetectFlowController = InsDetectFlowController()
            insDetectFlowController.projectName = lblProjectName.text
            insDetectFlowController.caseName = inspData.inspMstIdx
            self.navigationController?.pushViewController(insDetectFlowController, animated: true)
        } else {
            if checkIsNotUpload(inspData) {
                seletedIndex = indexPath.row
                verticalContentOffset = tableview.contentOffset.y
                InsTargetData.sharedInstance().reinspection = "ALL"
                UserDefaults.standard.setValue(inspData.building, forKey: "BUILDING")
                UserDefaults.standard.setValue(inspData.floor, forKey: "FLOOR")
                UserDefaults.standard.setValue(inspData.room, forKey: "ROOM")
                let insDetectFlowController = InsDetectFlowController()
                insDetectFlowController.projectName = lblProjectName.text
                insDetectFlowController.caseName = inspData.inspMstIdx
                self.navigationController?.pushViewController(insDetectFlowController, animated: true)
            }
        }
        /*
		if InsTargetData.sharedInstance().reinspection == "Y" {
            if inspData.RepairStatus != "Y" {
                UserDefaults.standard.setValue(inspData.building, forKey: "BUILDING")
                UserDefaults.standard.setValue(inspData.floor, forKey: "FLOOR")
                UserDefaults.standard.setValue(inspData.room, forKey: "ROOM")
                let insDetectFlowController = InsDetectFlowController()
                insDetectFlowController.projectName = lblProjectName.text
                insDetectFlowController.caseName = inspData.inspMstIdx
               self.navigationController?.pushViewController(insDetectFlowController, animated: true)
            } else {
                InsTargetData.sharedInstance().reinspection = "ALL"
                if checkIsNotUpload(inspData) {
                    UserDefaults.standard.setValue(inspData.building, forKey: "BUILDING")
                    UserDefaults.standard.setValue(inspData.floor, forKey: "FLOOR")
                    UserDefaults.standard.setValue(inspData.room, forKey: "ROOM")
                    let insDetectFlowController = InsDetectFlowController()
                    insDetectFlowController.projectName = lblProjectName.text
                    insDetectFlowController.caseName = inspData.inspMstIdx
                self.navigationController?.pushViewController(insDetectFlowController, animated: true)
                }
            }
		} else if inspData.RepairStatus != "Y" {
			UserDefaults.standard.setValue(inspData.building, forKey: "BUILDING")
			UserDefaults.standard.setValue(inspData.floor, forKey: "FLOOR")
            UserDefaults.standard.setValue(inspData.room, forKey: "ROOM")
			let insDetectFlowController = InsDetectFlowController()
			insDetectFlowController.projectName = lblProjectName.text
			insDetectFlowController.caseName = inspData.inspMstIdx
			self.navigationController?.pushViewController(insDetectFlowController, animated: true)
        } else {
            if checkIsNotUpload(inspData) {
                InsTargetData.sharedInstance().reinspection = "ALL"
                UserDefaults.standard.setValue(inspData.building, forKey: "BUILDING")
                UserDefaults.standard.setValue(inspData.floor, forKey: "FLOOR")
                UserDefaults.standard.setValue(inspData.room, forKey: "ROOM")
                let insDetectFlowController = InsDetectFlowController()
                insDetectFlowController.projectName = lblProjectName.text
                insDetectFlowController.caseName = inspData.inspMstIdx
                self.navigationController?.pushViewController(insDetectFlowController, animated: true)
            }
        }
 */
	}
    
    func checkIsNotUpload(_ data:InsTargetData) -> Bool {
        do {
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let projectsNo = UserDefaults.standard.string(forKey: "PROJECT_NO")
            let building = data.building
            let floor = data.floor
            let room = data.room
            let subFileURL = documentDirectory.appendingPathComponent(String.init(format: SystemConstants.DBFileNameSubUpload, projectsNo!, building))
            let db = try Connection(subFileURL.absoluteString)
            
            let targetChkNo = InsTargetData.sharedInstance().inspNo
            
            let InspCheckFlowDetail = Table("InspCheckFlowDetail")
            let InspDetail = Table("InspDetail")
            let ELEVEL_2_1 = Expression<String?>("ELEVEL_2_1")
            let ELEVEL_2_2 = Expression<String?>("ELEVEL_2_2")
            let ELEVEL_1 = Expression<String?>("ELEVEL_1")
            let AreaId = Expression<String?>("AreaId")
            let IsValid = Expression<String?>("IsValid")
            let ChkNo = Expression<String?>("ChkNo")
            
            let query = InspCheckFlowDetail.select(distinct:AreaId).filter( ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && IsValid == "Y" && ChkNo == targetChkNo)
            let count = try db.scalar(query.count)
            if count != 0 {
                return true
            } else {
                let query = InspDetail.select(distinct:AreaId).filter( ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && IsValid == "Y" && ChkNo == targetChkNo)
                let count = try db.scalar(query.count)
                if count != 0 {
                    return true
                } else {
                    return false
                }
            }
           
        } catch {
            //handle error
            print(error)
        }
        return false
    }

    //MARK: Button Action
    @objc func btnBackPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
	
	@IBAction func btnListPressed(sender: AnyObject) {
		let button = sender as! UIButton
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		alert.addAction(UIAlertAction(title: NSLocalizedString("InsMenu_Sync", comment: ""), style: .default) { _ in
            var NeedUpdateArr:[String] = []
            if UserDefaults.standard.object(forKey: "NeedUpdateArr") != nil {
                NeedUpdateArr = UserDefaults.standard.object(forKey: "NeedUpdateArr") as! [String]
            }
            if NeedUpdateArr.count > 0 {
                UserDefaults.standard.set(0, forKey: "NeedUpdateArrIndex")
                InsTmpDataManager.sharedInstance().uploadSqlDB(NeedUpdateArr[0], view: self.view)
            } else {
                UserDefaults.standard.set(0, forKey: "NeedUpdateArrIndex")
                let alert = UIAlertController(title: "", message: "上傳完成", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
               
//            let projectNo = UserDefaults.standard.string(forKey: "PROJECT_NO")
//            if UserDefaults.standard.dictionary(forKey: "downloadSqlite") != nil {
//
//
//                DispatchQueue.main.async {
//                    var downloadSqlite = [:] as [String:[String]]
//                    downloadSqlite = UserDefaults.standard.dictionary(forKey: "downloadSqlite") as! [String : [String]]
//                    for key in downloadSqlite.keys {
//                        if key == projectNo {
//                            let buildings = downloadSqlite[key]
//                            let buidingDoing = UserDefaults.standard.string(forKey: "BUILDING") ?? ""
//                            for building in buildings! {
//                                if buidingDoing.isEmpty {
//                                    UserDefaults.standard.set(building, forKey: "BUILDING")
//                                    let fileName = String.init(format: SystemConstants.DBFileNameSubUpload, projectNo!, building)
//                                    InsTmpDataManager.sharedInstance().uploadSqlDBUpdate(fileName, view: self.view)
//
//                                } else if buidingDoing == building {
//                                    let fileName = String.init(format: SystemConstants.DBFileNameSubUpload, projectNo!, building)
//                                    InsTmpDataManager.sharedInstance().uploadSqlDBUpdate(fileName, view: self.view)
//                                }
//                            }
//                        }
//                    }
//                    //InsTmpDataManager.sharedInstance().goUpdate()
//                    self.initLayaout()
//                }
//            }
            
            
            
			
		})
		/*
		alert.addAction(UIAlertAction(title: NSLocalizedString("InsMenu_News", comment: ""), style: .default) { _ in
            self.seletedIndex = button.tag
			self.navigationController?.pushViewController(NewsController.init(), animated: true)
		})
        */
        alert.addAction(UIAlertAction(title: NSLocalizedString("InsMenu_Booking", comment: ""), style: .default) { _ in
            self.seletedIndex = button.tag
            self.navigationController?.pushViewController(BookingController.init(), animated: true)
        })
 /*
        alert.addAction(UIAlertAction(title: NSLocalizedString("InsMenu_Case", comment: ""), style: .default) { _ in
			
		})
*/
		alert.addAction(UIAlertAction(title: NSLocalizedString("InsMenu_Record", comment: ""), style: .default) { _ in
            self.seletedIndex = button.tag
            UserDefaults.standard.removeObject(forKey: "RECORDHASTARGET")
			self.navigationController?.pushViewController(InsDashboardRecordController.init(), animated: true)
		})
/*
		alert.addAction(UIAlertAction(title: NSLocalizedString("InsMenu_Logout", comment: ""), style: .default) { _ in
			
		})
*/
		
		let popPresenter = alert.popoverPresentationController
		popPresenter?.sourceView = button
		popPresenter?.sourceRect = button.bounds
		present(alert, animated: true)
	}
	
    
}
