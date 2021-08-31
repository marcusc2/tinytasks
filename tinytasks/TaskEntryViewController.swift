//
//  TaskEntryViewController.swift
//  tinytasks
//
//  Created by Marcus Christerson on 8/31/21.
//

import RealmSwift
import UIKit

class TaskEntryViewController: UIViewController, UITextFieldDelegate {
    
    public var item: List<TinyTask>?
    
    @IBOutlet var textField: UITextField!
    
    private let realm = try! Realm()
    public var completionHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textField.becomeFirstResponder()
        textField.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "save", style: .done, target: self, action: #selector(didTapSaveButton))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func didTapSaveButton() {
        if let text = textField.text, !text.isEmpty {
            
            let taskToAdd = TinyTask()
            taskToAdd.task = text
            let tasks : [TinyTask] = [taskToAdd]
//
            realm.beginWrite()
//
//            let newItem = TinyTasksItem()
//            newItem.date = date
            item?.append(objectsIn: tasks)
//            newItem.item = text
//            realm.add(newItem)
            try! realm.commitWrite()
            
            completionHandler?()
            navigationController?.popToRootViewController(animated: true)
        }
        else {
            print("Add something")
        }
    }

}
