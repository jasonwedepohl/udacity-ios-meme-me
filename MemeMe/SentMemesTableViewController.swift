//
//  SetMemesTableViewController.swift
//  MemeMe
//
//  Created by Jason Wedepohl on 2017/07/05.
//

import UIKit

class SentMemesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	// MARK: Constants
	
	private struct Constants {
		static let cellIdentifier = "MemeCell"
        static let cellImageTag = 30;
        static let cellTopTextTag = 31;
        static let cellBottomTextTag = 32;
        static let rowHeight = 120.0;
	}
	
    // MARK: Outlets
    
    @IBOutlet var memeTableView: UITableView!
    @IBOutlet var noMemesLabel: UILabel!
    
	// MARK: UIViewController
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //refresh meme table
        let memes = MemeStore.instance.getAll()
        memeTableView.reloadData()
        memeTableView.isHidden = memes.count == 0
        noMemesLabel.isHidden = memes.count != 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        MemeDetailSeguePreparer.prepare(segue, sender, self)
    }
	
	// MARK: UITableViewDataSource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return MemeStore.instance.getAll().count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath)
		let meme = MemeStore.instance.get(fromIndex: indexPath.row)
        
        let imageView = cell.viewWithTag(Constants.cellImageTag) as! UIImageView
        let topText = cell.viewWithTag(Constants.cellTopTextTag) as!UILabel
        let bottomText = cell.viewWithTag(Constants.cellBottomTextTag) as! UILabel
        
        imageView.image = meme?.memedImage
        topText.text = meme?.top
        bottomText.text = meme?.bottom
		return cell
	}
    
    //allow deletion
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    //handle deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            MemeStore.instance.remove(fromIndex: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
	
	// MARK: UITableViewDelegate
    
    //set row height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(Constants.rowHeight)
    }
	
    //go to meme detail view on row tap
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: MemeDetailSeguePreparer.memeDetailSegueIdentifier, sender: indexPath.row)
	}
}
