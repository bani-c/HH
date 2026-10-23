//
//  ViewController.swift
//  Home-Maintenance
//
//  Created by Bani on 14/09/2017.
//  Copyright © 2017 Ultron mobile. All rights reserved.
//

import UIKit
import JGProgressHUD
import EPSignature
import NYTPhotoViewer
import PDFGenerator
import SQLite

class InsDetectListConfirmFinalController: UIViewController, UITableViewDelegate, UITableViewDataSource, EPSignatureDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	@IBOutlet weak var lblTitle: UILabel!
	@IBOutlet weak var tableView: UITableView!
	public var opName: String!
	public var caseName: String!
	public var projectName: String!
	let data0 = NSMutableArray.init()
	let data1 = NSMutableArray.init()
	var projectIndex:Int = 0
	var characterIndex:Int = 0
	var buildingIndex:Int = 0
	var catOpName:[String] = []
	var catOpId:[String] = []
	var catArea:[String] = []
	var catFilter = ["缺失項目", "通過項目", "全部項目"]
	var targetAreaData:[InsAreaItem] = []
	var targetItemData = NSMutableArray.init()
	var tmpAreaItem:InsAreaItem = InsAreaItem.init()
	var opIndex = 0
	var areaIndex:Int = 0
	var catFilterIndex:Int = 0
	var signIndex:Int = 0
    var placeData:[InsPlaceItem] = []
    var placeAllData:[InsPlaceItem] = []
    var isPrint = false
    private var twoSignatureColumns = false
    private var signatureLayout: SignatureColumnsLayout?
    private var selectedFormat: InspectionPDFFormat = .list
    private let formatControl = UISegmentedControl(items: ["純文字", "含照片"])
    private let formatHint = UILabel()
    private var photoLayoutWidth: CGFloat = 0
    private var photoRecords: [PDFData] = []
    private var photoItemPaths: [IndexPath] = []
    private lazy var photoCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = UIColor(white: 0.96, alpha: 1)
        collection.dataSource = self
        collection.delegate = self
        collection.register(InspectionPhotoRecordCell.self, forCellWithReuseIdentifier: "PhotoRecord")
        return collection
    }()
	
    var targetCell: InsDetectSignCell?
    @IBOutlet weak var lcTable: NSLayoutConstraint!
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var ivSign0: UIImageView!
	@IBOutlet weak var ivSign1: UIImageView!
	@IBOutlet weak var ivSign2: UIImageView!
	// MARK: Life Circle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resetTableViewHeight()
        if abs(photoCollection.bounds.width - photoLayoutWidth) > 0.5 {
            photoLayoutWidth = photoCollection.bounds.width
            photoCollection.collectionViewLayout.invalidateLayout()
        }
    }
    
    func resetTableViewHeight() {
		let availableHeight = scrollview.bounds.height
		guard availableHeight > 0, abs(lcTable.constant - availableHeight) > 0.5 else {
			return
		}
		lcTable.constant = availableHeight
    }
	override func viewDidLoad() {
		super.viewDidLoad()
		initLayaout()
        signatureLayout = SignatureColumnsLayout(images: [ivSign0, ivSign1, ivSign2])
        setupFormatToolbar()
	}
	
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        refreshPhotoRecords()
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

    // Keep the selected screen layout and every print entry point on the same format.
    private func setupFormatToolbar() {
        guard let top = view.constraints.first(where: {
            ($0.firstItem as? UIView) === scrollview && $0.firstAttribute == .top
        }), let header = top.secondItem as? UIView else { return }
        top.isActive = false
        let toolbar = UIView()
        toolbar.backgroundColor = UIColor(white: 0.97, alpha: 1)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        formatControl.selectedSegmentIndex = 0
        formatControl.addTarget(self, action: #selector(formatChanged), for: .valueChanged)
        formatControl.translatesAutoresizingMaskIntoConstraints = false
        toolbar.addSubview(formatControl)
        let printButton = UIButton(type: .system)
        printButton.setTitle("列印 PDF", for: .normal)
        printButton.setImage(UIImage(systemName: "printer"), for: .normal)
        printButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        printButton.tintColor = UIColor(red: 0.52, green: 0.12, blue: 0.14, alpha: 1)
        printButton.addTarget(self, action: #selector(clickPrint(_:)), for: .touchUpInside)
        printButton.translatesAutoresizingMaskIntoConstraints = false
        toolbar.addSubview(printButton)
        formatHint.font = UIFont.systemFont(ofSize: 12)
        formatHint.textColor = .darkGray
        formatHint.translatesAutoresizingMaskIntoConstraints = false
        toolbar.addSubview(formatHint)
        photoCollection.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(photoCollection)
        let preferredControlWidth = formatControl.widthAnchor.constraint(equalToConstant: 340)
        preferredControlWidth.priority = .defaultHigh
        preferredControlWidth.isActive = true
        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: header.bottomAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 84),
            scrollview.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            formatControl.topAnchor.constraint(equalTo: toolbar.topAnchor, constant: 8),
            formatControl.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor, constant: 16),
            formatControl.widthAnchor.constraint(lessThanOrEqualToConstant: 340),
            formatControl.trailingAnchor.constraint(lessThanOrEqualTo: printButton.leadingAnchor, constant: -16),
            formatControl.heightAnchor.constraint(equalToConstant: 36),
            printButton.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor, constant: -16),
            printButton.widthAnchor.constraint(equalToConstant: 100),
            printButton.centerYAnchor.constraint(equalTo: formatControl.centerYAnchor),
            printButton.heightAnchor.constraint(equalToConstant: 44),
            formatHint.leadingAnchor.constraint(equalTo: formatControl.leadingAnchor),
            formatHint.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor, constant: -16),
            formatHint.topAnchor.constraint(equalTo: formatControl.bottomAnchor, constant: 6),
            photoCollection.topAnchor.constraint(equalTo: scrollview.topAnchor),
            photoCollection.bottomAnchor.constraint(equalTo: scrollview.bottomAnchor),
            photoCollection.leadingAnchor.constraint(equalTo: scrollview.leadingAnchor),
            photoCollection.trailingAnchor.constraint(equalTo: scrollview.trailingAnchor)
        ])
        applySelectedFormat()
    }

    @objc private func formatChanged() {
        selectedFormat = formatControl.selectedSegmentIndex == 0 ? .list : .photoGrid
        refreshPhotoRecords()
        applySelectedFormat()
    }

    private func applySelectedFormat() {
        let photos = selectedFormat == .photoGrid
        scrollview.isHidden = photos
        photoCollection.isHidden = !photos
        formatHint.text = photos ? "四格照片 · 每格 1 張，多張照片分格顯示" : "純文字清單 · 列印不含照片"
        signatureLayout?.apply(twoColumns: photos || twoSignatureColumns)
        view.layoutIfNeeded()
    }

    private func refreshPhotoRecords() {
        let sortedPlaces = InspectionPrintOrder.sorted(placeData)
        let generator = PDFGenerator()
        generator.placeData = sortedPlaces
        photoRecords = generator.generatePDFData(itemsPerPage: 4, expandPhotos: true).flatMap { $0 }
        photoItemPaths = sortedPlaces.flatMap { place -> [IndexPath] in
            guard let section = placeData.firstIndex(where: { $0 === place }) else { return [] }
            return place.items.indices.flatMap { row in
                // Every photo card opens the same original defect for editing.
                Array(repeating: IndexPath(row: row, section: section),
                      count: max(1, place.items[row].picUrls.count))
            }
        }
        photoCollection.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoRecords.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoRecord", for: indexPath) as! InspectionPhotoRecordCell
        cell.configure(photoRecords[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = collectionView.bounds.width >= 600 ? 2 : 1
        let width = floor((collectionView.bounds.width - 32 - (columns - 1) * 12) / columns)
        return CGSize(width: width, height: width * 292 / 271.5)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < photoItemPaths.count else { return }
        openInspectionItem(at: photoItemPaths[indexPath.item])
    }

	// MARK: Custom Functions
	func initLayaout() {
		initData()
		UserDefaults.standard.removeObject(forKey: "sign0")
        UserDefaults.standard.removeObject(forKey: "sign1")
        UserDefaults.standard.removeObject(forKey: "sign2")
		//set title
		//lblTitle.text = caseName
		lblTitle.text = "驗屋確認單"
		
		//register nib
		tableView.register(UINib(nibName: "InsDetect0HeaderCell", bundle: nil), forCellReuseIdentifier: "InsDetect0HeaderCell")
        tableView.register(UINib(nibName: "InsHeaderTitleCell", bundle: nil), forCellReuseIdentifier: "InsHeaderTitleCell")
        
		tableView.register(UINib(nibName: "InsDetect0ItemCell", bundle: nil), forCellReuseIdentifier: "InsDetect0ItemCell")
        tableView.register(UINib(nibName: "InsDetectSignCell", bundle: nil), forCellReuseIdentifier: "InsDetectSignCell")
		
        //init back button
        let btnBack = NaviTool.initBtnBack()
        btnBack.addTarget(self, action: #selector(btnBackPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(btnBack)
	}
	
	func initData() {
        
        for flowName in InsTmpDataManager.sharedInstance().flowNameData {
            catOpName.append(flowName)
        }
        catOpName.append("一般檢核項目")
        for flowId in InsTmpDataManager.sharedInstance().flowIdData {
            catOpId.append(flowId)
        }
        catOpId.append("Ins")
		print(catOpId[opIndex] + "_DataArea")
		initAreaItem()
        initDisplayData()
        initDisplayAllData()
        //initSign()
	}
	
    func initSign() {
        do {
            
            
            let projectsNo = UserDefaults.standard.string(forKey: "PROJECT_NO")!
            
            let building = UserDefaults.standard.string(forKey: "BUILDING")!
            let fileNameUpload = String.init(format: SystemConstants.DBFileNameSubUpload, projectsNo, building)
            
            
            let room = UserDefaults.standard.string(forKey: "ROOM")!
            let floor = UserDefaults.standard.string(forKey: "FLOOR")!
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileName = String.init(format: SystemConstants.DBFileNameSub, projectsNo, building)
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            
            
            let db = try Connection(fileURL.absoluteString)
            let InspSignUploadFile = Table("InspSignUploadFile")
            let FileName = Expression<String?>("FileName")
            let FileType = Expression<String?>("FileType")
            
            
            let ELEVEL_2_1 = Expression<String?>("ELEVEL_2_1")
            let ELEVEL_2_2 = Expression<String?>("ELEVEL_2_2")
            let ELEVEL_1 = Expression<String?>("ELEVEL_1")
            let ChkNo = Expression<String?>("ChkNo")
            
            
            
            
            var query = InspSignUploadFile.select(FileName).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && ChkNo == InsTargetData.sharedInstance().inspNo && FileType == "0")
            
            for data in try db.prepare(query) {
                print("name: \(data[FileName]!)")
                let fileManager = FileManager.default
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURL = documentDirectory.appendingPathComponent(data[FileName]!)
                
                let image = try UIImage.init(data: Data.init(contentsOf: fileURL), scale:1.0)
                ivSign0.image = image
            }
            
            query = InspSignUploadFile.select(FileName).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && ChkNo == InsTargetData.sharedInstance().inspNo && FileType == "1")
            for data in try db.prepare(query) {
                print("name: \(data[FileName]!)")
                let fileManager = FileManager.default
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURL = documentDirectory.appendingPathComponent(data[FileName]!)
                
                let image = try UIImage.init(data: Data.init(contentsOf: fileURL), scale:1.0)
                ivSign1.image = image
            }
            
            query = InspSignUploadFile.select(FileName).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && ELEVEL_1 == floor && ChkNo == InsTargetData.sharedInstance().inspNo && FileType == "2")
            for data in try db.prepare(query) {
                print("name: \(data[FileName]!)")
                let fileManager = FileManager.default
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURL = documentDirectory.appendingPathComponent(data[FileName]!)
                
                let image = try UIImage.init(data: Data.init(contentsOf: fileURL), scale:1.0)
                ivSign2.image = image
            }
            
            
            
        } catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        
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
    
    func initDisplayData() {
        placeData = []
        defer {
            if placeData.allSatisfy({ $0.items.isEmpty }) {
                let label = UILabel()
                label.text = "無缺失項目"
                label.font = UIFont.systemFont(ofSize: 22)
                label.textColor = UIColor.darkGray
                label.textAlignment = .center
                label.numberOfLines = 0
                tableView.backgroundView = label
            } else {
                tableView.backgroundView = nil
            }
            tableView.reloadData()
        }
        if catOpName.count == 0 {
            return
        }
        for i in 0...catOpName.count - 1 {
            let tmpAreaData = InsTmpDataManager.sharedInstance().dicArea[catOpId[i] + "_DataArea"]!
            for areaItem in tmpAreaData {
                if areaItem.type == 0 {
                    let placeItem = InsPlaceItem()
                    placeItem.areaName = areaItem.name
                    placeItem.name = catOpName[i] + "-" + areaItem.name
                    for insItem in areaItem.items {
                        if insItem.result == 1 {
                            placeItem.items.append(insItem)
                        }
                    }
                    if placeItem.items.count > 0 {
                        placeData.append(placeItem)
                    }
                } else {
                    
                    for placeItemTmp in areaItem.places {
                        let placeItem = InsPlaceItem()
                        placeItem.areaName = areaItem.name
                        placeItem.placeName = placeItemTmp.name
                        placeItem.name = areaItem.name + "-" + placeItemTmp.name
                        for insItem in placeItemTmp.items {
                            if insItem.result == 1 {
                                placeItem.items.append(insItem)
                            }
                        }
                        if placeItem.items.count > 0 {
                            placeData.append(placeItem)
                        }
                    }
                }
            }
        }
    }
    
    func initDisplayAllData() {
        placeAllData = []
        if catOpName.count == 0 {
            return
        }
        for i in 0...catOpName.count - 1 {
            let tmpAreaData = InsTmpDataManager.sharedInstance().dicArea[catOpId[i] + "_DataArea"]!
            for areaItem in tmpAreaData {
                if areaItem.type == 0 {
                    let placeItem = InsPlaceItem()
                    placeItem.areaName = areaItem.name
                    placeItem.name = catOpName[i] + "-" + areaItem.name
                    for insItem in areaItem.items {
                        placeItem.items.append(insItem)
                    }
                    if placeItem.items.count > 0 {
                        placeAllData.append(placeItem)
                    }
                } else {
                    for placeItemTmp in areaItem.places {
                        let placeItem = InsPlaceItem()
                        placeItem.areaName = areaItem.name
                        placeItem.placeName = placeItemTmp.name
                        placeItem.name = areaItem.name + "-" + placeItemTmp.name
                        for insItem in placeItemTmp.items {
                            placeItem.items.append(insItem)
                        }
                        if placeItem.items.count > 0 {
                            placeAllData.append(placeItem)
                        }
                    }
                }
            }
        }
    }
    
	
	
	
	//MARK: TableView Datasource and Delegate
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isPrint {
            return placeData.count + 1
        } else {
            return placeData.count
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPrint {
            if section == placeData.count && isPrint {
                return placeData[section - 1].items.count + 1
            } else if section == 0 {
                return 0
            } else {
                return placeData[section - 1].items.count
            }
        } else {
            if section == placeData.count - 1 && isPrint {
                return placeData[section].items.count + 1
            } else {
                return placeData[section].items.count
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 58.0
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == placeData.count - 1 && isPrint && indexPath.row == placeData[indexPath.section].items.count {
            return 200.0
        } else {
			return 58.0
        }
    }
 
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 0 {
            return nil
        } else {
            if isPrint {
                if section == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "InsHeaderTitleCell") as! InsHeaderTitleCell
                    cell.lblTitle.text = "驗屋確認單"
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "InsDetect0HeaderCell") as! InsDetect0HeaderCell
                    cell.lblTitle.text = placeData[section - 1].name
                    return cell
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "InsDetect0HeaderCell") as! InsDetect0HeaderCell
                cell.lblTitle.text = placeData[section].name
                return cell
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isPrint {
            if indexPath.section == placeData.count && isPrint && indexPath.row == placeData[indexPath.section - 1].items.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "InsDetectSignCell") as! InsDetectSignCell
                
                targetCell = cell
                targetCell?.isHidden = true
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "InsDetect0ItemCell", for: indexPath) as! InsDetect0ItemCell
                cell.selectionStyle = .none
                let insItem = placeData[indexPath.section - 1].items[indexPath.row]
                if insItem.name == "" {
                    insItem.name = "數量檢核"
                }
                if insItem.amount.count != 0 && insItem.amount != "0"{
                    cell.lblTitle.text = String.init(format: "%d.%@ 數量:%@ ", indexPath.row + 1, insItem.name, insItem.amount)
                } else {
                    cell.lblTitle.text = String(indexPath.row + 1) + "." + insItem.name
                }
                cell.setCheck(InsItem: insItem)
                cell.tfNumber.isEnabled = false
                if insItem.desId != "" || insItem.inspRemark != "" || insItem.picUrl != "" {
                    cell.btnCamera.isHidden = false
                    cell.btnCamera.tag = indexPath.section * 10000 + indexPath.row
                    cell.btnCamera.addTarget(self, action: #selector(clickEdit(button:)), for: UIControlEvents.touchUpInside)
                } else {
                    cell.btnCamera.isHidden = true
                }
                
                return cell
            }
        } else {
            if indexPath.section == placeData.count - 1 && isPrint && indexPath.row == placeData[indexPath.section].items.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "InsDetectSignCell") as! InsDetectSignCell
                
                targetCell = cell
                targetCell?.isHidden = true
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "InsDetect0ItemCell", for: indexPath) as! InsDetect0ItemCell
                cell.selectionStyle = .none
                let insItem = placeData[indexPath.section].items[indexPath.row]
                if insItem.name == "" {
                    insItem.name = "數量檢核"
                }
                if insItem.amount.count != 0 && insItem.amount != "0"{
                    cell.lblTitle.text = String.init(format: "%d.%@ 數量:%@ ", indexPath.row + 1, insItem.name, insItem.amount)
                } else {
                    cell.lblTitle.text = String(indexPath.row + 1) + "." + insItem.name
                }
                cell.setCheck(InsItem: insItem)
                cell.tfNumber.isEnabled = false
                if insItem.desId != "" || insItem.inspRemark != "" || insItem.picUrl != "" {
                    cell.btnCamera.isHidden = false
                    cell.btnCamera.tag = indexPath.section * 10000 + indexPath.row
                    cell.btnCamera.addTarget(self, action: #selector(clickEdit(button:)), for: UIControlEvents.touchUpInside)
                } else {
                    cell.btnCamera.isHidden = true
                }
                
                return cell
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.viewDidLayoutSubviews()
    }
    
    @objc func clickEdit(button: UIButton) {
        
        openInspectionItem(at: IndexPath(row: button.tag % 10000, section: button.tag / 10000))
    }

    private func openInspectionItem(at indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        let addMistakeEditController = AddMistakeEditController()
        addMistakeEditController.type = 2
        addMistakeEditController.areaName = placeData[section].areaName
        if placeData[section].placeName == "" {
            addMistakeEditController.placeName = placeData[section].items[row].name
        } else {
            addMistakeEditController.placeName = placeData[section].placeName
        }
        
        if placeData[section].items[row].desName == "" {
            addMistakeEditController.desName = placeData[section].items[row].name
        } else {
            addMistakeEditController.desName = placeData[section].items[row].desName
        }
        
        addMistakeEditController.targetInsItem = placeData[section].items[row]
        self.navigationController?.pushViewController(addMistakeEditController, animated: true)
        
    }
	
	func clickCamera(button: UIButton) {
		do {
            let section = button.tag / 10000
            let row = button.tag % 10000
            let insItem = placeData[section].items[row]
			
			let fileManager = FileManager.default
			let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
			let fileURL = documentDirectory.appendingPathComponent(insItem.picUrl)
			print(insItem.picUrl)
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
	
    //MARK: Button Action
    @objc func btnBackPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
	
    @IBAction func clickCountDetail(_ sender: Any) {
        let insDetectListCountController = InsDetectListCountController()
        insDetectListCountController.targetPlaceData = placeAllData
        self.navigationController?.pushViewController(insDetectListCountController, animated: true)
    }
    
    @IBAction func btnNextPressed(_ sender: Any) {
        /*
		if ivSign0.image == nil {
			let alertController = UIAlertController(
				title: "提醒",
				message: "完成驗收，需有屋主代表簽名",
				preferredStyle: .alert)
			
			let okAction = UIAlertAction(title: "確定", style: .default) { (alertController) in
			}
			
			alertController.addAction(okAction)
			self.present(
				alertController,
				animated: true,
				completion: nil)
			return
		}
		
		if ivSign1.image == nil {
			let alertController = UIAlertController(
				title: "提醒",
				message: "完成驗收，需有業主代表簽名",
				preferredStyle: .alert)
			
			let okAction = UIAlertAction(title: "確定", style: .default) { (alertController) in
			}
			
			alertController.addAction(okAction)
			self.present(
				alertController,
				animated: true,
				completion: nil)
			return
		}
		
		if !twoSignatureColumns && ivSign2.image == nil {
			let alertController = UIAlertController(
				title: "提醒",
				message: "完成驗收，需有主管簽名",
				preferredStyle: .alert)
			
			let okAction = UIAlertAction(title: "確定", style: .default) { (alertController) in
			}
			
			alertController.addAction(okAction)
			self.present(
				alertController,
				animated: true,
				completion: nil)
			return
		}
		*/
		print(InsTmpDataManager.sharedInstance().sign0UrlStr + " "  + InsTmpDataManager.sharedInstance().sign1UrlStr  + " " + InsTmpDataManager.sharedInstance().sign2UrlStr )
		let hud = JGProgressHUD(style: .dark)
		hud.vibrancyEnabled = true
		hud.textLabel.text = "儲存中..."
		hud.show(in: self.view)
		
		InsTmpDataManager.sharedInstance().saveData()
		
		hud.dismiss()
		
		InsTmpDataManager.sharedInstance().clearData()
		for viewController in (navigationController?.viewControllers)! {
            if viewController.isKind(of: InsDashboardController.self) {
				navigationController?.popToViewController(viewController, animated: true)
				break
			}
		}
		
	}
	
	@IBAction func btnSignPressed(_ sender: Any) {
		let btn = sender as! UIButton
		signIndex = btn.tag
		let signatureVC = EPSignatureViewController(signatureDelegate: self, showsDate: true, showsSaveSignatureOption: true)
		signatureVC.showsDate = false
        signatureVC.modalPresentationStyle = .fullScreen
		signatureVC.showsSaveSignatureOption = false
		signatureVC.title = "線上簽名"
		signatureVC.subtitleText = "簽名處"
		let nav = UINavigationController(rootViewController: signatureVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
		
	}
	
	func epSignature(_: EPSignatureViewController, didSign signatureImage : UIImage, boundingRect: CGRect) {
		switch signIndex {
		case 0:
			ivSign0.image = signatureImage
			do {
				if let data = UIImagePNGRepresentation(ivSign0.image!) {
					let fileManager = FileManager.default
					let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
					let userIdx = UserDefaults.standard.string(forKey: "UserIdx")
					let fileName = String.init(format: "%@_%.0f.png", userIdx!, NSDate().timeIntervalSince1970)
					let fileURL = documentDirectory.appendingPathComponent(fileName)
					UserDefaults.standard.set(fileName, forKey: "sign0")
                    try data.write(to: fileURL)
					InsTmpDataManager.sharedInstance().sign0UrlStr = fileName
					
				}
			} catch {
				print(error)
			}
			break
		case 1:
			ivSign1.image = signatureImage
			do {
				if let data = UIImagePNGRepresentation(ivSign1.image!) {
					let fileManager = FileManager.default
					let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
					let userIdx = UserDefaults.standard.string(forKey: "UserIdx")
					let fileName = String.init(format: "%@_%.0f.png", userIdx!, NSDate().timeIntervalSince1970)
					let fileURL = documentDirectory.appendingPathComponent(fileName)
					try data.write(to: fileURL)
                    UserDefaults.standard.set(fileName, forKey: "sign1")
					InsTmpDataManager.sharedInstance().sign1UrlStr = fileName
					
				}
			} catch {
				print(error)
			}
			break
		case 2:
			ivSign2.image = signatureImage
			do {
				if let data = UIImagePNGRepresentation(ivSign2.image!) {
					let fileManager = FileManager.default
					let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
					let userIdx = UserDefaults.standard.string(forKey: "UserIdx")
					let fileName = String.init(format: "%@_%.0f.png", userIdx!, NSDate().timeIntervalSince1970)
					let fileURL = documentDirectory.appendingPathComponent(fileName)
					try data.write(to: fileURL)
                    UserDefaults.standard.set(fileName, forKey: "sign2")
					InsTmpDataManager.sharedInstance().sign2UrlStr = fileName
					
				}
			} catch {
				print(error)
			}
			break
		
		default:
			return
		}
	}
	
	func epSignature(_: EPSignatureViewController, didCancel error : NSError) {
		
	}
    @IBAction func clickPrint(_ sender: Any) {
        /*
        isPrint = true
        tableView.reloadData()
        tableView.setContentOffset(.zero, animated: false)
        targetCell?.isHidden = false
        do {

            for i in 0...tableView.numberOfSections - 1  {
                for j in 0...tableView.numberOfRows(inSection: i) {
                  tableView.cellForRow(at: IndexPath(row: j, section: j))
                }
            }
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let pdfURL = documentDirectory.appendingPathComponent("final.pdf")
            var data = PDFWithScrollView(scrollview: self.tableView)
            data.write(toFile: pdfURL.path, atomically: true)
            data = PDFWithScrollView(scrollview: self.tableView)
            data.write(toFile: pdfURL.path, atomically: true)
           //try PDFGenerator.generate(self.tableView, to: pdfURL)
            let printController = UIPrintInteractionController.shared
            let printInfo = UIPrintInfo(dictionary : nil)
            printInfo.duplex = .longEdge
            printInfo.outputType = .grayscale
            printInfo.jobName = "列印驗屋確認單"
            printController.printInfo = printInfo
            printController.printingItem = pdfURL
            printController.present(animated : true, completionHandler : nil)
    
        } catch let error {
            print(error)
        }
      targetCell?.isHidden = true
        isPrint = false
        tableView.reloadData()
      tableView.setContentOffset(.zero, animated: false)
 */
        printInspection()
    }

    private func printInspection() {
        let pdfURL = PDFGenerator().createPDF(placeData, twoSignatureColumns: twoSignatureColumns, format: selectedFormat)
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary : nil)
        printInfo.duplex = .longEdge
        printInfo.outputType = .general
        printInfo.jobName = "列印驗屋確認單"
        printController.printInfo = printInfo
        printController.printingItem = pdfURL
        printController.present(animated : true, completionHandler : nil)
        
    }

    @IBAction func btnListPressed(sender: AnyObject) {
        let button = sender as! UIButton
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        /*alert.addAction(UIAlertAction(title: "顯示數量清點單", style: .default) { _ in
            
            let insDetectListCountController = InsDetectListCountController()
            insDetectListCountController.targetPlaceData = self.placeAllData
            self.navigationController?.pushViewController(insDetectListCountController, animated: true)
            
            
            
        })*/
        
        
        if selectedFormat == .list {
            let signatureTitle = twoSignatureColumns ? "簽名欄位改成三欄" : "簽名欄位改成兩欄"
            alert.addAction(UIAlertAction(title: signatureTitle, style: .default) { _ in
                self.twoSignatureColumns.toggle()
                self.applySelectedFormat()
            })
        }

        alert.addAction(UIAlertAction(title: selectedFormat == .photoGrid ? "列印驗屋紀錄（含照片）" : "列印驗屋紀錄（純文字）", style: .default) { _ in
            self.printInspection()
        })
        
        alert.addAction(UIAlertAction(title: "儲存驗屋紀錄", style: .default) { _ in
            print(InsTmpDataManager.sharedInstance().sign0UrlStr + " "  + InsTmpDataManager.sharedInstance().sign1UrlStr  + " " + InsTmpDataManager.sharedInstance().sign2UrlStr )
            let hud = JGProgressHUD(style: .dark)
            hud.vibrancyEnabled = true
            hud.textLabel.text = "儲存中..."
            hud.show(in: self.view)
            
            InsTmpDataManager.sharedInstance().saveData()
            
            hud.dismiss()
            
            InsTmpDataManager.sharedInstance().clearData()
            for viewController in (self.navigationController?.viewControllers)! {
                if viewController.isKind(of: InsDashboardController.self) {
                    self.navigationController?.popToViewController(viewController, animated: true)
                    break
                }
            }
        })
        
        
        let popPresenter = alert.popoverPresentationController
        popPresenter?.sourceView = button
        popPresenter?.sourceRect = button.bounds
        present(alert, animated: true)
    }
   
    /*
    func PDFWithScrollView(scrollview: UIScrollView) -> NSData {
        
        
        
        let pageDimensions = scrollview.bounds
        
        
        let pageSize = pageDimensions.size
        let totalSize = scrollview.contentSize
        
        let numberOfPagesThatFitHorizontally = Int(ceil(totalSize.width / pageSize.width))
        let numberOfPagesThatFitVertically = Int(ceil(totalSize.height / pageSize.height))
        
        
        let outputData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(outputData, pageDimensions, nil)
        
        
        let savedContentOffset = scrollview.contentOffset
        let savedContentInset = scrollview.contentInset
        
        scrollview.contentInset = UIEdgeInsets.zero
        
        
        
        if let context = UIGraphicsGetCurrentContext()
        {
            for indexHorizontal in 0 ..< numberOfPagesThatFitHorizontally
            {
                for indexVertical in 0 ..< numberOfPagesThatFitVertically
                {
                    
                    
                    
                    UIGraphicsBeginPDFPage()
                    
                    
                    
                    let offsetHorizontal = CGFloat(indexHorizontal) * pageSize.width
                    let offsetVertical = CGFloat(indexVertical) * pageSize.height
                    
                    scrollview.contentOffset = CGPoint(x:offsetHorizontal, y:offsetVertical)
                    context.translateBy(x: -offsetHorizontal, y: -offsetVertical)
                    
                    
                    
                    scrollview.layer.render(in: context)
                }
            }
        }
        
        
        UIGraphicsEndPDFContext()
        
        
        
        scrollview.contentInset = savedContentInset
        scrollview.contentOffset = savedContentOffset
        
        
        return outputData
    }
 */
    
}
 
 


// Use the PDF cell renderer so photo placement and text match the exported form.
private final class InspectionPhotoRecordCell: UICollectionViewCell {
    private var record: PDFData?
    private let renderer = PDFGenerator()
    private let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        isOpaque = true
        contentMode = .redraw
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitButton
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ record: PDFData) {
        self.record = record
        accessibilityLabel = record.title + "，" + record.content
        accessibilityHint = record.isEmptyState ? nil : "點兩下編輯缺失資料與照片"
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), let record = record else { return }
        context.saveGState()
        context.scaleBy(x: bounds.width / 271.5, y: bounds.height / 292)
        renderer.drawPhotoCell(record, in: CGRect(x: 0.5, y: 0.5, width: 270.5, height: 291), directory: directory)
        context.restoreGState()
    }
}
