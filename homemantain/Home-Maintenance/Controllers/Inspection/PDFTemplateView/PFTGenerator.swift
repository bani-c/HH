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
class PDFGenerator:NSObject {
    var placeData:[InsPlaceItem] = []
    
    func createPDF(_ placeData:[InsPlaceItem]) -> URL {
        
        if placeData.count == 0 {
            let placeData = InsPlaceItem()
            placeData.items = [InsItem()]
            self.placeData = [placeData]
        } else {
            self.placeData = InspectionPrintOrder.sorted(placeData)
        }
        let pdfDataGroup = generatePDFData()
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
    
    func generatePDFData() -> [[PDFData]]{
        var index = 1
        var pdfDataAll:[PDFData] = []
        for placeItem in placeData {
            for item in placeItem.items {
                let data = PDFData()
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
                pdfDataAll.append(data)
                index += 1
                
            }
        }
        var pdfDataGroup:[[PDFData]] = []
        var pdfDataSub:[PDFData] = []
        for data in pdfDataAll {
            pdfDataSub.append(data)
            if pdfDataSub.count == 20 {
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
    var title:String = ""
    var content:String = ""
}
