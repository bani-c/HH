//
//  ViewController.swift
//  Home-Maintenance
//
//  Created by Bani on 14/09/2017.
//  Copyright © 2017 Ultron mobile. All rights reserved.
//

import UIKit
import JGProgressHUD
import SQLite
import FSCalendar

class NewsController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var newsData:[NewsData] = []
    @IBOutlet weak var tableView: UITableView!
   
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var ivPic: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lsPicHeight: NSLayoutConstraint!
    @IBOutlet weak var lblContent: UILabel!
    // MARK: Life Circle
	override func viewDidLoad() {
		super.viewDidLoad()
        initData()
		initLayaout()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: Custom Functions
	func initLayaout() {
		//Change orientation
		let value = UIInterfaceOrientation.landscapeRight.rawValue
		UIDevice.current.setValue(value, forKey: "orientation")
		
		//init back button
		let btnBack = NaviTool.initBtnBack()
		btnBack.addTarget(self, action: #selector(btnBackPressed(sender:)), for: .touchUpInside)
		self.view.addSubview(btnBack)
        tableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        let data = newsData[0]
        lblTitle.text = data.title
        lblTime.text = data.time
        ivPic.image = UIImage(named: data.pic)
        lblContent.text = data.content
       
        
		
	}
	
	func initData() {
		var data = NewsData()
        data.pic = "building_pic_1"
        data.title = "皇翔玉璽 坐擁圓山公園"
        data.time = "2010-7-6"
        data.content = "市政府積極推動捷運圓山站週邊環境改造，整合台銀及市有土地，提供公共運輸與停車空間。從捷運圓山站西側，東臨圓山公園、中山足球場、台北市立美術館、城市博物館預定地等多項北市文化及休憩地點。其向西接至孔廟歷史城區觀光再生計劃地域等文化資產，將「皇翔玉璽」週邊區塊串連成中外知名之觀光遊憩帶。\n\n在台北，國際花卉博覽會規劃出圓山公園、美術公園、新生公園三大公園，即圓山公園特區和大佳河濱公園展區，91.8公頃的展覽園區，堪稱台北史上最大規模綠化建設。  營建上市公司皇翔建設，在此時推出大基地建案「皇翔玉璽」即刻享受都更的優點，近有捷運圓山站，環抱11萬坪圓山公園、大佳河濱公園，加上花博街道建設及美術館的文化舞台，鄰近中小學、中山足球場，造就台北市中心少有的寬闊生活氛圍，無論從景觀、捷運或是公共建設角度切入，都是完美的置產區段。\n\n「皇翔玉璽」位於承德路大道，坪數規劃60坪、80坪、100坪大戶，開價與其它地區的天價相對合理。"
        newsData.append(data)
        
       
        
        data = NewsData()
        data.pic = "building_pic_2"
        data.title = "★優異獎★亞太住宅物產獎"
        data.time = "2010-4-22"
        data.content = "亞太住宅物產獎\n\n2010\n\n★優異獎★\n\n台灣最佳建築風格\n\n皇翔建設股份有限公司\n\n"
        newsData.append(data)
        
        data = NewsData()
        data.title = "Q3精銳盡出 將推700億案量"
        data.time = "2010-3-30"
        data.content = "皇翔手中指標重案將在2010起陸續推出，因此營收和獲利反映在市場的能見度將愈來愈高，今年第二季起推案量放量是可預期的，更可說是精銳盡出，除了價格將有再創區域新高可能外，地段與產品力的加強也是今年皇翔推案的重要賣點。皇翔建設董事長廖年吉表示，「由於去年國際金融風暴突然發生，為使企業穩健經營以因應時局變化，所以推案轉趨緩慢，景氣開始復甦後，真正價格最漂亮的時機點將在2010年看到，今年台北房市V型反彈的力道不容小覷。」經歷去年一整年的沉寂，默默儲備了六、七百億案量，等待對的時機出手。\n皇翔建設以堅守本業、穩健踏實的經營理念，用心規劃產品並提供完善的服務策略，在董事長的帶領及堅持誠信商譽的理念下，今年預計推出皇翔民生東路、皇翔中山北路案、皇翔圓山案、皇翔三峽北大案、皇翔文山102案、皇翔-F4案及今年初標得臨沂街、懷生段兩塊國有地等，俱是地段甚優、交通及生活機能極佳之產品，推案金額上看六、七百億（詳見附表一），預計皇翔民生東路、皇翔中山北路、皇翔F4案可於今年完工，另皇翔三峽北大案目前已進行施工，預計採邊建邊售方式銷售。\n可預見今年第二、三季皇翔將會精銳盡出，尤其Q3將會是今年皇翔的強銷期。除此外，皇翔在台北縣市尚擁有上萬坪精華地段土地目前都在規劃設計中（詳見附表二），預計可陸續推出。\n此外，未來皇翔手頭尚有「華山藝文特區忠孝臨沂」、「南京衣蝶商圈」、「信義捷運東門站」等商用不動產大案，將伺機推出市場。\n皇翔董事長廖年吉形容「土地是建設公司的柴火，庫存越多，燒得越久越旺。」因此皇翔早在土城永寧站與海山站佈局8350坪的土地開發案，持續提供未來公司收益。再加上北縣升格定案、捷運網絡逐漸完善下可帶動人口往北縣移動，也塑造皇翔未來在新北市推案，房價上漲的有利環境。\n在營建業內一直是最低調、保守的皇翔建設於今年元月以10.63億元標下臨沂街、建國南路2塊國有地，使得土地庫存量已上看700億元，加上寸土寸金的信義計劃區房價行情不斷墊高皇翔「F4」的想像空間，未來獲利可期。皇翔建設九十八年自結稅前損益為新台幣壹拾參億肆仟捌佰餘萬元，每股盈餘4.11元，以皇翔建設過去穩健的產銷能力，預估今明年的業績及獲利應可倍增，以目前之股價值得投資人長期持有。"
        newsData.append(data)
       
	}
	
	@objc func btnBackPressed(sender: UIBarButtonItem) {
		self.navigationController?.popViewController(animated: true)
	}
	
	
	
	// control orientation
	override var shouldAutorotate: Bool {
		return false
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .landscapeRight
	}
    
 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsData.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        let data = newsData[indexPath.row]
        cell.lblTitle.text = data.title
        cell.lblTime.text = data.time
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = newsData[indexPath.row]
        lblTitle.text = data.title
        lblTime.text = data.time
        if data.pic != "" {
           ivPic.isHidden = false
            ivPic.image = UIImage(named: data.pic)
            lsPicHeight.constant = 200
            view.updateConstraints()
        } else {
            ivPic.isHidden = true
            lsPicHeight.constant = 0
            view.updateConstraints()
        }
        
        lblContent.text = data.content
      
       
    }

  
}



class NewsData {
    var pic = ""
    var time = ""
    var title = ""
    var content = ""
}

