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
    @IBOutlet var timeField: UITextField!
    
    private let realm = try! Realm()
    public var completionHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textField.becomeFirstResponder()
        textField.delegate = self
        
        timeField.becomeFirstResponder()
        timeField.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "save", style: .done, target: self, action: #selector(didTapSaveButton))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func didTapSaveButton() {
        if let text = textField.text, !text.isEmpty {
            let time = timeField.text
            
            let taskToAdd = TinyTask()
            taskToAdd.task = text
            taskToAdd.time = time ?? ""
            let tasks : [TinyTask] = [taskToAdd]
            
            realm.beginWrite()
            item?.append(objectsIn: tasks)
            try! realm.commitWrite()
            
            completionHandler?()
            navigationController?.popViewController(animated: true)
        }
        else {
            print("Add something")
        }
    }

}
