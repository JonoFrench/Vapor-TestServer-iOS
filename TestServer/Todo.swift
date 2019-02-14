//
//  Todo.swift
//  TestServer
//
//  Created by Jonathan French on 08/02/2019.
//  Copyright © 2019 Jaypeeff. All rights reserved.
//

import UIKit

final class Todo: Codable {
    var id: Int?
    var title: String
    
    init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
    }
}
