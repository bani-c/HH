//
//  PFTGenerator.swift
//  Home-Maintenance
//
//  Created by Bani on 2018/7/31.
//  Copyright © 2018 Ultron mobile. All rights reserved.
//
import UIKit
import Foundation
import SQLite
enum InspectionPDFFormat {
    case list
    case photoGrid
}

class PDFGenerator:NSObject {
    var placeData:[InsPlaceItem] = []
    
    func createPDF(_ placeData:[InsPlaceItem], twoSignatureColumns: Bool = false, format: InspectionPDFFormat = .list) -> URL {
        
        self.placeData = InspectionPrintOrder.sorted(placeData)
        let pdfDataGroup = generatePDFData(itemsPerPage: format == .photoGrid ? 4 : 20, expandPhotos: format == .photoGrid)
        if format == .photoGrid {
            return createPhotoGridPDF(pdfDataGroup)
        }
        do {
            
            let a4Size = CGSize(width: 612, height: 772)
            let rect = CGRect(x: 0, y: 0, width: a4Size.width, height: a4Size.height)
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileName = "print.pdf"
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            do {
                try fileManager.removeItem(at: fileURL)
                print("Existing file deleted.")
            } catch {
                print("Failed to delete existing file:\n\((error as NSError).description)")
            }
            UIGraphicsBeginPDFContextToFile(fileURL.path, rect, nil)
            var pdfArray:[PDFTemplateView] = []
            var index = 1
            for (pageIndex, pdfDataSub) in pdfDataGroup.enumerated() {
                let pdfTmp = Bundle.main.loadNibNamed("PDFTemplateView", owner: self, options: nil)?.first as! PDFTemplateView
                pdfTmp.setup(
                    pdfDataSub,
                    index: index,
                    pageNumber: pageIndex + 1,
                    totalPages: pdfDataGroup.count
                )
                pdfTmp.setSignatureColumns(twoColumns: twoSignatureColumns)
                pdfTmp.layoutIfNeeded()
                pdfArray.append(pdfTmp)
                index += pdfDataSub.count
            }
            
            
            for pdfPage in pdfArray {
                UIGraphicsBeginPDFPageWithInfo(rect, nil);
                let pdfContext = UIGraphicsGetCurrentContext()
                pdfPage.layer.render(in: pdfContext!)
            }
            UIGraphicsEndPDFContext()
            return fileURL
        } catch {
            print(error)
        }
        return URL(fileURLWithPath: "")
       
    }
    
    func generatePDFData(itemsPerPage: Int = 20, expandPhotos: Bool = false) -> [[PDFData]]{
        var index = 1
        var pdfDataAll:[PDFData] = []
        for placeItem in placeData {
            for item in placeItem.items {
                let data = PDFData()
                data.photoNames = item.picUrls
                if placeItem.placeName.isEmpty {
                    data.title = String(format: "%d. ", index) + placeItem.areaName + ":" + item.name
                } else {
                   data.title = String(format: "%d. ", index) + placeItem.areaName + "-" + placeItem.placeName + ":" + item.name
                }
                
                if !item.desName.isEmpty {
                    data.content = item.desName
                }
                
                if !item.inspRemark.isEmpty {
                    data.content = item.inspRemark
                }

                if !item.inspRemark.isEmpty && !item.desName.isEmpty {
                    data.content = String(format: "%@: %@", item.desName, item.inspRemark)
                }
                
                if !item.amount.isEmpty && item.amount != "0" {
                    data.content += " 缺少：\(item.amount)"
                }
                
                
//                    if !item.inspRemark.isEmpty && item.desName == "其他描述" {
//                        data.content = String(format: "%@: %@", item.desName, item.inspRemark)
//                    }
                if expandPhotos && data.photoNames.count > 1 {
                    for (photoIndex, name) in data.photoNames.enumerated() {
                        let photoData = PDFData()
                        photoData.title = data.title + "（照片\(photoIndex + 1)）"
                        photoData.content = data.content
                        photoData.photoNames = [name]
                        pdfDataAll.append(photoData)
                    }
                } else {
                    pdfDataAll.append(data)
                }
                index += 1
                
            }
        }
        if pdfDataAll.isEmpty {
            let emptyData = PDFData()
            emptyData.title = "無缺失項目"
            emptyData.isEmptyState = true
            return [[emptyData]]
        }
        var pdfDataGroup:[[PDFData]] = []
        var pdfDataSub:[PDFData] = []
        for data in pdfDataAll {
            pdfDataSub.append(data)
            if pdfDataSub.count == max(1, itemsPerPage) {
                pdfDataGroup.append(pdfDataSub)
                pdfDataSub = []
            }
        }
        if pdfDataSub.count != 0 {
            pdfDataGroup.append(pdfDataSub)
        }
        return pdfDataGroup
    }
    
