//
//  DataManager.swift
//  SimpleNotesMVC
//
//  Created by Владимир Фалин on 29.08.2022.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    func createTempData(completion: @escaping () -> Void) {
        if !UserDefaults.standard.bool(forKey: "done") {
            let shoppingList = NoteList()
            shoppingList.name = "Shopping List"
            let milk = Note(value: ["name": "Milk", "message": "2L"])
            shoppingList.notes.append(milk)
            let bread = Note(value: ["name": "Bread"])
            shoppingList.notes.append(bread)
            let apples = Note(value: ["name": "Apples", "message": "2Kg"])
            shoppingList.notes.append(apples)
            
            let moviesList = NoteList()
            moviesList.name = "Movies List"
            let firstMovie = Note(value: ["name": "Pulp Fiction"])
            moviesList.notes.append(firstMovie)
            let secondMovie = Note(value: ["name": "Reservoir Dogs"])
            moviesList.notes.append(secondMovie)

            DispatchQueue.main.async {
                StorageManager.shared.save([shoppingList, moviesList])
                UserDefaults.standard.set(true, forKey: "done")
                completion()
            }
        }
    }
}
