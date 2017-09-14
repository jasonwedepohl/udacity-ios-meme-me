//
//  SentMemesCollectionViewController.swift
//  MemeMe
//
//  Created by Jason Wedepohl on 2017/07/05.
//

import UIKit

class SentMemesCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

	// MARK: Constants
	
	private struct Constants {
		static let cellIdentifier = "MemeCell"
        static let cellsPerRowInPortrait:CGFloat = 3;
        static let cellsPerRowInLandscape:CGFloat = 5;
        static let cellSpacing:CGFloat = 4;
	}
	
	// MARK: Outlets
	
	@IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var memeCollectionView: UICollectionView!
    @IBOutlet weak var noMemesLabel: UILabel!
	
	// MARK: UIViewController
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let memes = MemeStore.instance.getAll()
        
        memeCollectionView.reloadData()
        memeCollectionView.isHidden = memes.count == 0
        noMemesLabel.isHidden = memes.count != 0
        
        setFlowLayout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        MemeDetailSeguePreparer.prepare(segue, sender, self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        //change flow layout as orientation changes
        coordinator.animate(alongsideTransition: { _ in
            self.setFlowLayout()
        }, completion: nil)
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        //change flow layout after orientation changes
        setFlowLayout()
    }
    
    private func setFlowLayout() {
        if flowLayout == nil {
            /*
                sometimes flowLayout is nil during orientation change
                e.g. if simulator is in landscape mode, app launches in portrait mode then rotates immediately, before the view has been loaded
             */
            return;
        }
        
        /*
            The view frame is not up to date if we changed the orientation in the meme editor then navigated back.
            We have to use UIDevice.current.orientation (which is up to date) to get the width of the view in its current orientation.
        */
        let isPortrait = UIDevice.current.orientation.isPortrait
        let viewWidth = view.frame.width
        let viewHeight = view.frame.height
        let realViewWidth = (isPortrait && viewWidth > viewHeight) || (!isPortrait && viewWidth < viewHeight) ? viewHeight : viewWidth
        
        let itemsPerRow:CGFloat = isPortrait ? Constants.cellsPerRowInPortrait : Constants.cellsPerRowInLandscape
        let numberOfSpaces:CGFloat = 2 * (itemsPerRow - 1)
        let marginSpace:CGFloat = memeCollectionView.layoutMargins.left + memeCollectionView.layoutMargins.right
        let dimension = (realViewWidth - marginSpace - (numberOfSpaces * Constants.cellSpacing)) / itemsPerRow
        
        flowLayout.minimumInteritemSpacing = Constants.cellSpacing
        flowLayout.minimumLineSpacing = Constants.cellSpacing
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
	
	// MARK: UICollectionViewDataSource
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return MemeStore.instance.getAll().count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! MemeCollectionViewCell
		let meme = MemeStore.instance.get(fromIndex: indexPath.row)!
		cell.imageView?.image = meme.memedImage
        
        /*
         for landscape memes, scaleAspectFill produces best results - text is still visible but the whole cell space is used.
         for portrait memes, scaleAspectFill usually hides the text, so scaleAspectFit is better even though it doesn't use the whole cell space.
        */
        cell.imageView?.contentMode = meme.memedImage.size.width > meme.memedImage.size.height ? .scaleAspectFill : .scaleAspectFit
        
		return cell
	}
    
    // MARK: UICollectionViewDelegate
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: MemeDetailSeguePreparer.memeDetailSegueIdentifier, sender: indexPath.row)
	}
}

