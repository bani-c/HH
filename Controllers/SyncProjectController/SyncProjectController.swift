//
//  ViewController.swift
//  Home-Maintenance
//
//  Created by Bani on 14/09/2017.
//  Copyright © 2017 Ultron mobile. All rights reserved.
//

import UIKit
import JGProgressHUD
import VeloxDownloader
import SQLite

class SyncProjectController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
	// MARK: Variables

	@IBOutlet weak var btnSync: UIButton!
	@IBOutlet weak var vwProject: UIView!
	@IBOutlet weak var vwBuilding: UIView!
	@IBOutlet weak var vwFloor: UIView!
	@IBOutlet weak var vwRoom: UIView!
	@IBOutlet weak var tfProject: UITextField!
	@IBOutlet weak var tfBuilding: UITextField!
	@IBOutlet weak var tfFloor: UITextField!
	@IBOutlet weak var tfRoom: UITextField!
	var downloadSqlite = [:] as [String:[String]]
	var projectsData = [] as [String]
	var projectsNoData = [] as [String]
	var buildingsData = [] as [[String]]
	var floorsData = [] as [[[String]]]
	var rooms = ["ALL", "1", "2", "3"]
	var projectIndex = 0
	var buildingIndex = 0
	var floorIndex = 0
	var roomIndex = 0
	var mode = 0
    var dlPicArr:[PicData] = []
    var dlIndex = 0
    var hud:JGProgressHUD?
    var dlPicTimer = Timer()
	
	// MARK: Life Circle
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		initLayaout()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: Custom Functions
	func initLayaout() {
		//init data from meta sqlite
		initData()
		
		//check if data is download
		let userDefaults = UserDefaults.standard
		
		if userDefaults.dictionary(forKey: "downloadSqlite") != nil {
			downloadSqlite = userDefaults.dictionary(forKey: "downloadSqlite") as! [String : [String]]
			for projectNO in projectsNoData {
				if !downloadSqlite.keys.contains(projectNO) {
					downloadSqlite[projectNO] = []
				}
			}
		} else {
			for projectNO in projectsNoData {
				downloadSqlite[projectNO] = []
			}
		}
		print(downloadSqlite)
		//init back button
		let btnBack = NaviTool.initBtnBack()
		btnBack.addTarget(self, action: #selector(btnBackPressed(sender:)), for: .touchUpInside)
		self.view.addSubview(btnBack)
		
		//init project view
		vwProject.clipsToBounds = true
		vwProject.layer.cornerRadius = 5.0
		vwProject.layer.borderColor = UIColor.gray.cgColor
		vwProject.layer.borderWidth = 1.0
		
		if projectsData.count != 0 {
			projectIndex = 0
			tfProject.text = projectsData[projectIndex]
		} else {
			projectIndex = -1
		}
		tfProject.tintColor = .clear
		initTextField(textField: tfProject, tag: 0)
		
		//init project view
		vwBuilding.clipsToBounds = true
		vwBuilding.layer.cornerRadius = 5.0
		vwBuilding.layer.borderColor = UIColor.gray.cgColor
		vwBuilding.layer.borderWidth = 1.0
		
		tfBuilding.tintColor = .clear
		initTextField(textField: tfBuilding, tag: 1)
		
		//init floor view
		vwFloor.clipsToBounds = true
		vwFloor.layer.cornerRadius = 5.0
		vwFloor.layer.borderColor = UIColor.gray.cgColor
		vwFloor.layer.borderWidth = 1.0
		
		tfFloor.tintColor = .clear
		initTextField(textField: tfFloor, tag: 2)
		
		resetBuildingAndFloor()
		
		/*
		//init project view
		vwRoom.clipsToBounds = true
		vwRoom.layer.cornerRadius = 5.0
		vwRoom.layer.borderColor = UIColor.gray.cgColor
		vwRoom.layer.borderWidth = 1.0
		
		if rooms.count != 0 {
			roomIndex = 0
			tfRoom.text = rooms[roomIndex]
		} else {
			roomIndex = -1
		}
		tfRoom.tintColor = .clear
		initTextField(textField: tfRoom, tag: 3)
		*/
		//init btn view
		btnSync.clipsToBounds = true
		btnSync.layer.cornerRadius = 5.0
		
	}
	
	func resetBuildingAndFloor() {
		var buildings = buildingsData[projectIndex]
		if buildings.count != 0 {
			buildingIndex = 0
			tfBuilding.text = buildings[buildingIndex]
		} else {
			buildingIndex = -1
			tfBuilding.text = ""
		}
		
		var floorsBuildings = floorsData[projectIndex]
		var floors = floorsBuildings[buildingIndex]
		if floors.count != 0 {
			floorIndex = 0
			tfFloor.text = floors[floorIndex]
		} else {
			floorIndex = -1
			tfFloor.text = ""
		}
	}
	
	func initData() {
		do {
			let fileManager = FileManager.default
			let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
			let fileURL = documentDirectory.appendingPathComponent(SystemConstants.DBFileName)
			
			let db = try Connection(fileURL.absoluteString)
			
			let projects = Table("HomeProject")
			let project_name = Expression<String?>("PROJM_NAME")
			let project_no = Expression<String?>("PROJM_NO")
			let project_sorting = Expression<String?>("Sorting")
			var query = projects.select(project_name, project_no)
				.order(project_sorting.asc)
			
			for project in try db.prepare(query) {
				print("name: \(project[project_name]!), pwd: \(project[project_no]!)")
				projectsData.append(project[project_name]!)
				projectsNoData.append(project[project_no]!)
			}
			
			let homeSalems = Table("HomeSalem")
			let ELEVEL_2_1 = Expression<String?>("ELEVEL_2_1")
			
			for projectNo in projectsNoData {
				query = homeSalems.select(ELEVEL_2_1)
					.filter(project_no == projectNo)
					.group(ELEVEL_2_1)
				var buildings = [] as [String]
				var floorsBuildings = [] as [[String]]
				for homeSalem in try db.prepare(query) {
					print("name: \(homeSalem[ELEVEL_2_1]!)")
					buildings.append(homeSalem[ELEVEL_2_1]!)
					
					let item_e1 = Expression<String?>("ELEVEL_1")
					query = homeSalems.select(item_e1)
						.filter(project_no == projectNo && ELEVEL_2_1 == homeSalem[ELEVEL_2_1])
						.group(item_e1)
					
					var floors = [] as [String]
					floors.append("all")
					for homeSalem in try db.prepare(query) {
						print("name: \(homeSalem[item_e1]!)")
						floors.append(homeSalem[item_e1]!)
					}
					floorsBuildings.append(floors)
				}
				buildingsData.append(buildings)
				floorsData.append(floorsBuildings)
			}
		} catch {
			//handle error
			print(error)
		}
	}
	
	func initTextField(textField: UITextField, tag: Int) {
        textField.tintColor = UIColor.clear
		//set dropdown image
		textField.rightViewMode = .always
		let dropdownImgView = UIImageView(frame: CGRect(x:0, y:0, width:60.0, height:40.0))
		dropdownImgView.contentMode = .scaleAspectFit
		dropdownImgView.image = UIImage(named: "Icon_Drop")
		textField.rightView = dropdownImgView
		
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
	
	// MARK: Button Actions
	@IBAction func clickConfirm(_ sender: Any) {
		
	}
	
	@objc func btnBackPressed(sender: UIBarButtonItem) {
		self.navigationController?.popViewController(animated: true)
	}
	
	// MARK: UIPickerViewDelegate
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if pickerView.tag == 0 {
			return projectsData.count
		} else if pickerView.tag == 1 {
			let buildings = buildingsData[projectIndex]
			return buildings.count
		} else if pickerView.tag == 2 {
			let floorsBuildings = floorsData[projectIndex]
			let floors = floorsBuildings[buildingIndex]
			return floors.count
		} else if pickerView.tag == 3 {
			return rooms.count
		} else {
			return 0
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if pickerView.tag == 0 {
			return projectsData[row]
		} else if pickerView.tag == 1 {
			let buildings = buildingsData[projectIndex]
			return buildings[row]
		} else if pickerView.tag == 2 {
			let floorsBuildings = floorsData[projectIndex]
			let floors = floorsBuildings[buildingIndex]
			return floors[row]
		} else if pickerView.tag == 3 {
			return rooms[row]
		} else {
			return ""
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if pickerView.tag == 0 {
			projectIndex = row
			tfProject.text = projectsData[projectIndex]
			resetBuildingAndFloor()
		} else if pickerView.tag == 1 {
			buildingIndex = row
			let buildings = buildingsData[projectIndex]
			tfBuilding.text = buildings[buildingIndex]
		} else if pickerView.tag == 2 {
			floorIndex = row
			let floorsBuildings = floorsData[projectIndex]
			let floors = floorsBuildings[buildingIndex]
			tfFloor.text = floors[floorIndex]
		} else if pickerView.tag == 3 {
			roomIndex = row
			tfRoom.text = rooms[roomIndex]
		} else {
			
		}
	}
	
	@IBAction func clickSync(_ sender: Any) {
       let alert = UIAlertController(title: "提醒", message: "清除所有資料", preferredStyle: UIAlertControllerStyle.alert)
       alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.destructive, handler: { action in
           
       }))
        alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
            let buildings = self.buildingsData[self.projectIndex]
             let fileName = String.init(format: SystemConstants.DBFileNameSub, self.projectsNoData[self.projectIndex], buildings[self.buildingIndex])
             //loadPic(dbName: fileName)
             
             self.loadDB()
        }))
        self.present(alert, animated: true, completion: nil)
        
	}
    
    func loadPic() {
        let buildings = buildingsData[projectIndex]
        let fileName = String.init(format: SystemConstants.DBFileNameSub, projectsNoData[projectIndex], buildings[buildingIndex])
        loadPic(dbName: fileName)
    }
    
    func loadPic(dbName:String) {
        dlPicArr = []
        dlIndex = 0
        do {
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let subFileURL = documentDirectory.appendingPathComponent(dbName)
            let db = try Connection(subFileURL.absoluteString)
            let ProjectAreaMst = Table("ProjectAreaMst")
            let FileUrl = Expression<String?>("FileUrl")
            let FileName = Expression<String?>("FileName")
            let AreaFileUrl = Expression<String?>("AreaFileUrl")
            let AreaFileName = Expression<String?>("AreaFileName")
            let PlaneFileUrl = Expression<String?>("PlaneFileUrl")
            let PlaneFileName = Expression<String?>("PlaneFileName")
        
            var query = ProjectAreaMst.select(AreaFileUrl, AreaFileName, PlaneFileUrl, PlaneFileName)
            for data in try db.prepare(query) {
                if data[AreaFileUrl] != nil && data[AreaFileName] != nil && data[AreaFileUrl] != "" && data[AreaFileName] != "" {
                    print("*name: \(data[AreaFileUrl]!) \(data[AreaFileName]!)")
                    
                    let fileURL = documentDirectory.appendingPathComponent(data[AreaFileName]!)
                    if fileManager.fileExists(atPath: fileURL.path) {
                        print("FILE Exist")
                    } else {
                        let picData = PicData()
                        picData.fileName = data[AreaFileName]!
                        picData.fileUrl = URLConstants.ImagePrefixURL + data[AreaFileUrl]!
                        dlPicArr.append(picData)
                    }
                }
                if data[PlaneFileUrl] != nil && data[PlaneFileName] != nil && data[PlaneFileUrl] != "" && data[PlaneFileName] != "" {
                    print("*name: \(data[PlaneFileUrl]!) \(data[PlaneFileName]!)")
                    let fileManager = FileManager.default
                    let fileURL = documentDirectory.appendingPathComponent(data[PlaneFileName]!)
                    if fileManager.fileExists(atPath: fileURL.path) {
                        print("FILE Exist")
                    } else {
                        let picData = PicData()
                        picData.fileName = data[PlaneFileName]!
                        picData.fileUrl = URLConstants.ImagePrefixURL + data[PlaneFileUrl]!
                        dlPicArr.append(picData)
                    }
                }
            }
            for tableName in DBHelper.DLPicTables {
                let dl_table = Table(tableName)
                query = dl_table.select(FileUrl, FileName)
                for data in try db.prepare(query) {
                    if data[FileUrl] != nil && data[FileName] != nil && data[FileUrl] != "" && data[FileName] != "" {
                        print("*name: \(data[FileUrl]!) \(data[FileName]!)")
                        
                        let fileURL = documentDirectory.appendingPathComponent(data[FileName]!)
                        if fileManager.fileExists(atPath: fileURL.path) {
                            print("FILE Exist")
                        } else {
                            let picData = PicData()
                            picData.fileName = data[FileName]!
                            picData.fileUrl = URLConstants.ImagePrefixURL + data[FileUrl]!
                            dlPicArr.append(picData)
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
        
        if dlPicArr.count > 0 {
            hud = JGProgressHUD(style: .dark)
            hud?.vibrancyEnabled = true
            hud?.indicatorView = JGProgressHUDPieIndicatorView()
            hud?.detailTextLabel.text = String.init(format: "%d/%d", 0, dlPicArr.count)
            hud?.textLabel.text = "圖片下載中..."
            hud?.show(in: self.view)
            downloadPic()
        } else {
            let alertController = UIAlertController(
                title: "提醒",
                message: "下載完成",
                preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "確定", style: .default) { (alertController) in
                self.navigationController?.popViewController(animated: true)
                
            }
            alertController.addAction(okAction)
            self.present(
                alertController,
                animated: true,
                completion: nil)
        }
    }
    
    func downloadPic() {
        let progressClosure : (CGFloat, VeloxDownloadInstance) -> (Void)
        let remainingTimeClosure : (CGFloat) -> Void
        let completionClosure : (Bool) -> Void
        
        progressClosure = {(progress,downloadInstace) in
            print("Progress of File : \(downloadInstace.filename) is \(Float(progress))")
            
        }
        
        remainingTimeClosure = {(timeRemaning) in
            print("Remaining Time is : \(timeRemaning)")
        }
        
        completionClosure = {(status) in
            print("is Download completed : \(status)")
            self.dlPicTimer.invalidate()
            self.dlIndex += 1
            DispatchQueue.main.async {
                self.hud?.progress = (Float)(self.dlIndex) / (Float)(self.dlPicArr.count)
                self.hud?.detailTextLabel.text = String.init(format: "%d/%d", self.dlIndex, self.dlPicArr.count)
                if self.dlIndex < self.dlPicArr.count {
                    self.downloadPic()
                } else {
                    DispatchQueue.main.async {
                        self.hud?.dismiss(animated: false)
                        let alertController = UIAlertController(
                            title: "提醒",
                            message: "下載完成",
                            preferredStyle: .alert)
                        
                        let okAction = UIAlertAction(title: "確定", style: .default) { (alertController) in
                            self.navigationController?.popViewController(animated: true)
                            
                        }
                        alertController.addAction(okAction)
                        self.present(
                            alertController,
                            animated: true,
                            completion: nil)
                    }
                }
            }
            
        }
        
        do {
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileName = dlPicArr[dlIndex].fileName
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            let veloxDownloader = VeloxDownloadManager.sharedInstance
            var url = URL(string: dlPicArr[dlIndex].fileUrl.urlEncoded())
            if dlIndex > 5 {
                url = URL(string: dlPicArr[dlIndex].fileUrl.urlEncoded())
            }
            dlPicTimer = Timer.scheduledTimer(timeInterval: TimeInterval(20), target: self, selector: #selector(SyncProjectController.timerStop), userInfo: nil, repeats: false)
            
            veloxDownloader.downloadFile(
                withURL: url!,
                name: fileName,
                directoryName: fileURL.absoluteString,
                friendlyName: nil,
                progressClosure: progressClosure,
                remainigtTimeClosure: remainingTimeClosure,
                completionClosure: completionClosure,
                backgroundingMode: false)
        } catch {
            print(error)
        }
    }
	
    
    @objc func timerStop() {
       
        
        do {
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileName = dlPicArr[dlIndex].fileName
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            try fileManager.removeItem(at: fileURL)
            print("Existing file deleted.")
        } catch {
            print("Failed to delete existing file:\n\((error as NSError).description)")
        }
        self.hud?.dismiss(animated: false)
        let alert = UIAlertController(title: "提醒", message: "無法下載圖片\n" + self.dlPicArr[self.dlIndex].fileUrl, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
        
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
	func loadDB() {
		let hud = JGProgressHUD(style: .dark)
		hud.vibrancyEnabled = true
		//hud.indicatorView = JGProgressHUDPieIndicatorView()
		//hud.detailTextLabel.text = "0%"
		hud.textLabel.text = "下載中..."
		hud.show(in: self.view)
		
		let veloxDownloader = VeloxDownloadManager.sharedInstance
		let buildings = buildingsData[projectIndex]
		
		let floorsBuildings = floorsData[projectIndex]
		let floors = floorsBuildings[buildingIndex]
		let urlString = String.init(format: "%@?PROJM_NO=%@&ELEVEL_2=%@&ELEVEL_1=%@", URLConstants.DownloadDBSub, projectsNoData[projectIndex], buildings[buildingIndex], floors[floorIndex])
		
		let url = URL(string: urlString)
		
		let progressClosure : (CGFloat, VeloxDownloadInstance) -> (Void)
		let remainingTimeClosure : (CGFloat) -> Void
		let completionClosure : (Bool) -> Void
		
		progressClosure = {(progress,downloadInstace) in
			print("Progress of File : \(downloadInstace.filename) is \(Float(progress))")
			
			DispatchQueue.main.async {
				//self.incrementHUD(hud, progress: Float(progress))
			}
			
		}
		
		remainingTimeClosure = {(timeRemaning) in
			print("Remaining Time is : \(timeRemaning)")
		}
		
		completionClosure = {(status) in
			print("is Download completed : \(status)")
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
				
				var buildingSqlite = self.downloadSqlite[self.projectsNoData[self.projectIndex]]
				
				if !(buildingSqlite?.contains(self.tfBuilding.text!))! {
					buildingSqlite?.append(self.tfBuilding.text!)
				}
				
				self.downloadSqlite[self.projectsNoData[self.projectIndex]] = buildingSqlite
				//check if data is download
				let userDefaults = UserDefaults.standard
				userDefaults.setValue(self.downloadSqlite, forKey: "downloadSqlite")
				
				DispatchQueue.main.asyncAfter(deadline: .now()) {
					if(hud.isVisible) {
						hud.dismiss(animated: false)
                        self.generateUploadDB()
						self.loadPic()
						
					}
				}
			}
		}
		let fileManager = FileManager.default
		do {
			let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
			let buildings = buildingsData[projectIndex]
			let fileName = String.init(format: SystemConstants.DBFileNameSub, projectsNoData[projectIndex], buildings[buildingIndex])
			let fileURL = documentDirectory.appendingPathComponent(fileName)
            
            do {
                try fileManager.removeItem(at: fileURL)
                print("Existing file deleted.")
            } catch {
                print("Failed to delete existing file:\n\((error as NSError).description)")
            }
            
			veloxDownloader.downloadFile(
				withURL: url!,
				name: fileName,
				directoryName: fileURL.absoluteString,
				friendlyName: nil,
				progressClosure: progressClosure,
				remainigtTimeClosure: remainingTimeClosure,
				completionClosure: completionClosure,
				backgroundingMode: false)
		} catch {
			print(error)
		}
		
	}
	
	func generateUploadDB() {
		do {
			let fileManager = FileManager.default
			let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
			let buildings = buildingsData[projectIndex]
			let fileName = String.init(format: SystemConstants.DBFileNameSub, projectsNoData[projectIndex], buildings[buildingIndex])
			let fileURL = documentDirectory.appendingPathComponent(fileName)
			
			let fileNameUpload = String.init(format: SystemConstants.DBFileNameSubUpload, projectsNoData[projectIndex], buildings[buildingIndex])
			let fileURLUpload = documentDirectory.appendingPathComponent(fileNameUpload)
            do {
                try fileManager.removeItem(at: fileURLUpload)
                print("Existing file deleted.")
            } catch {
                print("Failed to delete existing file:\n\((error as NSError).description)")
            }
			try fileManager.copyItem(at: fileURL, to: fileURLUpload)
			
			let db = try Connection(fileURLUpload.absoluteString)
			for tableName in DBHelper.DeleteTables {
				let drop_table = Table(tableName)
				try db.run(drop_table.drop(ifExists: true))
			}
			for tableName in DBHelper.ClearTables {
				let clear_table = Table(tableName)
				try db.run(clear_table.delete())
			}
		} catch {
			print(error)
		}
	}
	/*
	func incrementHUD(_ hud: JGProgressHUD, progress: Float) {
		hud.progress = progress
		hud.detailTextLabel.text = "\(Int(progress * 100))%"
		
		if progress == 1.0 {
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
				UIView.animate(withDuration: 0.1, animations: {
					hud.textLabel.text = "下載完成"
					hud.detailTextLabel.text = nil
					hud.indicatorView = JGProgressHUDSuccessIndicatorView()
					let tmpIP = UserDefaults.standard.string(forKey: "TMPIP")
					UserDefaults.standard.set(tmpIP, forKey: "IP")
					UserDefaults.standard.removeObject(forKey: "TMPIP")
					UserDefaults.standard.synchronize()
				})
				
				hud.dismiss(afterDelay: 1.5)
				//self.navigationController?.popViewController(animated: true)
			}
		}
	}
*/
}

class PicData {
    var fileName:String = ""
    var fileUrl:String = ""
}



