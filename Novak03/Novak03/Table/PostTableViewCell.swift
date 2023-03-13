//
//  PostTableViewCell.swift
//  Novak03
//
//  Created by Vova on 06.03.2023.
//

import Foundation
import SwiftUI

final class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func config(with data: RedditPost) {
        self.titleLabel.numberOfLines = 0
        
        if let author = data.author, let _ = data.created, let domain = data.domain, let title = data.title, let ups = data.ups, let downs = data.downs, let numComments = data.num_comments, let subreddit = data.subreddit {
            guard let label = self.infoLabel else {
                return
            }
            label.text = author + " • " + data.countTime() + " • " + domain

            self.titleLabel.text = title
            ratingButton.setTitle(String(ups + downs), for: .normal)
            commentButton.setTitle(String(numComments), for: .normal)
        }
    }
}
