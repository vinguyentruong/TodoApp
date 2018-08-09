//
//  ViewController.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/10/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import UIKit
import Material
import RxSwift

class TaskGroup: GroupItemsExpandTable {
    
    var rowCount: Int {
        return tasks.count
    }
    var sectionTitle: String
    var isExpand: Bool = true
    var tasks:[Task]!
    
    init(_ title: String) {
        sectionTitle = title
    }
    
    init(_ title: String, tasks: [Task]) {
        self.tasks = tasks
        sectionTitle = title
    }
}

struct My {
    static var cellSnapshot : UIView? = nil
}
struct Path {
    static var initialIndexPath : IndexPath? = nil
}


class MainViewController: BaseTodoViewController {
    
    //MARK: Property
    
    internal var viewModel: MainViewModel!
    override var delegate: ViewModelDelegate? {
        return viewModel
    }
    @IBOutlet weak var calendarPickerView: CalendarPickerView!
    @IBOutlet weak var addTaskButton: ImageButton!
    @IBOutlet weak var profileButton: FABButton!
    @IBOutlet weak var tableView: UITableView!
    private var currentOffset: CGFloat = 0
    private var isEditMode = false
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        disposeBag = DisposeBag()
        
        super.viewDidLoad()
        
        prepareUI()
        prepareTableView()
        prepareToolbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        prepareNavigationBar()
    }
    
    //MARK: Overide methods
    
    override func bindData() {
        viewModel.inprogress
            .asObservable()
            .subscribe(onNext: { [weak self] value in
                guard let sSelf = self else {
                    return
                }
                if !value {
                    sSelf.tableView.stopFooterLoading()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.22, execute: {
                        sSelf.tableView.reloadData()
                    })
                } else {
                    sSelf.tableView.startFooterLoading()
                }
            }
            ).disposed(by: disposeBag)
    }
    
    //MARK: IBAction
    
    @IBAction func addTaskAction(_ sender: Any) {
        //
    }
    
}

//MARK: Prepare UI

extension MainViewController {
    
    private func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView?.register(JobCell.nib, forCellReuseIdentifier: JobCell.className)
        tableView?.register(TodoCell.nib, forCellReuseIdentifier: TodoCell.className)
        tableView?.register(TaskCell.nib, forCellReuseIdentifier: TaskCell.className)
//        let guesture = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPressForEdit))
//        guesture.minimumPressDuration = 0.2
//        tableView.addGestureRecognizer(guesture)
//        groups.append(TaskGroup("Tuesday 25th April"))
//        groups.append(TaskGroup("Wednesday 26th April"))
    }
    
    private func prepareUI() {
        UIApplication.shared.statusBarView?.backgroundColor = UIColor.white
        calendarPickerView.delegate = self
        calendarPickerView.currentDate = Date()
    }
    
    private func prepareNavigationBar() {
        navigationController?.isNavigationBarHidden = true
        navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .orange
    }
    
    private func prepareNavigationEditBar() {
        let rightBarButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelBarButtonAction))
        let leftBarButton = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(selectAllBarButtonAction))
        navigationController?.navigationBar.tintColor = UIColor.orange
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func prepareToolbar() {
        navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        navigationController?.toolbar.tintColor = .orange
        let leftBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(handleDeleteTasks))
        leftBarButton.isEnabled = false
        toolbarItems = [leftBarButton]
        let rightBarButton = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
        rightBarButton.isEnabled = false
        let flexibleButton = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [leftBarButton,flexibleButton,rightBarButton]
    }
}

//MARK: Actions

extension MainViewController {
    
    @objc
    private func handleDone() {
        
    }
    
