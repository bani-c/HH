//
//  PhotoView.swift
//  Home-Maintenance
//
//  Created by Yuchi Chen on 2017/9/22.
//  Copyright © 2017年 Ultron mobile. All rights reserved.
//

import UIKit

class PhotoView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var vwBackground: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnNext: UIButton!
    
    let photoCellIdentifier = "PhotoCell"
    var titles = [String]()
    var images = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //init btnBack & btnNext
        if images.count == 1 {
            btnBack.alpha = 0
            btnNext.alpha = 0
            collectionView.isScrollEnabled = false
        }
    }
    
    func initLayout() {
        //init vwBackground
        vwBackground.backgroundColor = UIColor.init(white: 0.0, alpha: 0.5)
        
        //register nib
        collectionView.register(UINib(nibName: photoCellIdentifier, bundle: nil), forCellWithReuseIdentifier:photoCellIdentifier)
        
        //init collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
    }
    
    //MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier, for: indexPath as IndexPath) as! PhotoCell
        
        cell.setTitle(titles[indexPath.row])
        cell.setImage(named: images[indexPath.row])
        
        if cell.btnClose.allTargets.count == 0 {
            cell.btnClose.addTarget(self, action: #selector(btnClosePressed(sender:)), for: .touchUpInside)
        }
        
        return cell
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width - 6, height: collectionView.frame.size.height);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0;
    }
    
    //MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let index = collectionView.indexPathForItem(at: scrollView.contentOffset)?.row
        
        if index == 0 {
            btnBack.alpha = 0
            btnNext.alpha = 1
        }
        else {
            btnBack.alpha = 1
            btnNext.alpha = 0
        }
    }
    
    //MARK: Button Action
    @IBAction func btnBackPressed(_ sender: UIButton) {
        let x = collectionView.contentOffset.x
        let width = collectionView.frame.size.width
        let index: Int = Int(x / width)
        let indexPath = IndexPath.init(item: index, section: 0)
        
        if indexPath.row == 0 {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    @IBAction func btnNextPressed(_ sender: UIButton) {
        let x = collectionView.contentOffset.x
        let width = collectionView.frame.size.width
        let index: Int = Int(x / width)
        let indexPath = IndexPath.init(item: index + 1, section: 0)
        
        if indexPath.row < titles.count {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    @objc func btnClosePressed(sender: UIButton) {
        self.removeFromSuperview()
    }
	
	@IBAction func btnBackgroundPressed(_ sender: Any) {
		self.removeFromSuperview()
	}
}
