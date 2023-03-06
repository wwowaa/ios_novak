//
//  ViewController.swift
//  Novak02
//
//  Created by Vova on 26.02.2023.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var ratingButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    var isSaved = false
    
    override func viewDidLoad() {
        
        prepareScreen()
        super.viewDidLoad()
    }
    
    func countTime(_ time: Double) -> String {
        let nowTime = Date()
        let years = Calendar.current.dateComponents([.year], from: Date(timeIntervalSince1970: time), to: nowTime).year
        if years != nil && years! > 0 {
            return String(years!) + "y"
        } else {
            let months = Calendar.current.dateComponents([.month], from: Date(timeIntervalSince1970: time), to: nowTime).month
            if months != nil && months! > 0 {
                return String(months!) + "m"
            } else {
                let days = Calendar.current.dateComponents([.day], from: Date(timeIntervalSince1970: time), to: nowTime).day
                if days != nil && days! > 0 {
                    return String(days!) + "d"
                } else {
                    let hours = Calendar.current.dateComponents([.hour], from: Date(timeIntervalSince1970: time), to: nowTime).hour
                    if hours != nil && hours! > 0 {
                        return String(hours!) + "h"
                    } else {
                        let minutes = Calendar.current.dateComponents([.minute], from: Date(timeIntervalSince1970: time), to: nowTime).minute
                        if minutes != nil && minutes! > 0 {
                            return String(minutes!) + "m"
                        } else {
                            let seconds = Calendar.current.dateComponents([.second], from: Date(timeIntervalSince1970: time), to: nowTime).second
                            return String(seconds!) + "s"
                        }
                    }
                }
            }
        }
    }
    
    func prepareScreen() {
        var data = RedditPost()
        let semaphore = DispatchSemaphore(value: 0)
        data.getData { result in
            data.copy(this: result)
            semaphore.signal()
        }
        semaphore.wait()
        
        if data.author != nil {
            self.infoLabel.text = data.author! + " • " + countTime(data.created!) + " • " + data.domain!
            self.titleLabel.text = data.title!
            ratingButton.setTitle("⬆️ " + String(data.ups! + data.downs!), for: .normal)
            commentButton.setTitle("💬 " + String(data.num_comments!), for: .normal)
            let urlimg = data.url_overriden_by_dest!
                if let url = URL(string: urlimg) {
                    let task = URLSession.shared.dataTask(with: url) { data, response, error in
                        guard let data = data, error == nil else { return }
                        DispatchQueue.main.async {
                            self.imageView.image = UIImage(data: data)
                        }
                    }
                    task.resume()
                }
        } else {
        }
    }
    
    
    @IBAction func clickOnSaveButton(_ sender: Any) {
        if isSaved {
            saveButton.setTitle("♡", for: .normal)
            isSaved = false
        } else {
            saveButton.setTitle("♥", for: .normal)
            isSaved = true
        }
    }
}
