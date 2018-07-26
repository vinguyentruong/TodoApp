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
//        tasks = Task.getDefault()
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
    
    @IBOutlet weak var addTaskButton: ImageButton!
    @IBOutlet weak var profileButton: FABButton!
    @IBOutlet weak var tableView: UITableView!
    private var currentOffset: CGFloat = 0
    private var groups = [TaskGroup]()
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
                } else {
                    sSelf.tableView.startFooterLoading()
                }
            }
            ).disposed(by: disposeBag)
        
        viewModel.tasks.asDriver().drive(onNext: { [weak self] tasks in
            guard let sSelf = self else {
                return
            }
            let groups = Dictionary(grouping: tasks, by: { $0.deadline })
            sSelf.groups = groups
                            .sorted(by: {$0.key.compare($1.key) == .orderedAscending})
                            .map { TaskGroup($0.key.dateToString(format: DateFormat.MMM_dd_yyyy_HH_mm_aa.name),
                                             tasks: $0.value)
                            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22, execute: {
                sSelf.tableView.reloadData()
            })
            
        }).disposed(by: disposeBag)
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
        let leftBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: nil)
        leftBarButton.isEnabled = false
        toolbarItems = [leftBarButton]
    }
}

//MARK: Actions

extension MainViewController {
    
    @objc
    private func createAction() {
        
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
        for section in 0...1 {
            let totalRows = groups[section].rowCount
            for row in 0..<totalRows {
                groups[section].tasks[row].selected = true
            }
        }
        toolbarItems?.first?.isEnabled = true
        tableView.reloadData()
    }
    
    private func deselectAll() {
        for section in 0...1 {
            let totalRows = groups[section].rowCount
            for row in 0..<totalRows {
                groups[section].tasks[row].selected = false
            }
        }
        toolbarItems?.first?.isEnabled = false
        tableView.reloadData()
    }
    
    @objc
    private func logoutAction() {
        navigationController?.popViewController(animated: true)
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
                if groups[section].rowCount > 0 {
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
                
                let newItem = groups[initialIndexPath.section].tasks[initialIndexPath.row]
                groups[initialIndexPath.section].tasks.remove(at: initialIndexPath.row)
                groups[updatingIndexPath.section].tasks.insert(newItem, at: updatingIndexPath.row)
                
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
        for section in 0..<groups.count {
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
        let header = HeaderExpandTableView()
        header.delegate = self
        header.section = section
        header.titleLabel.text = groups[section].sectionTitle
        header.titleLabel.textColor = .red
        header.expand = groups[section].isExpand
        header.contentView.backgroundColor = .white
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell {
            let group = groups[indexPath.section]
            cell.delegate = self
            let job = group.tasks[indexPath.row]
            cell.contentView.backgroundColor = job.selected ? UIColor.orange.withAlphaComponent(0.5) : UIColor.white
//            cell.configUI(name: job.name, done: job.done)
            cell.configUI(task: groups[indexPath.section].tasks[indexPath.row])
            let guesture = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPressForEdit))
            guesture.minimumPressDuration = 0.4
            cell.addGestureRecognizer(guesture)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let rowRemoveAction = UITableViewRowAction.init(style: .destructive, title: "Remove") { (row, indexpath) in
            let task = self.groups[indexPath.section].tasks[indexPath.row]
            self.viewModel.deleteTask(task: task) {
                self.groups[indexPath.section].tasks.remove(at: indexPath.row)
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .left)
                tableView.endUpdates()
            }
        }
        rowRemoveAction.backgroundColor = UIColor.orange.withAlphaComponent(0.7)
        
        return [rowRemoveAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isEditMode {
            guard let detailVC = UIStoryboard.main.getViewController(TaskDetailViewController.self) else {
                return
            }
            detailVC.assignData(groups[indexPath.section].tasks[indexPath.row].id)
            self.navigationController?.pushViewController(detailVC, animated: true)
        } else {
            let group = groups[indexPath.section]
            group.tasks[indexPath.row].selected.toggle()
            tableView.reloadRows(at: [indexPath], with: .none)
            if (group.tasks.map{$0.selected}).contains(true) {
                toolbarItems?.first?.isEnabled = true
            } else {
                toolbarItems?.first?.isEnabled = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == groups.count - 1 {
            viewModel.loadMore()
        }
    }
    
}

//MARK: Tableview datasource

extension MainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].isExpand ? groups[section].rowCount : 0
    }
}


//MARK: Expand HeaderView

extension MainViewController: HeaderExpandTableViewDelegate {
    
    func header(_ header: HeaderExpandTableView, toggleSectionArrow toggle: Bool) {
        groups[header.section].isExpand = toggle
        var indexPaths = [IndexPath]()
        
        for i in 0..<groups[header.section].rowCount {
            indexPaths.append(IndexPath(row: i, section: header.section))
        }
        tableView.beginUpdates()
        let numberRows = tableView.numberOfRows(inSection: header.section)
        if groups[header.section].isExpand {
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
        let group = groups[indexPath.section]
        let job = group.tasks[indexPath.row]
        job.done.toggle()
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
