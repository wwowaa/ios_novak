//
//  APIData.swift
//  Novak04
//
//  Created by Vova on 10.03.2023.
//

import Foundation

class APIData {
    
    func getData(link: String, _ completion: @escaping ([RedditPost]) -> Void) {
        var posts: [RedditPost] = []
        guard let url = URL(string: link) else {
            fatalError()
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let data = json["data"] as? [String:Any],
                    let children = data["children"] as? [[String:Any]],
                    children.count > 0
                    {
                        for child in children {
                            if let childData = child["data"] as? [String:Any],
                               let author = childData["author"] as? String,
                               let created = childData["created"] as? Double,
                               let domain = childData["domain"] as? String,
                               let title = childData["title"] as? String,
                               let ups = childData["ups"] as? Int,
                               let downs = childData["downs"] as? Int,
                               let num_comments = childData["num_comments"] as? Int,
                               let subreddit = childData["subreddit"] as? String,
                               let idpost = childData["id"] as? String {
                                let post = RedditPost()
                                post.created = created
                                post.author = author
                                post.domain = domain
                                post.title = title
                                if let pic = childData["url_overridden_by_dest"] as? String {
                                post.url_overriden_by_dest = pic
                                }
                                post.ups = ups
                                post.downs = downs
                                post.num_comments = num_comments
                                post.subreddit = subreddit
                                post.url = "https://www.reddit.com/r/" + post.subreddit! + "/comments/" + idpost + "/"
                                posts.append(post)
                            }
                        }
                        completion(posts)
                    } else {
                        return
                    }
                }
            } else { return }

            
        }
        task.resume()
    }
    
    func getAfter(link: String, _ completion: @escaping (String) -> Void) {
        guard let url = URL(string: link) else {
            fatalError()
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let data = json["data"] as? [String:Any],
                    let after = data["after"] as? String
                    {
                        completion(after)
                    } else {
                        return
                    }
                }
            } else { return }

            
        }
        task.resume()
    }
    
    func getDataFromAPI(link: String) -> [RedditPost] {
        let semaphore = DispatchSemaphore(value: 0)
        var data: [RedditPost] = []
        APIData().getData(link: link, {result in
            data = result
            semaphore.signal()
        })
        semaphore.wait()
        return data
    }
}
