//
//  ViewController.swift
//  Novak04
//
//  Created by Vova on 06.03.2023.
//

import UIKit

class PostTableViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var savedButton: UIButton!
    @IBOutlet weak var myTextField: UITextField!
    
    struct Const {
        static let cellReuseIdentifier = "myCustomCell"
        static let goToPost = "goToPost"
    }
    
    private var saved = false
    private var saved_posts: [RedditPost] = []
    private var posts: [RedditPost] = []
    let link = "https://www.reddit.com/r/ios/top.json?limit=10"
    var lastSelectedPost: RedditPost?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.posts = APIData().getDataFromAPI(link: link)
        self.saved_posts = SavedPosts().getSavedPosts()
        self.subLabel.text = "r/ios"
        self.tableView.rowHeight = 110
        myTextField.isHidden = true
        self.tableView.delegate = self
        self.myTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Const.goToPost:
            let nextVc = segue.destination as! UIViewCell
            DispatchQueue.main.async {
                if let lastSelectedPost = self.lastSelectedPost {
                    nextVc.config(with: lastSelectedPost)
                } else {
                    nextVc.config(with: RedditPost())
                }
            }
        default: break
        }
    }
    
    @IBAction func isClickedSaved(_ sender: Any) {
        if !saved {
            saved = true
            savedButton.isSelected = true
            myTextField.isHidden = false
            self.saved_posts = SavedPosts().getSavedPosts()
            self.subLabel.text = "Saved Posts"
            tableView.reloadData()
        } else {
            saved = false
            savedButton.isSelected = false
            myTextField.isHidden = true
            self.posts = APIData().getDataFromAPI(link: link)
            self.subLabel.text = "r/ios"
            tableView.reloadData()
        }
    }
    
    
}

extension PostTableViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if saved {
            return self.saved_posts.count
        } else {
            return self.posts.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.cellReuseIdentifier, for: indexPath) as! PostTableViewCell
        var num: RedditPost
        if saved {
            num = self.saved_posts[indexPath.row]
        } else {
            num = self.posts[indexPath.row]
        }
        cell.config(with: num)
        return cell
        }
    
}

extension PostTableViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !saved {
            DispatchQueue.global(qos: .userInitiated).async {
                let semaphore = DispatchSemaphore(value: 0)
                var after: String = ""
                let changeLink = self.link.replacingOccurrences(of: "10", with: String(self.posts.count))
                APIData().getAfter(link: changeLink, {result in
                    after = result
                    semaphore.signal()
                })
                semaphore.wait()
                let newPosts = APIData().getDataFromAPI(link: (self.link + "&after=" + after))
                DispatchQueue.main.async {
                    if !newPosts.isEmpty {
                        self.posts += newPosts
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !saved {
            self.lastSelectedPost = self.posts[indexPath.row]
        } else {
            self.lastSelectedPost = self.saved_posts[indexPath.row]
        }
        self.performSegue(withIdentifier: Const.goToPost, sender: nil)
    }
}

extension PostTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let nonfiltered_posts = saved_posts
        let searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if searchText == "" {
            saved_posts = nonfiltered_posts
        } else {
            saved_posts = nonfiltered_posts.filter( {
                if let title0 = $0.title {
                    return title0.lowercased().contains(searchText.lowercased())
                }
                else {
                    return false
                }
            })
        }
        tableView.reloadData()
        saved_posts = nonfiltered_posts
        return true
    }
}

