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

class MISController: UIViewController{
	// MARK: Variables
    @IBOutlet weak var btnUpload: UIButton!
	@IBOutlet weak var btnDL: UIButton!
	@IBOutlet weak var btnUpdate: UIButton!
	@IBOutlet weak var btnClear: UIButton!
	var updateIndex = 0
	var hud = JGProgressHUD(style: .dark)
	var updateUrls = [] as [String]
	var updateFileNames = [] as [String]
	var updateFileNamesUpload = [] as [String]
	var removeFileNames = [] as [String]
	var removeFileNamesUpload = [] as [String]
    var dlPicArr:[PicData] = []
    var dlIndex = 0
    var dlPicTimer = Timer()
	
	
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
		//init back button
		let btnBack = NaviTool.initBtnBack()
		btnBack.addTarget(self, action: #selector(btnBackPressed(sender:)), for: .touchUpInside)
		self.view.addSubview(btnBack)
		
		//init btnDL
		btnDL.clipsToBounds = true
		btnDL.layer.cornerRadius = 5.0
		
	
	}
	
	
	// MARK: Button Actions
	@IBAction func clickLoadBasic(_ sender: Any) {
        loadDBBasic()
		
    }
	@IBAction func clickDownload(_ sender: Any) {
        if (UserDefaults.standard.object(forKey: "NeedUpdate") != nil) {
            let alert = UIAlertController(title: "提醒", message: "請上傳驗屋資料或至清除資料清除", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
//                 self.navigationController?.pushViewController(SyncProjectController(), animated: true)
            }))
//            alert.addAction(UIAlertAction(title: "上傳資料", style: UIAlertActionStyle.destructive, handler: { action in
//                var NeedUpdateArr:[String] = []
//                if UserDefaults.standard.object(forKey: "NeedUpdateArr") != nil {
//                    NeedUpdateArr = UserDefaults.standard.object(forKey: "NeedUpdateArr") as! [String]
//                }
//                if NeedUpdateArr.count > 0 {
//                    InsTmpDataManager.sharedInstance().uploadSqlDB(NeedUpdateArr[0], view: self.view)
//                }
//            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            
           self.navigationController?.pushViewController(SyncProjectController(), animated: true)
        }
		
	}
	@IBAction func clickUpdate(_ sender: Any) {
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
            present(alert, animated: true, completion: nil)
        }
	}
    
	@IBAction func clickClear(_ sender: Any) {
		let alert = UIAlertController(title: "提醒", message: "確定要清除全部資料嗎？", preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.destructive, handler:nil))
		alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
			self.goRemove()
		}))
		self.present(alert, animated: true, completion: nil)
		
	}
	@objc func btnBackPressed(sender: UIBarButtonItem) {
		self.navigationController?.popToRootViewController(animated: true)
	}
    
    func loadDBBasic() {
        hud.vibrancyEnabled = true
        hud.textLabel.text = "下載中..."
        hud.show(in: self.view)
        
        let veloxDownloader = VeloxDownloadManager.sharedInstance
        let urlString = URLConstants.DownloadDB
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
            self.dlPicTimer.invalidate()
            print("is Download completed : \(status)")
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    if(self.hud.isVisible) {
                        self.hud.dismiss(animated: false)
                        let alert = UIAlertController(title: "", message: "下載完成", preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            
        }
        
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(SystemConstants.DBFileName)
            dlPicTimer = Timer.scheduledTimer(timeInterval: TimeInterval(20), target: self, selector: #selector(timerStopBasic), userInfo: nil, repeats: false)
            veloxDownloader.downloadFile(
                withURL: url!,
                name: SystemConstants.DBFileName,
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
	
	func goUpdate() {
		
		let userDefaults = UserDefaults.standard
		if userDefaults.dictionary(forKey: "downloadSqlite") != nil {
			var downloadSqlite = [:] as [String:[String]]
			downloadSqlite = userDefaults.dictionary(forKey: "downloadSqlite") as! [String : [String]]
			updateUrls = []
			updateFileNames = []
			updateFileNamesUpload = []
            dlPicArr = []
            dlIndex = 0
			updateIndex = 0
			for key in downloadSqlite.keys {
				let buildings = downloadSqlite[key]
				for building in buildings! {
					let urlString = String.init(format: "%@?PROJM_NO=%@&ELEVEL_2=%@&ELEVEL_1=%@", URLConstants.DownloadDBSub, key, building, "all")
					let fileName = String.init(format: SystemConstants.DBFileNameSub, key, building)
					let fileNameUpload = String.init(format: SystemConstants.DBFileNameSubUpload, key, building)
					updateUrls.append(urlString)
					updateFileNames.append(fileName)
                    loadPic(fileName)
					updateFileNamesUpload.append(fileNameUpload)
				}
				
			}
			print(updateUrls)
			if updateUrls.count > 0 {
				loadDB()
			}
		}
	}
    
    func loadPic(_ dbName:String) {
        
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
            self.dlIndex += 1
            DispatchQueue.main.async {
                self.hud.progress = (Float)(self.dlIndex) / (Float)(self.dlPicArr.count)
                self.hud.detailTextLabel.text = String.init(format: "%d/%d", self.dlIndex, self.dlPicArr.count)
                if self.dlIndex < self.dlPicArr.count {
                    self.downloadPic()
                } else {
                    DispatchQueue.main.async {
                        self.hud.dismiss(animated: false)
                        let alertController = UIAlertController(
                            title: "提醒",
                            message: "下載完成",
                            preferredStyle: .alert)
                        
                        let okAction = UIAlertAction(title: "確定", style: .default) { (alertController) in
                            
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
            let url = URL(string: dlPicArr[dlIndex].fileUrl)
           
            dlPicTimer = Timer.scheduledTimer(timeInterval: TimeInterval(5), target: self, selector: #selector(MISController.timerStop), userInfo: nil, repeats: false)
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
        self.hud.dismiss(animated: false)
        let alert = UIAlertController(title: "提醒", message: "無法下載圖片\n" + self.dlPicArr[self.dlIndex].fileUrl, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func timerStopBasic() {
       
        self.hud.dismiss(animated: false)
        let alert = UIAlertController(title: "提醒", message: "無法下載資料\n" + self.dlPicArr[self.dlIndex].fileUrl, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
	
	func loadDB() {
        
		hud.vibrancyEnabled = true
		hud.detailTextLabel.text = String.init(format: "%d / %d", self.updateIndex, self.updateUrls.count)
		hud.textLabel.text = "更新中"
		hud.show(in: self.view)
		
		let veloxDownloader = VeloxDownloadManager.sharedInstance
		let urlString = updateUrls[updateIndex]
		
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
			
			DispatchQueue.main.asyncAfter(deadline: .now()) {
				self.clearUploadDB()
				self.updateIndex += 1;
				if self.updateIndex >= self.updateUrls.count {
                    if self.dlPicArr.count > 0 {
                        self.hud.vibrancyEnabled = true
                        self.hud.indicatorView = JGProgressHUDPieIndicatorView()
                        self.hud.detailTextLabel.text = String.init(format: "%d/%d", 0, self.dlPicArr.count)
                        self.hud.textLabel.text = "圖片下載中..."
                        self.hud.show(in: self.view)
                        self.downloadPic()
                    } else {
                        DispatchQueue.main.async {
                            if(self.hud.isVisible) {
                                self.hud.dismiss(animated: false)
                            }
                            let alertController = UIAlertController(
                                title: "提醒",
                                message: "下載完成",
                                preferredStyle: .alert)
                            
                            let okAction = UIAlertAction(title: "確定", style: .default) { (alertController) in
                                
                            }
                            alertController.addAction(okAction)
                            self.present(
                                alertController,
                                animated: true,
                                completion: nil)
                        }
                    }
					
				} else {
					self.loadDB()
				}
			}
		}
		
		let fileManager = FileManager.default
		do {
			let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
			let fileName = updateFileNames[updateIndex]
			let fileURL = documentDirectory.appendingPathComponent(fileName)
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
	
	func clearUploadDB() {
		do {
			let fileManager = FileManager.default
			let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
			let fileName = updateFileNamesUpload[updateIndex]
			let fileURLUpload = documentDirectory.appendingPathComponent(fileName)
			let db = try Connection(fileURLUpload.absoluteString)
			for tableName in DBHelper.ClearTables {
				let clear_table = Table(tableName)
				try db.run(clear_table.delete())
			}
		} catch {
			print(error)
		}
	}
	
	func goRemove() {
        
		hud.textLabel.text = "刪除中..."
		hud.show(in: self.view)
		let userDefaults = UserDefaults.standard
        UserDefaults.standard.removeObject(forKey: "NeedUpdate")
		if userDefaults.dictionary(forKey: "downloadSqlite") != nil {
			var downloadSqlite = [:] as [String:[String]]
			downloadSqlite = userDefaults.dictionary(forKey: "downloadSqlite") as! [String : [String]]
			for key in downloadSqlite.keys {
				let buildings = downloadSqlite[key]
				for building in buildings! {
					do {
						let fileManager = FileManager.default
						let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
						let fileName = String.init(format: SystemConstants.DBFileNameSub, key, building)
						let fileNameUpload = String.init(format: SystemConstants.DBFileNameSubUpload, key, building)
						let fileURL = documentDirectory.appendingPathComponent(fileName)
						let fileURLUpload = documentDirectory.appendingPathComponent(fileNameUpload)
						try fileManager.removeItem(at:fileURL)
						try fileManager.removeItem(at:fileURLUpload)
					}
					catch let error as NSError {
						print("Ooops! Something went wrong: \(error)")
					}
				}
			}
		}
		userDefaults.removeObject(forKey: "downloadSqlite")
		hud.textLabel.text = "刪除完成"
		hud.dismiss(afterDelay: 1.0)
	}
	
	func showPieHUD(message: String) {
		let hud = JGProgressHUD(style: .dark)
		hud.vibrancyEnabled = true
		hud.indicatorView = JGProgressHUDPieIndicatorView()
		hud.detailTextLabel.text = "0%"
		hud.textLabel.text = message
		hud.show(in: self.view)
		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
			self.incrementHUD(hud, progress: 0)
		}
	}
	
	func incrementHUD(_ hud: JGProgressHUD, progress previousProgress: Int) {
		let progress = previousProgress + 1
		hud.progress = Float(progress)/100.0
		hud.detailTextLabel.text = "\(progress)%"
		
		if progress == 100 {
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
				UIView.animate(withDuration: 0.1, animations: {
					hud.textLabel.text = "完成"
					hud.detailTextLabel.text = nil
					hud.indicatorView = JGProgressHUDSuccessIndicatorView()
				})
				
				hud.dismiss(afterDelay: 1.0)
			}
		}
		else {
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20)) {
				self.incrementHUD(hud, progress: progress)
			}
		}
    }
}
