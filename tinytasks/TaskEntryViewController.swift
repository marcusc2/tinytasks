//
//  TaskEntryViewController.swift
//  TinyTasks
//
//  Created by Marcus Christerson on 8/28/21.
//

import RealmSwift
import UIKit

class TaskEntryViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var textField: UITextField!
    @IBOutlet var addDescription: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    
    private let realm = try! Realm()
    public var completionHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textField.becomeFirstResponder()
        textField.delegate = self
        
        addDescription.becomeFirstResponder()
        addDescription.delegate = self
        
        datePicker.setDate(Date(), animated: true)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "save", style: .done, target: self, action: #selector(didTapSaveButton))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func didTapSaveButton() {
        if let text = textField.text, !text.isEmpty {
            let description = addDescription.text
            let date = datePicker.date
            
            realm.beginWrite()
            
            let newItem = TinyTasksProject()
            newItem.date = date
            newItem.name = text
            newItem.userDescription = description ?? ""
            realm.add(newItem)
            try! realm.commitWrite()
            
            completionHandler?()
            navigationController?.popToRootViewController(animated: true)
        }
        else {
            print("Add something")
        }
    }
    

}
