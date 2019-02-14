//
//  TodoTableViewController.swift
//  TestServer
//
//  Created by Jonathan French on 13/02/2019.
//  Copyright © 2019 Jaypeeff. All rights reserved.
//

import UIKit

class TodoTableViewController: UITableViewController {
    
    var todos:[Todo] = [] {
        didSet {
            print("Todos set, all \(todos.count) of them")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(TodoTableViewController.addTapped))
        
        let handlerBlock: (httpResponse) -> Void = { success in
            if success.success {
                if let allTodos:[Todo] = success.data as? [Todo] {
                    self.todos = allTodos
                }
            } else {
                print("Error \(success.retCode)")
            }
        }
        HTTPRequests.get(completion:handlerBlock)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        cell.textLabel?.text = todos[indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let todoToDelete = todos[indexPath.row]
            let handlerBlock: (httpResponse) -> Void = { success in
                if success.success {
                    if let index = self.todos.firstIndex(where: { $0 === todoToDelete }) {
                        self.todos.remove(at: index)
                    }
                } else {
                    print("Error \(success.retCode)")
                }
            }
            HTTPRequests.delete(todo: todoToDelete, completion: handlerBlock)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in
            let alert = UIAlertController(title: "", message: "Edit list item", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = self.todos[indexPath.row].title
            })
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (updateAction) in
                
                let handlerBlock: (httpResponse) -> Void = { success in
                    if success.success {
                        if let newTodo:[Todo] = success.data as? [Todo] {
                            if let t = newTodo.first {
                                self.todos[indexPath.row] = t
                                DispatchQueue.main.async {
                                    self.tableView.reloadRows(at: [indexPath], with: .fade)
                                }
                            }
                        }
                    } else {
                        print("Error \(success.retCode)")
                    }
                }
                if let t = alert.textFields?.first?.text {
                    self.todos[indexPath.row].title = t
                    HTTPRequests.create(todo: self.todos[indexPath.row], completion:handlerBlock)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: false)
        })
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            self.todos.remove(at: indexPath.row)
            tableView.reloadData()
        })
        return [deleteAction, editAction]
    }
    
    @objc func addTapped() {
        let alert = UIAlertController(title: "", message: "Add To Do item", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
        })
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (updateAction) in
            let handlerBlock: (httpResponse) -> Void = { success in
                if success.success {
                    if let newTodo:[Todo] = success.data as? [Todo] {
                        if let t = newTodo.first {
                            print("added")
                            self.todos.append(t)
                        }
                    }
                } else {
                    print("Error \(success.retCode)")
                }
            }
            if let t = alert.textFields?.first?.text {
                let newTodo = Todo(title: t)
                HTTPRequests.create(todo: newTodo, completion:handlerBlock)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: false)
    }
    
}
