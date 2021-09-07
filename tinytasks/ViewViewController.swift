//
//  ViewViewController.swift
//  TinyTasks
//
//  Created by Marcus Christerson on 8/4/21.
//

import RealmSwift
import UIKit

class ViewViewController: UIViewController {

    public var item: TinyTasksProject?
    public var deletionHandler: (() -> Void)?
    
    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!

    @IBOutlet var tableView: UITableView!

    private let realm = try! Realm()

    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
 
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
   
        itemLabel.text = item?.item
        descriptionLabel.text = item?.itemDescription
        dateLabel.text = Self.dateFormatter.string(from: item!.date)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTapDelete))
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Enable swipe to delete on table items
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            realm.beginWrite()
            item?.tasks.remove(at: indexPath.item)
            try! realm.commitWrite()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func sumTotalTime() -> Int {
        var sum = 0
        for task in item!.tasks {
            let taskTime = Int(task.time) ?? 0
            sum += taskTime
        }
        return sum
    }
    
    func minutesToHoursAndMinutes (_ minutes : Int) -> (hours : Int , minutes : Int) {
        return (minutes / 60, (minutes % 60))
    }
    
    // User adds a project. Instantiates TaskEntryViewController
    @IBAction func didTapAddButton() {
        guard let vc = storyboard?.instantiateViewController(identifier: "entertask") as? TaskEntryViewController else {
            return
        }
        vc.item = item?.tasks
        
        vc.completionHandler = { [weak self] in
            self?.tableView.reloadData()
        }
        
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.title = "Add Task"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // User deletes proiect from ViewViewController
    @objc func didTapDelete() {
        guard let myItem = self.item else {
            return
        }
        
        realm.beginWrite()
        realm.delete(myItem)
        try! realm.commitWrite()
        
        deletionHandler?()
        navigationController?.popToRootViewController(animated: true)
    }
    
}

extension ViewViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return item!.tasks.count
    }

    // Display tasks and times within table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
    
        // Set to the sum of the tasks times
        let totalTime = minutesToHoursAndMinutes(sumTotalTime())
        if (totalTime.hours != 0) {
            timeLabel?.text = "Total time: " + String(totalTime.hours) + "h " + String(totalTime.minutes) + "m"
        } else {
            timeLabel?.text = "Total time: " + String(totalTime.minutes) + "m"
        }
        
        let item = item?.tasks[indexPath.row]
        let itemTime = item?.time
        
        cell.textLabel?.text = item?.task ?? ""
        if (!itemTime!.isEmpty) {
            cell.detailTextLabel?.text = itemTime! + "m"
        } else {
            cell.detailTextLabel?.text = ""
        }
        return cell
    }
    
}