    @objc
    private func cancelBarButtonAction() {
        isEditMode = false
        profileButton.isEnabled = true
        addTaskButton.isEnabled = true
        deselectAll()
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.isToolbarHidden = true
        }
    }
    
    @objc
    private func selectAllBarButtonAction() {
        for section in 0..<viewModel.groups.value.count {
            let totalRows = viewModel.groups.value[section].rowCount
            for row in 0..<totalRows {
                viewModel.groups.value[section].tasks[row].selected = true
            }
        }
        toolbarItems?.first?.isEnabled = true
        tableView.reloadData()
    }
    
    private func deselectAll() {
        for section in 0..<viewModel.groups.value.count {
            let totalRows = viewModel.groups.value[section].rowCount
            for row in 0..<totalRows {
                viewModel.groups.value[section].tasks[row].selected = false
            }
        }
        toolbarItems?.first?.isEnabled = false
        tableView.reloadData()
    }
    
    @objc
    private func handleDeleteTasks() {
        viewModel.deleteTasks()
    }
    
    @objc
    private func handleLongPressForEdit() {
        isEditMode = true
        profileButton.isEnabled = false
        addTaskButton.isEnabled = false
        tableView.allowsMultipleSelection = true
        prepareNavigationEditBar()
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.isToolbarHidden = false
        }
    }
    
    //TODO: Handel Drag and Drop
    
    @objc
    private func handleLongPress(longGesture: UILongPressGestureRecognizer) {
        let state = longGesture.state
        let location = longGesture.location(in: tableView)
        var updatingIndexPath = tableView.indexPathForRow(at: location)
        if updatingIndexPath == nil {
            if let section = getSectionFromPoint(location) {
                let header = tableView.headerView(forSection: section) as? HeaderExpandTableView
                if viewModel.groups.value[section].rowCount > 0 {
                    header?.expandHeader()
                } else {
                    updatingIndexPath = IndexPath(row: 0, section: section)
                }
            }
        }
        
        switch state {
        case UIGestureRecognizerState.began:
            guard let updatingIndexPath = updatingIndexPath,
                let cell = tableView.cellForRow(at: updatingIndexPath) else {
                return
            }
            Path.initialIndexPath = updatingIndexPath
            
            My.cellSnapshot  = snapshopOfCell(cell)
            var center = cell.center
            My.cellSnapshot!.center = center
            My.cellSnapshot!.alpha = 0.0
            tableView.addSubview(My.cellSnapshot!)
            
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                center.y = location.y
                My.cellSnapshot!.center = center
                My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                My.cellSnapshot!.alpha = 0.98
                cell.alpha = 0.0
                
            }, completion: { (finished) -> Void in
                if finished {
                    cell.isHidden = true
                }
            })
            
            return
        case UIGestureRecognizerState.changed:
            guard var center = My.cellSnapshot?.center else {
                return
            }
            
            center.y = location.y
            My.cellSnapshot!.center = center
            if updatingIndexPath != Path.initialIndexPath {
                
                guard
                    let initialIndexPath = Path.initialIndexPath, let updatingIndexPath = updatingIndexPath else {
                    return
                }
                
                let newItem = viewModel.groups.value[initialIndexPath.section].tasks[initialIndexPath.row]
                viewModel.groups.value[initialIndexPath.section].tasks.remove(at: initialIndexPath.row)
                viewModel.groups.value[updatingIndexPath.section].tasks.insert(newItem, at: updatingIndexPath.row)
                
                tableView.moveRow(at: initialIndexPath, to: updatingIndexPath)
                Path.initialIndexPath = updatingIndexPath
            }
        default:
            guard let initialIndexPath = Path.initialIndexPath,
                let cellSnapshot = My.cellSnapshot else {
                return
            }
            
            guard let cell = tableView.cellForRow(at: initialIndexPath) else{
                cellSnapshot.removeFromSuperview()
                return
            }
            
            cell.isHidden = false
            cell.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                cellSnapshot.center = (cell.center)
                cellSnapshot.transform = CGAffineTransform.identity
                cellSnapshot.alpha = 0.0
                cell.alpha = 1.0
            }, completion: { (finished) -> Void in
                if finished {
                    Path.initialIndexPath = nil
                    cellSnapshot.removeFromSuperview()
                    My.cellSnapshot = nil
                }
            })
        }
    }
    
    func snapshopOfCell(_ inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    private func getSectionFromPoint(_ point: CGPoint) -> Int? {
        for section in 0..<viewModel.groups.value.count {
            if tableView.rect(forSection: section).contains(point) {
                return section
            }
        }
        return nil
    }
}