    func getDesName(_ desId:String) -> String {
        do {
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let mainFileURL = documentDirectory.appendingPathComponent(SystemConstants.DBFileName)
            let dbMain = try Connection(mainFileURL.absoluteString)
            let table = Table("InspDescItem")
            let table_inspDescItemId = Expression<String?>("InspDescItemId")
            let table_inspDescItemName = Expression<String?>("InspDescItemName")
            let Sorting = Expression<String?>("Sorting")
            let query = table.select(table_inspDescItemId, table_inspDescItemName).filter(table_inspDescItemId == desId).order(Sorting.asc)
            for data in try dbMain.prepare(query) {
                print("name: \(data[table_inspDescItemId]!)")
                return data[table_inspDescItemName]!
            }
           
        } catch {
            
        }
        
        return ""
    }
}

class PDFData {
    var photoNames: [String] = []
    var isEmptyState = false
    var title:String = ""
    var content:String = ""
}

// A4 photo record: four defects in reading order, with two signature columns.
extension PDFGenerator {
    func createPhotoGridPDF(_ pages: [[PDFData]]) -> URL {
        do {
            let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
                                                        appropriateFor: nil, create: false)
            let url = directory.appendingPathComponent("inspection-photos.pdf")
            let bounds = CGRect(x: 0, y: 0, width: 595, height: 842)
            UIGraphicsBeginPDFContextToFile(url.path, bounds, nil)
            defer { UIGraphicsEndPDFContext() }
            for (pageIndex, items) in pages.enumerated() {
                UIGraphicsBeginPDFPageWithInfo(bounds, nil)
                drawPhotoGridPage(items, directory: directory, page: pageIndex + 1, total: pages.count)
            }
            return url
        } catch {
            print("Unable to create photo inspection PDF: \(error)")
            return URL(fileURLWithPath: "")
        }
    }

    func drawPhotoGridPage(_ items: [PDFData], directory: URL, page: Int, total: Int) {
        let defaults = UserDefaults.standard
        drawText((defaults.string(forKey: "PROJECT_NAME") ?? "") + "－驗屋紀錄單",
                 in: CGRect(x: 26, y: 24, width: 543, height: 24), size: 16, centered: true)
        let header = CGRect(x: 26, y: 58, width: 543, height: 38)
        stroke(header)
        let date = DateFormatter()
        date.dateFormat = "yyyy/MM/dd"
        let fields = ["棟別：" + (defaults.string(forKey: "BUILDING") ?? ""),
                      "樓別：" + (defaults.string(forKey: "FLOOR") ?? ""),
                      "戶別：" + (defaults.string(forKey: "ROOM") ?? ""),
                      "驗屋日期：" + date.string(from: Date())]
        let widths: [CGFloat] = [90, 90, 135, 228]
        var x: CGFloat = header.minX
        for (index, field) in fields.enumerated() {
            drawText(field, in: CGRect(x: x + 5, y: 69, width: widths[index] - 10, height: 19), size: 10)
            x += widths[index]
        }
        for slot in 0..<4 {
            let cell = CGRect(x: 26 + CGFloat(slot % 2) * 271.5,
                              y: 96 + CGFloat(slot / 2) * 292, width: 271.5, height: 292)
            let item = slot < items.count ? items[slot] : nil
            drawPhotoCell(item, in: cell, directory: directory)
        }
        for index in 0..<2 {
            let cell = CGRect(x: 26 + CGFloat(index) * 271.5, y: 700, width: 271.5, height: 75)
            stroke(cell)
            stroke(CGRect(x: cell.minX, y: cell.minY, width: 28, height: cell.height))
            drawText(index == 0 ? "屋\n主\n代\n表" : "業\n主\n代\n表",
                     in: CGRect(x: cell.minX + 4, y: cell.minY + 6, width: 20, height: 64),
                     size: 11, centered: true)
            if let name = defaults.string(forKey: "sign\(index)"),
               let image = UIImage(contentsOfFile: directory.appendingPathComponent(name).path) {
                drawImage(image, in: CGRect(x: cell.minX + 34, y: cell.minY + 5,
                                           width: cell.width - 40, height: 65))
            }
        }
        drawText("第 \(page) / \(total) 頁", in: CGRect(x: 26, y: 791, width: 543, height: 18),
                 size: 9, centered: true)
    }

    func drawPhotoCell(_ item: PDFData?, in cell: CGRect, directory: URL) {
        let labelWidth: CGFloat = 40
        let titleHeight: CGFloat = 44
        let descriptionHeight: CGFloat = 60
        stroke(cell)
        stroke(CGRect(x: cell.minX, y: cell.minY, width: cell.width, height: titleHeight))
        stroke(CGRect(x: cell.minX, y: cell.minY, width: labelWidth, height: titleHeight))
        stroke(CGRect(x: cell.minX, y: cell.minY + titleHeight, width: cell.width, height: descriptionHeight))
        stroke(CGRect(x: cell.minX, y: cell.minY + titleHeight, width: labelWidth, height: descriptionHeight))
        drawText("項目", in: CGRect(x: cell.minX + 3, y: cell.minY + 14, width: 34, height: 20),
                 size: 11, centered: true)
        drawText("缺失\n描述", in: CGRect(x: cell.minX + 3, y: cell.minY + titleHeight + 14,
                                         width: 34, height: 36), size: 11, centered: true)
        drawText(item?.title ?? "", in: CGRect(x: cell.minX + 45, y: cell.minY + 5,
                                               width: cell.width - 50, height: titleHeight - 10), size: 11)
        drawText(item?.content ?? "", in: CGRect(x: cell.minX + 45, y: cell.minY + titleHeight + 5,
                                                 width: cell.width - 50, height: descriptionHeight - 10), size: 11)
        let photoRect = CGRect(x: cell.minX + 6, y: cell.minY + titleHeight + descriptionHeight + 6,
                               width: cell.width - 12, height: cell.height - titleHeight - descriptionHeight - 12)
        guard let item = item, !item.isEmptyState else { return }
        guard let name = item.photoNames.first else {
            drawText("未附照片", in: CGRect(x: photoRect.minX, y: photoRect.midY - 9,
                                             width: photoRect.width, height: 18), size: 11, centered: true)
            return
        }
        if let image = UIImage(contentsOfFile: directory.appendingPathComponent(name).path) {
            drawImage(image, in: photoRect)
        } else {
            drawText("照片無法載入", in: CGRect(x: photoRect.minX, y: photoRect.midY - 9,
                                               width: photoRect.width, height: 18), size: 11, centered: true)
        }
    }

    func stroke(_ rect: CGRect) {
        UIColor.black.setStroke()
        let path = UIBezierPath(rect: rect)
        path.lineWidth = 0.8
        path.stroke()
    }

    func drawText(_ text: String, in rect: CGRect, size: CGFloat, centered: Bool = false) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = centered ? .center : .left
        paragraph.lineBreakMode = .byWordWrapping
        var fontSize = size
        var attributes: [NSAttributedStringKey: Any] = [:]
        repeat {
            attributes = [.font: UIFont.systemFont(ofSize: fontSize), .foregroundColor: UIColor.black,
                          .paragraphStyle: paragraph]
            let measured = (text as NSString).boundingRect(with: CGSize(width: rect.width, height: .greatestFiniteMagnitude),
                                                           options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                           attributes: attributes, context: nil)
            if measured.height <= rect.height || fontSize <= 6 { break }
            fontSize -= 0.5
        } while true
        (text as NSString).draw(with: rect, options: [.usesLineFragmentOrigin, .usesFontLeading],
                               attributes: attributes, context: nil)
    }

    func drawImage(_ image: UIImage, in rect: CGRect) {
        guard image.size.width > 0, image.size.height > 0 else { return }
        let scale = min(rect.width / image.size.width, rect.height / image.size.height)
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        image.draw(in: CGRect(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2,
                              width: size.width, height: size.height))
    }
}
