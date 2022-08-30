//
//  NotesViewController.swift
//  SimpleNotesMVC
//
//  Created by Владимир Фалин on 29.08.2022.
//

import UIKit
import RealmSwift

class NotesViewController: UIViewController {

    var noteList: NoteList!
    
    // MARK: - Private properties
    private var currentNotes: Results<Note>?
    private var completedNotes: Results<Note>?
    private let cellIdentifire = "NotesCell"
    
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
        currentNotes = noteList.notes.filter("isComplete = false")
        completedNotes = noteList.notes.filter("isComplete = true")
    }
    
    // MARK: - Private methods
    private func setupTableView() {
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifire)
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
    
    private func setupNavigationBar() {
        navigationItem.title = noteList.name
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        navigationItem.rightBarButtonItems = [addButton]
    }
    
    private func save(note: String, withMessage message: String) {
        StorageManager.shared.save(note, withMessage: message, to: noteList) { note in
            let rowIndex = IndexPath(row: currentNotes?.index(of: note) ?? 0, section: 0)
            tableview.insertRows(at: [rowIndex], with: .automatic)
        }
    }
    
    @objc private func addButtonPressed() {
        showAlert()
    }
}

// MARK: - Table view delegate
extension NotesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let note = indexPath.section == 0
                ? currentNotes?[indexPath.row]
                : completedNotes?[indexPath.row] else { return UISwipeActionsConfiguration() }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.shared.delete(note)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
            showAlert(with: note) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneTitle = indexPath.section == 0 ? "Done" : "Undone"
        
        let doneAction = UIContextualAction(style: .normal, title: doneTitle) { [weak self] _, _, isDone in
            StorageManager.shared.done(note)
            let currentTaskIndex = IndexPath(
                row: self?.currentNotes?.index(of: note) ?? 0,
                section: 0
            )
            let completedTaskIndex = IndexPath(
                row: self?.completedNotes?.index(of: note) ?? 0,
                section: 1
            )
            let destinationIndexRow = indexPath.section == 0 ? completedTaskIndex : currentTaskIndex
            tableView.moveRow(at: indexPath, to: destinationIndexRow)
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = .green
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
}

// MARK: - Table view data source
extension NotesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentNotes?.count ?? 0 : completedNotes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT NOTES" : "COMPLETED NOTES"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableview.dequeueReusableCell(withIdentifier: cellIdentifire) else { return UITableViewCell() }
        var content = cell.defaultContentConfiguration()
        if let note = indexPath.section == 0 ? currentNotes?[indexPath.row] : completedNotes?[indexPath.row] {
            content.text = note.name
            content.secondaryText = note.message
        }
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - show alert
extension NotesViewController {
    private func showAlert(with note: Note? = nil, completion: (() -> Void)? = nil) {
        let title = note != nil ? "Edit Note" : "New Note"
        
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "What do you want to do?")
        
        alert.action(with: note) { newValue, message in
            if let note = note, let completion = completion {
                StorageManager.shared.rename(note, to: newValue, withMessage: message)
                completion()
            } else {
                self.save(note: newValue, withMessage: message)
            }
        }
        
        present(alert, animated: true)
    }
}
