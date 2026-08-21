//
//  ViewController.swift
//  NXDrawKit
//
//  Created by Nicejinux on 2016. 7. 12..
//  Copyright © 2016년 Nicejinux. All rights reserved.
//

import UIKit
import NXDrawKit
import RSKImageCropper
import AVFoundation
import MobileCoreServices

@objc public protocol CameraControllerDelegate
{
	@objc optional func didFinishPhoto(image:UIImage)
}

class CameraController: UIViewController
{

	
    weak var canvasView: Canvas?
    weak var paletteView: Palette?
    weak var toolBar: ToolBar?
	@objc open weak var delegate: CameraControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.initialize()
	}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func initialize() {
        self.setupCanvas()
        self.setupPalette()
        self.setupToolBar()
		DispatchQueue.main.async {
			self.showCamera()
		}
    }
    
    fileprivate func setupPalette() {
		
		//init back button
		let btnBack = NaviTool.initBtnBack()
		btnBack.addTarget(self, action: #selector(btnBackPressed(sender:)), for: .touchUpInside)
		self.view.addSubview(btnBack)
		
        self.view.backgroundColor = UIColor.white
        
        let paletteView = Palette()
        paletteView.delegate = self
        paletteView.setup()
        self.view.addSubview(paletteView)
        self.paletteView = paletteView
        let paletteHeight = paletteView.paletteHeight()
        paletteView.frame = CGRect(x: 0, y: self.view.frame.height - paletteHeight, width: self.view.frame.width, height: paletteHeight)
    }
	
	//MARK: Button Action
	@objc func btnBackPressed(sender: UIBarButtonItem) {
		self.navigationController?.popViewController(animated: true)
	}
    
    fileprivate func setupToolBar() {
        let height = (self.paletteView?.frame)!.height * 0.25
        let startY = self.view.frame.height - (paletteView?.frame)!.height - height
        let toolBar = ToolBar()
        toolBar.frame = CGRect(x: 0, y: startY, width: self.view.frame.width, height: height)
        toolBar.undoButton?.addTarget(self, action: #selector(CameraController.onClickUndoButton), for: .touchUpInside)
        toolBar.redoButton?.addTarget(self, action: #selector(CameraController.onClickRedoButton), for: .touchUpInside)
        toolBar.loadButton?.addTarget(self, action: #selector(CameraController.onClickLoadButton), for: .touchUpInside)
        toolBar.saveButton?.addTarget(self, action: #selector(CameraController.onClickSaveButton), for: .touchUpInside)
        // default title is "Save"
        toolBar.saveButton?.setTitle("save", for: UIControlState())
        toolBar.clearButton?.addTarget(self, action: #selector(CameraController.onClickClearButton), for: .touchUpInside)
        toolBar.loadButton?.isEnabled = true
		toolBar.loadButton?.isHidden = true
        self.view.addSubview(toolBar)
        self.toolBar = toolBar
    }
    
    fileprivate func setupCanvas() {
		//        let canvasView = Canvas(backgroundImage: UIImage.init(named: "frame")!) // You can init with custo(m background image
		let canvasView = Canvas()
        let height = self.view.frame.size.height - 50 - 87 - 180
		canvasView.frame = CGRect(x: 200, y: 50 + 67, width: height / 3 * 4, height: height)
		canvasView.center = CGPoint.init(x: self.view.frame.origin.x + self.view.frame.size.width / 2, y: canvasView.center.y)
        canvasView.delegate = self
        canvasView.layer.borderColor = UIColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 0.8).cgColor
        canvasView.layer.borderWidth = 2.0
        canvasView.layer.cornerRadius = 5.0
        canvasView.clipsToBounds = true
        self.view.addSubview(canvasView)
        self.canvasView = canvasView
    }
    
    fileprivate func updateToolBarButtonStatus(_ canvas: Canvas) {
        self.toolBar?.undoButton?.isEnabled = canvas.canUndo()
        self.toolBar?.redoButton?.isEnabled = canvas.canRedo()
        self.toolBar?.saveButton?.isEnabled = canvas.canSave()
        self.toolBar?.clearButton?.isEnabled = canvas.canClear()
    }
    
    @objc func onClickUndoButton() {
        self.canvasView?.undo()
    }

    @objc func onClickRedoButton() {
        self.canvasView?.redo()
    }

    @objc func onClickLoadButton() {
        self.showActionSheetForPhotoSelection()
    }

    @objc func onClickSaveButton() {
        self.canvasView?.save()
    }

    @objc func onClickClearButton() {
        self.canvasView?.clear()
    }

    
    // MARK: - Image and Photo selection
    fileprivate func showActionSheetForPhotoSelection() {
		let actionSheet = UIActionSheet(title: nil, delegate: self as! UIActionSheetDelegate, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Photo from Album", "Take a Photo")
        actionSheet.show(in: self.view)
    }
    
    fileprivate func showPhotoLibrary () {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [String(kUTTypeImage)]
		
        present(picker, animated: true, completion: nil)
    }
    
    fileprivate func showCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch (status) {
        case .notDetermined:
            self.presentImagePickerController()
            break
        case .restricted, .denied:
            self.showAlertForImagePickerPermission()
            break
        case .authorized:
            self.presentImagePickerController()
            break
        }
    }
    
    fileprivate func showAlertForImagePickerPermission() {
        let message = "If you want to use camera, you should allow app to use.\nPlease check your permission"
        let alert = UIAlertView(title: "", message: message, delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Allow")
        alert.show()
    }
    
    fileprivate func openSettings() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(url!)
    }
    
    fileprivate func presentImagePickerController() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.mediaTypes = [kUTTypeImage as String]
		    //present(picker, animated: true, completion: nil)
			DispatchQueue.main.async {
				self.present(picker, animated: true, completion: nil)
			}
			
        } else {
            let message = "This device doesn't support a camera"
            let alert = UIAlertView(title:"", message:message, delegate:nil, cancelButtonTitle:nil, otherButtonTitles:"Ok")
            alert.show()
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError: NSError?, contextInfo:UnsafeRawPointer)       {
        if didFinishSavingWithError != nil {
            let message = "Saving failed"
            let alert = UIAlertView(title:"", message:message, delegate:nil, cancelButtonTitle:nil, otherButtonTitles:"Ok")
            alert.show()
        } else {
            let message = "Saved successfuly"
            let alert = UIAlertView(title:"", message:message, delegate:nil, cancelButtonTitle:nil, otherButtonTitles:"Ok")
            alert.show()
        }
    }
}


// MARK: - CanvasDelegate
extension CameraController: CanvasDelegate
{
    func brush() -> Brush? {
        return self.paletteView?.currentBrush()
    }
    
    func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, mergedImage image: UIImage?) {
        self.updateToolBarButtonStatus(canvas)
    }
    
    func canvas(_ canvas: Canvas, didSaveDrawing drawing: Drawing, mergedImage image: UIImage?) {
        
        let imgData = UIImageJPEGRepresentation(image!, 0.1)
        let compressImage = UIImage.init(data: imgData!, scale: 1.0)
        
		self.delegate?.didFinishPhoto!(image: compressImage!)
		self.navigationController?.popViewController(animated: true)
    }
}

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

func generateBoundaryString() -> String {
    return "Boundary-\(NSUUID().uuidString)"
}


// MARK: - UIImagePickerControllerDelegate
extension CameraController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
	
	
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let type = info[UIImagePickerControllerMediaType]
        if type as? String != String(kUTTypeImage) {
            return
        }
        
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }

        picker.dismiss(animated: true, completion: { [weak self] in
            let cropper = RSKImageCropViewController(image:selectedImage, cropMode:.square)
            cropper.delegate = self
            self?.canvasView?.update(selectedImage)
            //self?.present(cropper, animated: true, completion: nil)
        })
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
		self.navigationController?.popViewController(animated: true)
    }
}


