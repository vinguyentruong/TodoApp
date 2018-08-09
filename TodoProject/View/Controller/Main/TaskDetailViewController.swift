//
//  JobDetailViewController.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/13/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit
import RxSwift
import SpringIndicator
import Material

class TaskDetailViewController: BaseTodoViewController {

    //MARK: Property
    internal var viewModel: TaskDetailViewModel!
    override var delegate: ViewModelDelegate? {
        return viewModel
    }
    
    @IBOutlet weak var doneSwitch: UISwitch!
    @IBOutlet weak var rowDoneView: UIView!
    @IBOutlet weak var tableView: UITableView!
    private var itemTitlesTable = [String]()
    private var cellIdentifies = [NameCell.className, DateTimeCell.className, DescriptionCell.className]
    private var name = ""
    private var content = ""
    private var date: Date? = Date()
    private var time: Date? = Date()
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        disposeBag = DisposeBag()
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
    
    //MARK: Overide methods
    
    override func bindAction() {
        viewModel
            .inprogress
            .asObservable()
            .subscribe(onNext: { [weak self] value in
                guard let sSelf = self else {
                    return
                }
                if value {
                    sSelf.view.startAnimation(attribute: SpringIndicator.lagreAndCenter)
                } else {
                    sSelf.view.stopAnimation()
                }
            }
        ).disposed(by: disposeBag)
    }
    
    override func bindData() {
        viewModel.task.asDriver().drive(onNext: { [weak self] task in
            guard let sSelf = self else {
                return
            }
            sSelf.doneSwitch.isOn = task.status == .done
            sSelf.name = task.name
            sSelf.date = task.deadline
            sSelf.time = task.deadline
            sSelf.content = task.content
            sSelf.tableView.reloadData()
        }).disposed(by: disposeBag)
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
        let rightBarButton = UIBarButtonItem.init(title: "Save", style: .done, target: self, action: #selector(handleSave))
        navigationItem.rightBarButtonItem = rightBarButton
    }
}

//MARK: Actions

extension TaskDetailViewController {
    
    @objc
    private func handleSave() {
        guard
            let date = date,
            let time = time,
            let deadline = DateHelper.shared.combineDateWithTime(date: date, time: time),
            !name.trimmed.isEmpty else {
                viewModel.navigator.showAlert(
                    title           : "Error",
                    message         : "You must fill in all of the fields!",
                    negativeTitle   : "Ok")
            return
        }
        viewModel.updateTask(
            name        : name,
            deadline    : deadline,
            description : content,
            isDone    : doneSwitch.isOn)
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
            let task = viewModel.task.value
            cell.delegate = self
            cell.configure(title: itemTitlesTable[indexPath.row], task: task)
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
                self.time = date
            }) { (picker) in
                button.valueLabel.text = nil
                self.time = nil
            }
    }
    
    func dateTimeCell(didSelectDateButton button: ValueButton) {
        DatePickerView.show(
            type: .date,
            title: "Date",
            doneHandler: { (picker, date) in
                button.valueLabel.text = date.dateToString(format: DateFormatter.yyyy_MM_dd)
                self.date = date
            }) { (picker) in
                button.valueLabel.text = nil
                self.date = nil
            }
    }
}

extension TaskDetailViewController: NameCellDelegate {
    
    func nameCell(nameValueDidEndChange textField: TextField) {
        name = textField.text ?? ""
    }
}

extension TaskDetailViewController: DescriptionCellDelegate {
    
    func descriptionCell(contentDidEndChange text: String?) {
        content = text ?? ""
    }
}
