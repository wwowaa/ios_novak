//
//  APIResource.swift
//  Novak03
//
//  Created by Vova on 28.02.2023.
//

import Foundation

class RedditPost: Codable {
    var created: Double?
    var author: String?
    var domain: String?
    var title: String?
    var url_overriden_by_dest: String?
    var ups: Int?
    var downs: Int?
    var num_comments: Int?
    var subreddit: String?
    
    init() {}
        
    init(created: Double?, author: String?, domain: String?, title: String?, url_overriden_by_dest: String?, ups: Int?, downs: Int?, num_comments: Int?, subreddit: String?) {
        self.created = created
        self.author = author
        self.domain = domain
        self.title = title
        self.url_overriden_by_dest = url_overriden_by_dest
        self.ups = ups
        self.downs = downs
        self.num_comments = num_comments
        self.subreddit = subreddit
    }
    
    func copy(this: RedditPost) {
        created = this.created
        author = this.author
        domain = this.domain
        title = this.title
        url_overriden_by_dest = this.url_overriden_by_dest
        ups = this.ups
        downs = this.downs
        num_comments = this.num_comments
        subreddit = this.subreddit
    }
    
    func getData(link: String, _ completion: @escaping (RedditPost) -> Void) {
        let post = RedditPost()
        guard let url = URL(string: link) else {
            fatalError()
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let data = json["data"] as? [String:Any],
                    let children = data["children"] as? [[String:Any]],
                    let firstChild = children.first,
                    let childData = firstChild["data"] as? [String:Any],
                    let author = childData["author"] as? String,
                    let created = childData["created"] as? Double,
                    let domain = childData["domain"] as? String,
                    let title = childData["title"] as? String,
                    let pic = childData["url_overridden_by_dest"] as? String,
                    let ups = childData["ups"] as? Int,
                    let downs = childData["downs"] as? Int,
                    let num_comments = childData["num_comments"] as? Int,
                    let subreddit = childData["subreddit"] as? String
                    {
                        post.created = created
                        post.author = author
                        post.domain = domain
                        post.title = title
                        post.url_overriden_by_dest = pic
                        post.ups = ups
                        post.downs = downs
                        post.num_comments = num_comments
                        post.subreddit = subreddit
                        completion(post)

                    } else {
                        return
                    }
                }
            } else { return }

            
        }
        task.resume()
    }
    
    func countTime() -> String {
        let time = self.created!
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
}
