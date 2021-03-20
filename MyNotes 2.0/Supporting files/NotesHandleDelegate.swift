//
//  NotesHandleDelegate.swift
//  MyNotes 2.0
//
//  Created by Sergey Golovin on 19.03.2021.
//  Copyright © 2021 GoldenWindGames LLC. All rights reserved.
//

import Foundation

protocol NotesHandleDelegate {
    func saveChanges(note: Note)
    func deleteNote()
}
