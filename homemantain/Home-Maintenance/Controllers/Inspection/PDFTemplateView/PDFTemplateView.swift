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
import SQLite
import PDFGenerator

class PDFTemplateView:UIView, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblBuilding: UILabel!
    @IBOutlet weak var lblFloor: UILabel!
    @IBOutlet weak var lblRoom: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblCustomerName: UILabel!
    @IBOutlet weak var lblTel: UILabel!
    @IBOutlet weak var vwHeader: UIView!
  
    @IBOutlet weak var vwSign: UIView!
    @IBOutlet weak var ivSign0: UIImageView!
    @IBOutlet weak var ivSign1: UIImageView!
    @IBOutlet weak var ivSign2: UIImageView!
    
    @IBOutlet weak var lblPageNumber: UILabel!
    var pdfData:[PDFData] = []
    private var showsEmptyState: Bool { return pdfData.count == 1 && pdfData[0].isEmptyState }
    var index = 0
    private var signatureLayout: SignatureColumnsLayout?

    func setSignatureColumns(twoColumns: Bool) {
        if signatureLayout == nil {
            signatureLayout = SignatureColumnsLayout(images: [ivSign0, ivSign1, ivSign2])
        }
        signatureLayout?.apply(twoColumns: twoColumns)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.frame = CGRect(x: 0, y: 0, width: 612, height: 772)
        
        
        
        
    }
    
    func setup(_ pdfData:[PDFData], index:Int, pageNumber:Int, totalPages:Int) {
        initLayout()
        self.pdfData = pdfData
        self.index = index
        lblPageNumber.text = String(format: "第 %d / %d 頁", pageNumber, totalPages)
        tableView.register(UINib(nibName: "PDFHeaderCell", bundle: nil), forCellReuseIdentifier: "PDFHeaderCell")
        tableView.register(UINib(nibName: "PDFErrorCell", bundle: nil), forCellReuseIdentifier: "PDFErrorCell")

        // iOS 15 adds extra padding above the first section header of a plain
        // table view.  That padding becomes a large blank strip in the PDF.
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.sectionHeaderHeight = showsEmptyState ? 0.00001 : 30
        tableView.estimatedSectionHeaderHeight = 0
        tableView.reloadData()
        
    }
    
    func initLayout() {
        
        vwHeader.layer.borderColor = UIColor.darkGray.cgColor
        vwHeader.layer.borderWidth = 1.0
        vwSign.layer.borderColor = UIColor.darkGray.cgColor
        vwSign.layer.borderWidth = 1.0
        
        tableView.layer.borderColor = UIColor.darkGray.cgColor
        tableView.layer.borderWidth = 1.0
        let projectsName = UserDefaults.standard.string(forKey: "PROJECT_NAME")
        let building = UserDefaults.standard.string(forKey: "BUILDING")
        let floor = UserDefaults.standard.string(forKey: "FLOOR")
        let room = UserDefaults.standard.string(forKey: "ROOM")
        lblTitle.text = projectsName! + " - 驗屋紀錄單"
        lblBuilding.text = building
        lblFloor.text = floor
        lblRoom.text = room
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        lblDate.text = dateFormatter.string(from: Date())
        //initSign()
        do {
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            
            
            
            
            
            if UserDefaults.standard.object(forKey: "sign0") != nil {
                let fileName = UserDefaults.standard.string(forKey: "sign0")
                let fileURL = documentDirectory.appendingPathComponent(fileName!)
                let image = try UIImage.init(data: Data.init(contentsOf: fileURL), scale:1.0)
                self.ivSign0.image = image
            }
            if UserDefaults.standard.object(forKey: "sign1") != nil {
                let fileName = UserDefaults.standard.string(forKey: "sign1")
                let fileURL = documentDirectory.appendingPathComponent(fileName!)
                let image = try UIImage.init(data: Data.init(contentsOf: fileURL), scale:1.0)
                self.ivSign1.image = image
            }
            if UserDefaults.standard.object(forKey: "sign2") != nil {
                let fileName = UserDefaults.standard.string(forKey: "sign2")
                let fileURL = documentDirectory.appendingPathComponent(fileName!)
                let image = try UIImage.init(data: Data.init(contentsOf: fileURL), scale:1.0)
                self.ivSign2.image = image
            }
        } catch {
            
        }
        
        
        
    }
    
    func initSign() {
        do {
            
            
            let projectsNo = UserDefaults.standard.string(forKey: "PROJECT_NO")!
            
            let building = UserDefaults.standard.string(forKey: "BUILDING")!
            let fileNameUpload = String.init(format: SystemConstants.DBFileNameSubUpload, projectsNo, building)
            
            
            let room = UserDefaults.standard.string(forKey: "ROOM")!
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
            let ChkNo = Expression<String?>("ChkNo")
            
            
            
            
            var query = InspSignUploadFile.select(FileName).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && ChkNo == InsTargetData.sharedInstance().inspNo && FileType == "0")
            
            for data in try db.prepare(query) {
                print("name: \(data[FileName]!)")
                let fileManager = FileManager.default
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURL = documentDirectory.appendingPathComponent(data[FileName]!)
                
                let image = try UIImage.init(data: Data.init(contentsOf: fileURL), scale:1.0)
                ivSign0.image = image
            }
            
            query = InspSignUploadFile.select(FileName).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && ChkNo == InsTargetData.sharedInstance().inspNo && FileType == "1")
            for data in try db.prepare(query) {
                print("name: \(data[FileName]!)")
                let fileManager = FileManager.default
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURL = documentDirectory.appendingPathComponent(data[FileName]!)
                
                let image = try UIImage.init(data: Data.init(contentsOf: fileURL), scale:1.0)
                ivSign1.image = image
            }
            
            query = InspSignUploadFile.select(FileName).filter(ELEVEL_2_1 == building && ELEVEL_2_2 == room && ChkNo == InsTargetData.sharedInstance().inspNo && FileType == "2")
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

    override func layoutSubviews() {
        super.layoutSubviews()
    }
 
    //MARK: TableView Datasource and Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pdfData.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return showsEmptyState ? 0.00001 : 30
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !showsEmptyState else { return nil }
        let cell = tableView.dequeueReusableCell(withIdentifier: "PDFHeaderCell") as! PDFHeaderCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = pdfData[indexPath.row]
        if data.isEmptyState {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.selectionStyle = .none
            cell.textLabel?.text = data.title
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "PDFErrorCell", for: indexPath) as! PDFErrorCell
        cell.selectionStyle = .none
        cell.lblTitle.text = data.title
        cell.lblContent.text = data.content
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
	
	
	
    
}

