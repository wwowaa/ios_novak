//
//  UIViewController.swift
//  Novak03
//
//  Created by Vova on 26.02.2023.
//

import UIKit

class UIViewCell:
    UIViewController {
    
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var ratingButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    
    var isSaved = false
    
    func config(with post: RedditPost) {
        prepareScreen(data: post)
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
    
    func prepareScreen(data: RedditPost) {
        
        if let author = data.author, let created = data.created, let domain = data.domain, let title = data.title, let ups = data.ups, let downs = data.downs, let numComments = data.num_comments {
            guard let label = self.infoLabel else {
                return
            }
            label.text = author + " • " + data.countTime() + " • " + domain

            self.titleLabel.text = title
            ratingButton.setTitle("⬆️ " + String(ups + downs), for: .normal)
            commentButton.setTitle("💬 " + String(numComments), for: .normal)
            if let urlimg = data.url_overriden_by_dest {
                if let url = URL(string: urlimg) {
                    let task = URLSession.shared.dataTask(with: url) { data, response, error in
                        guard let data = data, error == nil else { return }
                        DispatchQueue.main.async {
                            self.imageView.image = UIImage(data: data)
                        }
                    }
                    task.resume()
                }
            }
        }
    }
    
    @IBAction func onClick(_ sender: Any) {
        if isSaved {
            saveButton.setTitle("♡", for: .normal)
            isSaved = false
        } else {
            saveButton.setTitle("♥", for: .normal)
            isSaved = true
        }
    }
    
}
