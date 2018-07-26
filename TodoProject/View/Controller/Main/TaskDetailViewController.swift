//
//  JobDetailViewController.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/13/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {

    //MARK: Property
    
    @IBOutlet weak var rowDoneView: UIView!
    @IBOutlet weak var tableView: UITableView!
    private var itemTitlesTable = [String]()
    private var cellIdentifies = [NameCell.className, DateTimeCell.className, DescriptionCell.className]
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.url(forResource: "TaskProperties", withExtension: "plist") {
            if let data = try? Data(contentsOf: path),
                let array = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String] {
                itemTitlesTable = array ?? []
            }
        }
        prepareUI()
        prepareTableView()
        prepareNavigationBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
}

//MARK: Prepare UI

extension TaskDetailViewController {
    
    private func prepareUI() {
        let shadowPath = UIBezierPath(rect: rowDoneView.bounds)
        rowDoneView.layer.shadowOffset = CGSize(width: 0.2, height: 0.2)
        rowDoneView.layer.shadowColor = UIColor.black.cgColor
        rowDoneView.layer.shadowOpacity = 0.1
        
        rowDoneView.layer.shadowPath = shadowPath.cgPath
        rowDoneView.clipsToBounds = true
        rowDoneView.layer.masksToBounds = false
        rowDoneView.layer.cornerRadius = 8
    }
    
    private func prepareTableView() {
        tableView.register(NameCell.nib, forCellReuseIdentifier: NameCell.className)
        tableView.register(DateTimeCell.nib, forCellReuseIdentifier: DateTimeCell.className)
        tableView.register(DescriptionCell.nib, forCellReuseIdentifier: DescriptionCell.className)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func prepareNavigationBar() {
        title = "Task detail"
    }
}

//MARK: Actions

extension TaskDetailViewController {
    
    @objc
    private func handelDoneAction() {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: TableView delegate

extension TaskDetailViewController: UITableViewDelegate {
    
}

//MARK: TableView Datasouce

extension TaskDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemTitlesTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifies[indexPath.row]) as? BaseTableViewCell {
            (cell as? DateTimeCell)?.delegate = self
            cell.configTitle(title: itemTitlesTable[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
}

//MARK: DateTimeCellDelegate

extension TaskDetailViewController: DateTimeCellDelegate {
    
    func dateTimeCell(didSelectTimeButton button: ValueButton) {
        DatePickerView.show(
            type        : .time,
            title       : "Time",
            doneHandler : { (picker, date) in
                
                button.valueLabel.text = date.dateToString(format: DateFormatter.hh_mm_aa)
            }) { (picker) in
                button.valueLabel.text = nil
            }
    }
    
    func dateTimeCell(didSelectDateButton button: ValueButton) {
        DatePickerView.show(
            type: .date,
            title: "Date",
            doneHandler: { (picker, date) in
                
                button.valueLabel.text = date.dateToString(format: DateFormatter.yyyy_MM_dd)
            }) { (picker) in
                button.valueLabel.text = nil
            }
    }
}
