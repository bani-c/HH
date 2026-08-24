//
//  ViewController.swift
//  NxtPos
//
//  Created by Bani on 2018/6/3.
//  Copyright © 2018 Bani. All rights reserved.
//

import UIKit

class AddBookingController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    var buildings = ["A"]
    var floors = ["1F", "2F", "3F", "5F", "6F", "7F", "8F", "9F", "10F"]
    var rooms = ["01", "02", "03", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15"]
    var times = ["09:00-10:00", "10:00-11:00", "13:00-14:00", "14:00-15:00", "15:00-16:00", "16:00-17:00"]
    
    @IBOutlet weak var tfTime: UITextField!
    @IBOutlet weak var tfRoom: UITextField!
    @IBOutlet weak var tfFloor: UITextField!
    @IBOutlet weak var tfBuilding: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        initLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initTextFields()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initLayout() {
        btnSave.layer.cornerRadius = 5
        btnSave.layer.masksToBounds = true
       
       
        
    }
    
    func initTextFields() {
        //init textFields
        tfBuilding.text = buildings[0]
        tfRoom.text = rooms[0]
        tfFloor.text = floors[0]
        tfTime.text = times[0]
        initTextField(textField: tfBuilding, tag: 0)
        initTextField(textField: tfRoom, tag: 1)
        initTextField(textField: tfFloor, tag: 2)
        initTextField(textField: tfTime, tag: 3)
        
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
        
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width:view.frame.width, height: 300))
        
        bgView.addSubview(picker)
        
        textField.inputView = bgView
    }
    
    // MARK: UIPickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return buildings.count
        } else if pickerView.tag == 1 {
            return floors.count
        } else if pickerView.tag == 2 {
            return rooms.count
        } else if pickerView.tag == 3 {
            return times.count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return buildings[row]
        } else if pickerView.tag == 1 {
            return floors[row]
        } else if pickerView.tag == 2 {
            return rooms[row]
        } else if pickerView.tag == 3 {
            return times[row]
        } else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            tfBuilding.text = buildings[row]
        } else if pickerView.tag == 1 {
            tfFloor.text = floors[row]
        } else if pickerView.tag == 2 {
            tfRoom.text = rooms[row]
        } else if pickerView.tag == 3 {
            tfTime.text = times[row]
        } else {
            
        }
    }
    
    @IBAction func clickBackground(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
   
    @IBAction func clickCancel(_ sender: Any) {
        clickBackground(btnCancel)
    }
    
    @IBAction func clickSave(_ sender: Any) {
        clickBackground(btnCancel)
    }
    
   
}

