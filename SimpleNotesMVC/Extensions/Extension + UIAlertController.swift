//
//  Extension + UIAlertController.swift
//  SimpleNotesMVC
//
//  Created by Владимир Фалин on 29.08.2022.
//

import UIKit

extension UIAlertController {
    
    static func createAlert(withTitle title: String, andMessage message: String) -> UIAlertController {
        UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
        
    func action(with noteList: NoteList?, completion: @escaping (String) -> Void) {
        
        let doneButton = noteList == nil ? "Save" : "Update"
                
        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            guard let newValue = self.textFields?.first?.text else { return }
            guard !newValue.isEmpty else { return }
            completion(newValue)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        addTextField { textField in
            textField.placeholder = "List Name"
            textField.text = noteList?.name
        }
    }
    
    func action(with note: Note?, completion: @escaping (String, String) -> Void) {
                        
        let title = note == nil ? "Save" : "Update"
        
        let saveAction = UIAlertAction(title: title, style: .default) { _ in
            guard let newNote = self.textFields?.first?.text else { return }
            guard !newNote.isEmpty else { return }
            
            if let note = self.textFields?.last?.text, !note.isEmpty {
                completion(newNote, note)
            } else {
                completion(newNote, "")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        
        addTextField { textField in
            textField.placeholder = "New note"
            textField.text = note?.name
        }
        
        addTextField { textField in
            textField.placeholder = "Note"
            textField.text = note?.message
        }
    }
}
