//
//  StorageManager.swift
//  SimpleNotesMVC
//
//  Created by Владимир Фалин on 29.08.2022.
//

import Foundation
import RealmSwift

class StorageManager {
    static let shared = StorageManager()
    let realm = try? Realm()
    
    private init() {}
    
    // MARK: - Note List
    func save(_ noteLists: [NoteList]) {
        write {
            realm?.add(noteLists)
        }
    }
    
    func save(_ noteList: String, completion: (NoteList) -> Void) {
        write {
            let taskList = NoteList(value: [noteList])
            realm?.add(taskList)
            completion(taskList)
        }
    }
    
    func delete(_ noteList: NoteList) {
        write {
            realm?.delete(noteList.notes)
            realm?.delete(noteList)
        }
    }
    
    func edit(_ noteList: NoteList, newValue: String) {
        write {
            noteList.name = newValue
        }
    }

    func done(_ noteList: NoteList) {
        write {
            noteList.notes.setValue(true, forKey: "isComplete")
        }
    }

    // MARK: - Notes
    func save(_ note: String, withMessage message: String, to noteList: NoteList, completion: (Note) -> Void) {
        write {
            let note = Note(value: [note, message])
            noteList.notes.append(note)
            completion(note)
        }
    }
    
    func delete(_ note: Note) {
        write {
            realm?.delete(note)
        }
    }
    
    func rename(_ note: Note, to name: String, withMessage message: String) {
        write {
            note.name = name
            note.message = message
        }
    }
    
    func done(_ note: Note) {
        write {
            note.isComplete.toggle()
        }
    }
    
    private func write(completion: () -> Void) {
        do {
            try realm?.write {
                completion()
            }
        } catch {
            print(error)
        }
    }
}
