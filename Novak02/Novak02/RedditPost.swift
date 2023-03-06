//
//  APIResource.swift
//  Novak02
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
    
    init() {}
        
    init(created: Double?, author: String?, domain: String?, title: String?, url_overriden_by_dest: String?, ups: Int?, downs: Int?, num_comments: Int?) {
        self.created = created
        self.author = author
        self.domain = domain
        self.title = title
        self.url_overriden_by_dest = url_overriden_by_dest
        self.ups = ups
        self.downs = downs
        self.num_comments = num_comments
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
    }
    
    func getData(_ completion: @escaping (RedditPost) -> Void) {
        let post = RedditPost()
        guard let url = URL(string: "https://www.reddit.com/r/ios/top.json?limit=1") else {
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
                    let num_comments = childData["num_comments"] as? Int
                    {
                        post.created = created
                        post.author = author
                        post.domain = domain
                        post.title = title
                        post.url_overriden_by_dest = pic
                        post.ups = ups
                        post.downs = downs
                        post.num_comments = num_comments
                        completion(post)

                    } else {
                        return
                    }
                }
            } else { return }

            
        }
        task.resume()
    }
}

