//
//  UIViewController.swift
//  Novak05
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
    
    private var my_post: RedditPost = RedditPost()
    
    
    var isSaved = false
    
    func config(with post: RedditPost) {
        self.my_post = post
        prepareScreen(data: post)
        let myGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        myGesture.numberOfTapsRequired = 2
        self.imageView.addGestureRecognizer(myGesture)
        self.imageView.isUserInteractionEnabled = true
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
            if SavedPosts().findPost(post: data) {
                saveButton.setTitle("♥", for: .normal)
            } else {
                saveButton.setTitle("♡", for: .normal)
            }
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
            SavedPosts().deletePost(post: self.my_post)
        } else {
            saveButton.setTitle("♥", for: .normal)
            isSaved = true
            SavedPosts().addPost(post: self.my_post)
        }
    }
    
    @IBAction func onClickShareButton(_ sender: Any) {
        let items = [URL(string: self.my_post.url!)!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    @objc private func imageViewTapped() {
        drawBookmark()
        if !isSaved {
            saveButton.setTitle("♥", for: .normal)
            isSaved = true
            SavedPosts().addPost(post: self.my_post)
        }
    }
    
    private func drawBookmark() {
        let frame = self.view.frame
        let size: CGFloat = 50
        
        let path = UIBezierPath()
        path.move(to: CGPoint(
                    x: frame.midX - size / 2,
                    y: frame.midY - size))
        path.addLine(to: CGPoint(
                        x: frame.midX + size / 2,
                        y: frame.midY - size))
        path.addLine(to: CGPoint(
                        x: frame.midX + size / 2,
                        y: frame.midY + size))
        path.addLine(to: CGPoint(
                        x: frame.midX,
                        y: frame.midY + size / 3 * 2))
        path.addLine(to: CGPoint(
                        x: frame.midX - size / 2,
                        y: frame.midY + size))
        path.addLine(to: CGPoint(
                        x: frame.midX - size / 2,
                        y: frame.midY - size))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.systemBlue.cgColor
        shapeLayer.strokeColor = UIColor.systemBlue.cgColor
        shapeLayer.lineWidth = 5
        view.layer.addSublayer(shapeLayer)
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            UIView.transition(
                with: self.view,
                duration: 1,
                options: .transitionCrossDissolve
            ) {
                shapeLayer.isHidden = true
            }
        
        }
    }
    
}
