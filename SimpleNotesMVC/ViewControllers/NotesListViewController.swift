//
//  NotesListViewController.swift
//  SimpleNotesMVC
//
//  Created by Владимир Фалин on 29.08.2022.
//

import UIKit
import RealmSwift

class NotesListViewController: UIViewController {
    
    var noteLists: Results<NoteList>?

    // MARK: - Private properties
    private let cellIdentifire = "NotesListCell"
    
    private lazy var tableview: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupTableView()
        setConstraints()
        createTempData()
        noteLists = StorageManager.shared.realm?.objects(NoteList.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableview.reloadData()
    }
    
    // MARK: - Private methods
    private func setupNavigationBar() {
        title = "Note List"
        navigationController?.navigationBar.prefersLargeTitles = true
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = .systemMint
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func setupTableView() {
        tableview.delegate = self
        tableview.dataSource = self
        view.addSubview(tableview)
        tableview.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            tableview.topAnchor.constraint(equalTo: view.topAnchor),
            tableview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func addButtonPressed() {
        showAlert()
    }

    private func createTempData() {
        DataManager.shared.createTempData { [weak self] in
            self?.tableview.reloadData()
        }
    }
    
    private func save(noteList: String) {
        StorageManager.shared.save(noteList) { noteList in
            let rowIndex = IndexPath(row: noteLists?.index(of: noteList) ?? 0, section: 0)
            tableview.insertRows(at: [rowIndex], with: .automatic)
        }
    }
}

// MARK: - Table view delegate
extension NotesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let noteLists = noteLists else { return }
        let notesVC = NotesViewController()
        let noteList = noteLists[indexPath.row]
        notesVC.noteList = noteList
        navigationController?.pushViewController(notesVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let noteLists = noteLists else { return UISwipeActionsConfiguration() }
        let noteList = noteLists[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.shared.delete(noteList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
            showAlert(with: noteList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { _, _, isDone in
            StorageManager.shared.done(noteList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = .green
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
}

// MARK: - Table view data source
extension NotesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        if let noteLists = noteLists, !noteLists.isEmpty {
            numberOfRows = noteLists.count
        }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let noteLists = noteLists else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifire) ?? UITableViewCell(style: .value1, reuseIdentifier: cellIdentifire)
        let noteList = noteLists[indexPath.row]
        cell.configure(with: noteList)
        return cell
    }
}

// MARK: - show alert
extension NotesListViewController {
    private func showAlert(with noteList: NoteList? = nil, completion: (() -> Void)? = nil) {
        let title = noteList != nil ? "Edit List" : "New List"
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "Please set title for new note list")
        
        alert.action(with: noteList) { [weak self] newValue in
            if let noteList = noteList, let completion = completion {
                StorageManager.shared.edit(noteList, newValue: newValue)
                completion()
            } else {
                self?.save(noteList: newValue)
            }
        }
        present(alert, animated: true)
    }
}
