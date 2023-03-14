//
//  SavedPosts.swift
//  Novak04
//
//  Created by Vova on 14.03.2023.
//

import Foundation
import SwiftUI

class SavedPosts {
    
    var posts: [RedditPost] = []
    
    func addPost(post: RedditPost) {
        self.posts = []
        readFile()
        posts.append(post)
        writeFile()
    }
    
    func findPost(post: RedditPost) -> Bool {
        self.posts = []
        readFile()
        for post_i in posts {
            if post_i.url == post.url {
                return true
            }
        }
        return false
    }
    
    func deletePost(post: RedditPost) {
        self.posts = []
        readFile()
        var new_posts: [RedditPost] = []
        for post_i in posts {
            if post_i.url != post.url {
                new_posts.append(post_i)
            }
        }
        posts = new_posts
        writeFile()
    }
    
    func getSavedPosts() -> [RedditPost] {
        self.posts = []
        readFile()
        return self.posts
    }
    
    private func writeFile() {
        let fileName = "posts.json"
        do {
            let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentsURL.appendingPathComponent(fileName)
            let jsonData = try? JSONSerialization.data(withJSONObject: ["posts": postsToDict()], options: .prettyPrinted)
            if let jsonData = jsonData {
                let jsonString = String(data: jsonData, encoding: .utf8)
                try jsonString?.write(to: fileURL, atomically: true, encoding: .utf8)
            }
        } catch {
            print("Error saving file: \(error)")
        }
    }
    
    private func readFile() {
        let fileName = "posts.json"
        do {
            let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentsURL.appendingPathComponent(fileName)
            let data = try Data(contentsOf: fileURL)
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let posts_json = json["posts"] as? [[String:Any]]
                {
                    for post_json in posts_json {
                        if let author = post_json["author"] as? String,
                           let created = post_json["created"] as? Double,
                           let domain = post_json["domain"] as? String,
                           let title = post_json["title"] as? String,
                           let ups = post_json["ups"] as? Int,
                           let downs = post_json["downs"] as? Int,
                           let num_comments = post_json["num_comments"] as? Int,
                           let subreddit = post_json["subreddit"] as? String,
                           let url = post_json["url"] as? String {
                            let post = RedditPost()
                            post.created = created
                            post.author = author
                            post.domain = domain
                            post.title = title
                            if let pic = post_json["url_overridden_by_dest"] as? String {
                                post.url_overriden_by_dest = pic
                            }
                            post.ups = ups
                            post.downs = downs
                            post.num_comments = num_comments
                            post.subreddit = subreddit
                            post.url = url
                            self.posts.append(post)
                        }
                    }
                }
            }
        } catch {
            print("Error reading file: \(error)")
        }
    }
    
    private func postsToDict() -> [[String:Any]] {
        var dicts: [[String: Any]] = []
        for post in self.posts {
            var dict: [String: Any] = [:]
            dict["author"] = post.author!
            dict["domain"] = post.domain!
            dict["title"] = post.title!
            dict["created"] = post.created!
            dict["ups"] = post.ups!
            dict["downs"] = post.downs!
            dict["num_comments"] = post.num_comments!
            dict["subreddit"] = post.subreddit!
            dict["url"] = post.url!
            if let pic = post.url_overriden_by_dest as? String {
                dict["url_overridden_by_dest"] = pic
            }
            dicts.append(dict)
        }
        return dicts
    }
}
