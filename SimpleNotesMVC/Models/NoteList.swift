//
//  NoteList.swift
//  SimpleNotesMVC
//
//  Created by Владимир Фалин on 29.08.2022.
//

import Foundation
import RealmSwift

class NoteList: Object {
    @Persisted var name = ""
    @Persisted var date = Date()
    @Persisted var notes = List<Note>()
}

class Note: Object {
    @Persisted var name = ""
    @Persisted var message = ""
    @Persisted var date = Date()
    @Persisted var isComplete = false
}
