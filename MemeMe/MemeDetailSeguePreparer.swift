//
//  SentMemesCommon.swift
//  MemeMe
//
//  Created by Jason Wedepohl on 2017/09/13.
//
//

import UIKit

class MemeDetailSeguePreparer {
    static let MemeDetailSegueIdentifier = "MemeDetailSegue"
    
    static func prepare(_ segue: UIStoryboardSegue, _ sender: Any?, _ viewController: UIViewController) {
        if segue.identifier == MemeDetailSegueIdentifier {
            guard let memeDetailController = segue.destination as? MemeDetailViewController else {
                print("Expected segue destination to be MemeDetailViewController but was \(String(describing: segue.destination))")
                return
            }
            
            guard let memeIndex = sender as? Int else {
                print("Expected sender to be an int but was \(String(describing: sender))")
                return
            }
            
            memeDetailController.memeIndex = memeIndex
            
            //set back bar title on Meme Detail view to "Sent Memes", not the default "Back"
            let backItem = UIBarButtonItem()
            backItem.title = "Sent Memes"
            viewController.navigationItem.backBarButtonItem = backItem
        }
    }
}
