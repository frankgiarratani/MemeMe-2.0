//
//  MemeEditorViewController.swift
//  MemeMe 1.0
//
//  Created by Frank Giarratani on 2016/12/27.
//  Copyright © 2016 Frank Giarratani. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName : UIColor.white,
        NSBackgroundColorAttributeName : UIColor.clear,
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : NSNumber(value: -3.0)
    ]
    

    @IBAction func shareButtonPushed(_ sender: UIBarButtonItem) {
        //print("Share Button Pressed")
        
        //generate a memed image
        let memedImage = generateMemedImage()
        //print("Memed Image Generated")
        
        //define an instance of the ActivityViewController
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        //pass the ActivityViewController a memedImage as an activity item
        activityViewController.completionWithItemsHandler = {
            (activity, success, items, error) in
            
            if success{
                self.save(memedImage: memedImage) // calling save
                self.dismiss(animated: true, completion: nil) // dismissing view
            }
        }
        //print("AVC passed a memedImage")
        
        //present the ActivityViewController
        present(activityViewController, animated: true, completion: nil)
        
        
    }
    
    func save(memedImage: UIImage) {
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage {
        
        bottomToolbar.isHidden = true
        topToolbar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        
        bottomToolbar.isHidden = false
        topToolbar.isHidden = false
        
        return memedImage
    }
    
    
    // START - KEYBOARD ADJUSTMENT -----------
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification:Notification) {
        if bottomText.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // FINISH - KEYBOARD ADJUSTMENT -----------
    
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        shareButton.isEnabled = imagePickerView.image != nil
        tabBarController?.hidesBottomBarWhenPushed = true
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topText.defaultTextAttributes = memeTextAttributes
        topText.borderStyle = UITextBorderStyle.none
        topText.text = "TOP"
        topText.textAlignment = .center
        topText.delegate = self
        
        bottomText.defaultTextAttributes = memeTextAttributes
        bottomText.borderStyle = UITextBorderStyle.none
        bottomText.text = "BOTTOM"
        bottomText.textAlignment = .center
        bottomText.delegate = self
        
        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    @IBAction func pickAnImage(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        //print(">>>>>>Picker Launched")
        
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        //print(">>>>>>Cancelled")
    }
    
    
    
    //reference: https://discussions.udacity.com/t/image-not-showing-in-uiimageview/171554/20
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage]
        
        if ((image as? UIImage) != nil) {
            imagePickerView.image = image as! UIImage?
            self.dismiss(animated: true, completion: nil)
        }
        //print(">>>>>>Picked")
    }
    
}