// MARK: - RSKImageCropViewControllerDelegate
extension CameraController: RSKImageCropViewControllerDelegate
{
	func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
		self.canvasView?.update(croppedImage)
		controller.dismiss(animated: true, completion: nil)
	}
	
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}


// MARK: - UIActionSheetDelegate
extension CameraController: UIActionSheetDelegate
{
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if (actionSheet.cancelButtonIndex == buttonIndex) {
            return
        }
        
        if buttonIndex == 1 {
            self.showPhotoLibrary()
        } else if buttonIndex == 2 {
            self.showCamera()
        }
    }
}


// MARK: - UIAlertViewDelegate
extension CameraController: UIAlertViewDelegate
{
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if (alertView.cancelButtonIndex == buttonIndex) {
            return
        } else {
            self.openSettings()
        }
    }
}


// MARK: - PaletteDelegate
extension CameraController: PaletteDelegate
{
//    func didChangeBrushColor(color: UIColor) {
//
//    }
//
//    func didChangeBrushAlpha(alpha: CGFloat) {
//
//    }
//
//    func didChangeBrushWidth(width: CGFloat) {
//
//    }
    

    // tag can be 1 ... 12
    func colorWithTag(_ tag: NSInteger) -> UIColor? {
        if tag == 4 {
            // if you return clearColor, it will be eraser
            return UIColor.clear
        }
        return nil
    }
    
    // tag can be 1 ... 4
//    func widthWithTag(tag: NSInteger) -> CGFloat {
//        if tag == 1 {
//            return 5.0
//        }
//        return -1
//    }

    // tag can be 1 ... 3
//    func alphaWithTag(tag: NSInteger) -> CGFloat {
//        return -1
//    }
}