//MARK: Tableview delegate

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if viewModel.groups.value.isEmpty {
            return nil
        }
        let header = HeaderExpandTableView()
        header.delegate = self
        header.section = section
        header.titleLabel.text = viewModel.groups.value[section].sectionTitle
        header.titleLabel.textColor = .red
        header.expand = viewModel.groups.value[section].isExpand
        header.contentView.backgroundColor = .white
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.className, for: indexPath) as? TaskCell {
            if viewModel.groups.value.isEmpty {
                return UITableViewCell()
            }
            let group = viewModel.groups.value[indexPath.section]
            let job = group.tasks[indexPath.row]
            let guesture = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPressForEdit))
            guesture.minimumPressDuration = 0.4
            cell.delegate = self
            cell.contentView.backgroundColor = job.selected ? UIColor.orange.withAlphaComponent(0.5) : UIColor.white
            cell.configUI(task: viewModel.groups.value[indexPath.section].tasks[indexPath.row])
            cell.addGestureRecognizer(guesture)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isEditMode {
            guard let detailVC = UIStoryboard.main.getViewController(TaskDetailViewController.self) else {
                return
            }
            detailVC.assignData(viewModel.groups.value[indexPath.section].tasks[indexPath.row])
            self.navigationController?.pushViewController(detailVC, animated: true)
        } else {
            let group = viewModel.groups.value[indexPath.section]
            group.tasks[indexPath.row].selected.toggle()
            tableView.reloadRows(at: [indexPath], with: .none)
            toolbarItems?.first?.isEnabled = (group.tasks.map{$0.selected}).contains(true)
            toolbarItems?.last?.isEnabled = (group.tasks.map{$0.selected}).contains(true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if viewModel.groups.value.isEmpty {
            return
        }
        if indexPath.row == (viewModel.groups.value.last?.rowCount)! - 1 {
            if !Util.isConnectedToNetwork() {
                return
            }
            viewModel.loadMoreForDate()
        }
    }
}

//MARK: Tableview datasource

extension MainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.groups.value.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.groups.value[section].isExpand ? viewModel.groups.value[section].rowCount : 0
    }
}


//MARK: Expand HeaderView

extension MainViewController: HeaderExpandTableViewDelegate {
    
    func header(_ header: HeaderExpandTableView, toggleSectionArrow toggle: Bool) {
        viewModel.groups.value[header.section].isExpand = toggle
        var indexPaths = [IndexPath]()
        
        for i in 0..<viewModel.groups.value[header.section].rowCount {
            indexPaths.append(IndexPath(row: i, section: header.section))
        }
        tableView.beginUpdates()
        let numberRows = tableView.numberOfRows(inSection: header.section)
        if viewModel.groups.value[header.section].isExpand {
            if numberRows == 0 {
                tableView.insertRows(at: indexPaths, with: .left)
            }
        } else {
            if numberRows == indexPaths.count {
                tableView.deleteRows(at: indexPaths, with: .left)
            }
        }
        tableView.endUpdates()
    }
}

//MARK: TaskCellDelegate

extension MainViewController: TaskCellDelegate {
    
    func taskCell(cell: TaskCell, didSelectDoneButton button: UIButton) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        let group = viewModel.groups.value[indexPath.section]
        let job = group.tasks[indexPath.row]
        if job.status == .done {
            job.rawStatus = Status.inprogess.rawValue
        } else {
            job.rawStatus = Status.done.rawValue
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func taskCell(cell: TaskCell, didSelectDeleteButton button: UIButton) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        let task = self.viewModel.groups.value[indexPath.section].tasks[indexPath.row]
        self.viewModel.deleteTask(task: task) { [weak self] in
            guard let sSelf = self else {
                return
            }
            sSelf.viewModel.groups.value[indexPath.section].tasks.remove(at: indexPath.row)
            sSelf.tableView.beginUpdates()
            sSelf.tableView.deleteRows(at: [indexPath], with: .left)
            sSelf.tableView.endUpdates()
        }
    }
}

//MARK: Calendar pickerview delegate

extension MainViewController: CalendarPickerViewDelegate {
    
    func calendarPickerView(picker: CalendarPickerView, dateDidChange date: Date) {
        viewModel.fetchTasks(date: date)
    }
}
