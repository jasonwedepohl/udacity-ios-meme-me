//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Jason Wedepohl on 2017/09/11.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
    //MARK: Constants
    
    let memeEditorSegueIdentifier = "MemeEditorSegue"
    
    //MARK: Properties
    
    var memeIndex: Int!
    
    //MARK: Outlets
    
    @IBOutlet var imageView: UIImageView!
    
    //MARK: Actions
    
    @IBAction func edit(_ sender: Any) {
        performSegue(withIdentifier: memeEditorSegueIdentifier, sender: nil)
    }
    
    //MARK: UIViewController overrides
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView.image = MemeStore.instance.get(fromIndex: memeIndex)?.memedImage
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == memeEditorSegueIdentifier {
            guard let editorNavController = segue.destination as? UINavigationController else {
                print("Expected segue destination to be UINavigationController but was \(String(describing: segue.destination))")
                return
            }
            
            guard let editorController = editorNavController.viewControllers[0] as? MemeEditorViewController else {
                print("Expected segue destination subview to be MemeEditorViewController but was \(String(describing: segue.destination))")
                return
            }
            
            editorController.editingMemeIndex = memeIndex
        }
    }
}
