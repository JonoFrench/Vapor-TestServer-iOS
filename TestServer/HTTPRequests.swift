//
//  HTTPRequests.swift
//  TestServer
//
//  Created by Jonathan French on 11/02/2019.
//  Copyright © 2019 Jaypeeff. All rights reserved.
//

import UIKit

let serverUrl = "http://localhost:8080/todos"

struct httpResponse {
    var success:Bool = false
    var retCode:Int = 0
    var data:[Any]?
}

class HTTPRequests {
    
    static func get(completion: @escaping (httpResponse) -> Void) -> Void {
        let url = URL(string: serverUrl)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            
            guard let data = data,
                let response = response as? HTTPURLResponse,
                (200 ..< 300) ~= response.statusCode,
                error == nil else {
                    completion(httpResponse(success: false, retCode: 0,data: nil))
                    return
            }
            let decoder = JSONDecoder()
            if let allTodos = try? decoder.decode([Todo].self, from: data) {
                completion(httpResponse(success: true, retCode: 0,data: allTodos))
            }
            else {
                completion(httpResponse(success: false, retCode: -1,data: nil))
            }
        })
        task.resume()
    }
    
    static func create(todo:Todo,completion: @escaping (httpResponse) -> Void) -> Void {
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(todo)
        let url = URL(string: serverUrl)!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                (200 ..< 300) ~= response.statusCode,
                error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    completion(httpResponse(success: false, retCode: 0,data: nil))
                    return
            }
            let decoder = JSONDecoder()
            if let newTodo = try? decoder.decode(Todo.self, from: data) {
                completion(httpResponse(success: true, retCode: 0,data: [newTodo]))
            }
            else {
                completion(httpResponse(success: false, retCode: -1,data: nil))
            }
        }
        task.resume()
    }
    
    static func delete(todo:Todo,completion: @escaping (httpResponse) -> Void) -> Void {
        let url:URLComponents = URLComponents(string: "\(serverUrl)/\(todo.id!)")!
        var request = URLRequest(url: url.url!)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse,
                (200 ..< 300) ~= response.statusCode,
                error == nil else {
                    completion(httpResponse(success: false, retCode: 0,data: nil))
                    return
            }
            completion(httpResponse(success: true, retCode: 0,data: nil))
        }
        task.resume()
    }
    
}
