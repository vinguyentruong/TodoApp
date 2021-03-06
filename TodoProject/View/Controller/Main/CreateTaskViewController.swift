//
//  CreateTaskViewController.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/18/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit
import Material

class CreateTaskViewController: BaseTodoViewController {

    //MARK: Property
    
    internal var viewModel: CreateTaskViewModel!
    override var delegate: ViewModelDelegate? {
        return viewModel
    }
    
    @IBOutlet weak var tableView: UITableView!
    private var itemTitlesTable = [String]()
    private var cellIdentifies = [NameCell.className, DateTimeCell.className, DescriptionCell.className]
    private var name = ""
    private var content = ""
    private var date: Date? = Date()
    private var time: Date? = Date()
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.url(forResource: "TaskProperties", withExtension: "plist") {
            if let data = try? Data(contentsOf: path),
                let array = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String] {
                itemTitlesTable = array ?? []
            }
        }
        prepareTableView()
        prepareNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
}

//MARK: Prepare UI

extension CreateTaskViewController {
    
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
        let rightBarButton = UIBarButtonItem(title  : "Done",
                                             style  : .done,
                                             target : self,
                                             action : #selector(handelDoneAction))
        navigationItem.rightBarButtonItem = rightBarButton
    }
}

//MARK: Actions

extension CreateTaskViewController {
    
    @objc
    private func handelDoneAction() {
        viewModel.createTask(name: name, date: date, time: time, description: content)
    }
    
    private func validateFields() {
        
    }
}

//MARK: TableView Delegate

extension CreateTaskViewController: UITableViewDelegate {
    
}

//MARK: TableView Datasource

extension CreateTaskViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemTitlesTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifies[indexPath.row]) as? BaseTableViewCell {
            (cell as? DateTimeCell)?.configure(defaultDate: Date(), defaultTime: Date())
            cell.delegate = self
            cell.configure(title: itemTitlesTable[indexPath.row])
            return cell
        }
        
        return UITableViewCell()
    }
}

//MARK: DateTimeCellDelegate

extension CreateTaskViewController: DateTimeCellDelegate {
    
    func dateTimeCell(didSelectTimeButton button: ValueButton) {
        DatePickerView.show(
            type        : .time,
            title       : "Time",
            doneHandler : { (picker, date) in
                
                button.valueLabel.text = date.dateToString(format: DateFormatter.hh_mm_aa)
                self.time = date
            }) { (picker) in
                button.valueLabel.text = nil
                self.time = nil
            }
    }
    
    func dateTimeCell(didSelectDateButton button: ValueButton) {
        DatePickerView.show(
            type        : .date,
            title       : "Date",
            doneHandler : { (picker, date) in
                
                button.valueLabel.text = date.dateToString(format: DateFormatter.yyyy_MM_dd)
                self.date = date
            }) { (picker) in
                button.valueLabel.text = nil
                self.date = nil
            }
    }
}

extension CreateTaskViewController: NameCellDelegate {
    
    func nameCell(nameValueDidEndChange textField: TextField) {
        name = textField.text ?? ""
    }
}

extension CreateTaskViewController: DescriptionCellDelegate {
    
    func descriptionCell(contentDidEndChange text: String?) {
        content = text ?? ""
    }
}
