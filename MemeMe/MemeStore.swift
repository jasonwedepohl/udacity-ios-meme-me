//
//  Utilities.swift
//  MemeMe
//
//  Created by Jason Wedepohl on 2017/09/13.
//
//

import UIKit

class MemeStore {
    
    static let instance = MemeStore()
    
    func getAll() -> [Meme] {
        return getAppDelegate().memes
    }
    
    func get(fromIndex index: Int) -> Meme? {
        guard index < getAppDelegate().memes.count else {
            print("Meme index was out of bounds.")
            return nil
        }
        return getAppDelegate().memes[index]
    }
    
    func add(_ meme: Meme) {
        getAppDelegate().memes.append(meme)
    }
    
    func update(_ meme: Meme, atPosition index: Int) {
        guard index < getAppDelegate().memes.count else {
            print("Meme index was out of bounds.")
            return
        }
        
        getAppDelegate().memes[index] = meme
    }
    
    func remove(fromIndex index: Int) {
        getAppDelegate().memes.remove(at: index)
    }
    
    private func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}
