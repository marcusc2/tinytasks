//
//  ViewController.swift
//  TinyTasks
//
//  Created by Marcus Christerson on 8/4/21.
//

import RealmSwift
import UIKit

class TinyTasksProject: Object {
    @objc dynamic var item: String = ""
    @objc dynamic var itemDescription: String = ""
    @objc dynamic var date: Date = Date()
    var tasks = List<TinyTask>()
}

class TinyTask: Object {
    @objc dynamic var task: String = ""
    @objc dynamic var time: String = ""
}

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    private let realm = try! Realm()
    private var data = [TinyTasksProject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        data = realm.objects(TinyTasksProject.self).map({ $0 })
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // Enable swipe to delete on table items
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            let item = data[indexPath.item]
            
            realm.beginWrite()
            data.remove(at: indexPath.item)
            realm.delete(item)
            
            try! realm.commitWrite()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Projects"
    }

    // User adds a project. Instantiates EntryViewController
    @IBAction func didTapAddButton() {
        guard let vc = storyboard?.instantiateViewController(identifier: "enter") as? EntryViewController else {
            return
        }
        vc.completionHandler = { [weak self] in
            self?.refresh()
        }
        vc.title = "New Project"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

    func refresh() {
        data = realm.objects(TinyTasksProject.self).map({ $0 })
        tableView.reloadData()
    }

}

extension ViewController: UITableViewDelegate {
    
    // User selects a project to view. Instanties ViewViewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = data[indexPath.row]

        guard let vc = storyboard?.instantiateViewController(identifier: "view") as? ViewViewController else {
            return
        }

        vc.item = item
        vc.deletionHandler = { [weak self] in
            self?.refresh()
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.title = item.item
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    // Display project names within table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row].item
        return cell
    }
    
}

