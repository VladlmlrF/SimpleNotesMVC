//
//  Extension + UITableViewCell.swift
//  SimpleNotesMVC
//
//  Created by Владимир Фалин on 29.08.2022.
//

import UIKit

extension UITableViewCell {
    func configure(with noteList: NoteList) {
        let currentNotes = noteList.notes.filter("isComplete = false")
        var content = defaultContentConfiguration()
        content.text = noteList.name
        
        
        if noteList.notes.isEmpty {
            content.secondaryText = "0"
            accessoryType = .disclosureIndicator
        } else if currentNotes.isEmpty {
            content.secondaryText = nil
            accessoryType = .checkmark
        } else {
            content.secondaryText = currentNotes.count.formatted()
            accessoryType = .disclosureIndicator
        }

        contentConfiguration = content
    }
}

