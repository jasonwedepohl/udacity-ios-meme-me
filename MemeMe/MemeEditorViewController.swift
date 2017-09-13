//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Jason Wedepohl on 2017/07/05.
//

import UIKit

class MemeEditorViewController: UIViewController {
	
	// MARK: Constants
	
	struct Constants {
		static let DefaultTopText = "TOP"
		static let DefaultBottomText = "BOTTOM"
		static let TagTopText = 0
		static let TagBottomText = 1
		static let MemeTextAttributes:[String:Any] = [
			NSStrokeColorAttributeName: UIColor.black,
			NSForegroundColorAttributeName: UIColor.white,
			NSFontAttributeName: UIFont(name: "Impact", size: getTextFontSize())!,
			NSStrokeWidthAttributeName: -3.0]
        
        private static func getTextFontSize() -> CGFloat {
            //using a base of size 40 on a screen of height 667 (iphone 6), set text size for any screen size
            let baseFontSize: CGFloat = 40
            let baseScreenHeight: CGFloat = 667
            
            let currentScreenHeight = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
            let scaleFactor = currentScreenHeight / baseScreenHeight
            
            return baseFontSize * scaleFactor
        }
	}
	
	// MARK: Properties
	
    var editingMemeIndex:Int?
	
	// MARK: Outlets
	
	@IBOutlet var imageView:UIImageView!
	@IBOutlet var topField:UITextField!
	@IBOutlet var bottomField:UITextField!
	@IBOutlet var shareButton:UIBarButtonItem!
    @IBOutlet var cancelButton:UIBarButtonItem!
	@IBOutlet var cameraButton:UIBarButtonItem!
	@IBOutlet var galleryButton:UIBarButtonItem!
    @IBOutlet var toolbar: UIToolbar!
	
	// MARK: Actions
	
	@IBAction func pickAnImageFromAlbum(_ sender: Any) {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.sourceType = .photoLibrary
		present(imagePicker, animated: true, completion: nil)
	}
	
	@IBAction func pickAnImageFromCamera(_ sender: Any) {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.sourceType = .camera
		present(imagePicker, animated: true, completion: nil)
	}
    
    @IBAction func share(_ sender: Any) {
        shareMeme(sender)
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
	
	// MARK: UIViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if editingMemeIndex == nil {
            //we are adding a new meme (+ was tapped from sent memes view)
            
            topField.text = Constants.DefaultTopText
            bottomField.text = Constants.DefaultBottomText
            shareButton.isEnabled = false
        } else {
            //we are reusing an existing meme (edit was tapped from meme detail view)
            
            let meme = MemeStore.instance.get(fromIndex: editingMemeIndex!)
            topField.text = meme?.top
            bottomField.text = meme?.bottom
            imageView.image = meme?.image
            shareButton.isEnabled = true
            
            /*
                the camera/gallery toolbar does not display correctly if the imageView image is set in viewDidLoad
                no online solution after much searching >:-/
                so when reusing a meme, app hides toolbar so user can change the text but not the image
             */
            toolbar.isHidden = true
        }
        
        configureTextField(topField, withTag: Constants.TagTopText)
        configureTextField(bottomField, withTag: Constants.TagBottomText)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        
        //sometimes camera is unavailable, e.g. in simulator
		cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
		subscribeToKeyboardNotifications()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		unsubscribeFromKeyboardNotifications()
	}
	
	private func configureTextField(_ textField: UITextField, withTag tag: Int) {
		textField.delegate = self
		textField.tag = tag
		textField.defaultTextAttributes = Constants.MemeTextAttributes
        textField.textAlignment = .center
        textField.autocapitalizationType = .allCharacters
	}
}

//MARK: Meme generation extension

extension MemeEditorViewController
{
    func shareMeme(_ sender: Any) {
		let memedImage = generateMemedImage()
        
		let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        //Activity VC crashes on iPad without this line! It should not be necessary, but it works.
        controller.popoverPresentationController?.barButtonItem = (sender as! UIBarButtonItem)
        
		controller.completionWithItemsHandler = { activity, completed, items, error in
            if !completed {
                //user cancelled out of activity controller
                return
            }
            
            //create meme
            let meme = Meme(top: self.topField.text!,
                            bottom: self.bottomField.text!,
                            image: self.imageView.image!,
                            memedImage: memedImage)
            
            //save meme to global array
            if self.editingMemeIndex == nil {
                MemeStore.instance.add(meme)
            } else {
                MemeStore.instance.update(meme, atPosition: self.editingMemeIndex!)
            }
            
            //return to sent memes
            self.dismiss(animated: true, completion: nil)
		}
        
		self.present(controller, animated: true, completion: nil)
	}
	
	private func generateMemedImage() -> UIImage {
		
		//hide toolbar and navbar
        navigationController?.setNavigationBarHidden(true, animated: false)
        toolbar.isHidden = true
        
        //temporarily adjust image and bottom text field frames to fill toolbar area
        let tempImageViewFrame = imageView.frame
        let tempBottomFieldFrame = bottomField.frame
        imageView.frame = view.frame
        bottomField.frame = CGRect(x: bottomField.frame.origin.x,
                                   y: view.frame.origin.y + view.frame.size.height - bottomField.frame.size.height - 48,
                                   width: bottomField.frame.size.width,
                                   height: bottomField.frame.size.height)
		
		//render view to memedImage
		UIGraphicsBeginImageContext(view.frame.size)
		view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
		let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		//show toolbar and navbar
        navigationController?.setNavigationBarHidden(false, animated: false)
        toolbar.isHidden = editingMemeIndex != nil //don't show toolbar if editing, see viewDidLoad() for explanation
        
        //reset image and bottom text field frames
        imageView.frame = tempImageViewFrame
        bottomField.frame = tempBottomFieldFrame
        view.setNeedsLayout()
		
		return memedImage
	}
}

//MARK: UIImagePickerControllerDelegate extension

extension MemeEditorViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //user picked an image, so show it and allow them to share meme
			imageView.image = image
            shareButton.isEnabled = true
		}
		picker.dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}

//MARK: UITextFieldDelegate extension

extension MemeEditorViewController : UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //wipe text if it is the default "TOP" or "BOTTOM" text
        
		if (textField.text! == Constants.DefaultTopText && textField.tag == Constants.TagTopText) ||
            (textField.text! == Constants.DefaultBottomText && textField.tag == Constants.TagBottomText) {
			textField.text = ""
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //if text field is empty, replace it with default top/bottom text so user has something visible to tap on
        
		if textField.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
			textField.text = textField.tag == Constants.TagTopText ? Constants.DefaultTopText : Constants.DefaultBottomText
		}
		textField.resignFirstResponder()
		return true
	}
}

//MARK: Keyboard show/hide extension
//required to scroll view so bottom text field isn't hidden by keyboard

extension MemeEditorViewController
{
	func subscribeToKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
	}
	
	func unsubscribeFromKeyboardNotifications() {
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
	}
	
	func keyboardWillShow(_ notification:Notification) {
		
		//only scroll down if we are editing the bottom text
		if topField.isEditing {
			return
		}
		view.frame.origin.y -= getKeyboardHeight(notification)
	}
	
	func keyboardWillHide(_ notification:Notification) {
		view.frame.origin.y = 0
	}
	
	func getKeyboardHeight(_ notification:Notification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
		return keyboardSize.cgRectValue.height
	}
}