// Shared by the confirmation screen and the PDF footer. Original constraints and
// signature images are retained so switching back restores the three-column form.
final class SignatureColumnsLayout {
    private let container: UIView
    private let images: [UIImageView]
    private let titles: [UIView]
    private let buttons: [UIButton]
    private let originalConstraints: [NSLayoutConstraint]
    private var twoColumnConstraints: [NSLayoutConstraint] = []

    init(images: [UIImageView]) {
        self.images = images
        let container = images[0].superview!
        self.container = container
        titles = container.subviews.filter { view in
            view.subviews.contains { $0 is UILabel }
        }.sorted { $0.frame.minX < $1.frame.minX }
        buttons = container.subviews.compactMap { $0 as? UIButton }.sorted { $0.tag < $1.tag }
        originalConstraints = container.constraints.filter {
            ($0.firstItem as? UIView) !== container || $0.secondItem != nil
        }
    }

    func apply(twoColumns: Bool) {
        guard titles.count == 3 else { return }
        NSLayoutConstraint.deactivate(twoColumnConstraints)
        twoColumnConstraints.removeAll()
        titles[2].isHidden = twoColumns
        images[2].isHidden = twoColumns
        buttons.first { $0.tag == 2 }?.isHidden = twoColumns
        if !twoColumns {
            NSLayoutConstraint.activate(originalConstraints)
            return
        }
        NSLayoutConstraint.deactivate(originalConstraints)
        for index in 0..<2 {
            let title = titles[index]
            let image = images[index]
            twoColumnConstraints += [
                title.topAnchor.constraint(equalTo: container.topAnchor),
                title.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                title.leadingAnchor.constraint(equalTo: index == 0 ? container.leadingAnchor : images[0].trailingAnchor),
                image.leadingAnchor.constraint(equalTo: title.trailingAnchor),
                image.topAnchor.constraint(equalTo: container.topAnchor),
                image.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ]
            if let button = buttons.first(where: { $0.tag == index }) {
                twoColumnConstraints += [
                    button.leadingAnchor.constraint(equalTo: image.leadingAnchor),
                    button.trailingAnchor.constraint(equalTo: image.trailingAnchor),
                    button.topAnchor.constraint(equalTo: image.topAnchor),
                    button.bottomAnchor.constraint(equalTo: image.bottomAnchor)
                ]
            }
        }
        twoColumnConstraints += [
            images[0].trailingAnchor.constraint(equalTo: container.centerXAnchor),
            images[1].trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ]
        NSLayoutConstraint.activate(twoColumnConstraints)
    }
}
