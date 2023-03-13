//
//  ViewController.swift
//  Novak03
//
//  Created by Vova on 06.03.2023.
//

import UIKit

class PostTableViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var subLabel: UILabel!
    
    struct Const {
        static let cellReuseIdentifier = "myCustomCell"
        static let goToPost = "goToPost"
    }
    
    private var posts: [RedditPost] = []
    let link = "https://www.reddit.com/r/ios/top.json?limit=10"
    var lastSelectedPost: RedditPost?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.posts = APIData().getDataFromAPI(link: link)
        self.subLabel.text = posts[0].subreddit!
        self.tableView.rowHeight = 110
        self.tableView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Const.goToPost:
            let nextVc = segue.destination as! UIViewCell
            DispatchQueue.main.async {
                nextVc.config(with: self.lastSelectedPost ?? RedditPost())
            }
        default: break
        }
    }
    
}

extension PostTableViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.cellReuseIdentifier, for: indexPath) as! PostTableViewCell
        let num = self.posts[indexPath.row]
        cell.config(with: num)
        return cell
        }
    
}

extension PostTableViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
                self.posts += newPosts
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.lastSelectedPost = self.posts[indexPath.row]
        self.performSegue(withIdentifier: Const.goToPost, sender: nil)
    }
}

