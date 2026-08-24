//
//  PhotoCell.swift
//  Home-Maintenance
//
//  Created by Yuchi Chen on 2017/9/22.
//  Copyright © 2017年 Ultron mobile. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var btnClose: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        initLayout()
    }

    func initLayout() {
        
    }
    
    func setTitle(_ title: String) {
        lblTitle.text = title
    }
    
    func setImage(named imageName: String) {
		do {
			let fileManager = FileManager.default
			let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
			let fileURL = documentDirectory.appendingPathComponent(imageName)
			let image = try UIImage.init(data: Data.init(contentsOf: fileURL), scale:1.0)
			imageView.image = image
		} catch {
			print(error)
		}
    }
}
