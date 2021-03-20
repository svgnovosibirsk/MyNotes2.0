//
//  NotesViewController.swift
//  MyNotes 2.0
//
//  Created by Sergey Golovin on 19.03.2021.
//  Copyright © 2021 GoldenWindGames LLC. All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UICollectionViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let reuseIdentifier = "noteCell"
    private let detailID = "detailVC"
    
    private let numberOfCellsInRow: CGFloat = 2
    private let insetWidth: CGFloat = 20
    private let sectionInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    private var editMode = false
    private var indexPathForEditingNote: IndexPath?
    
    var notesArray = [Note]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadNotes()
        createTestNotes()
    }
    
    // Creates first note when app first time starts
    private func createTestNotes() {
        var localNotesArray = [Note]()
        let request: NSFetchRequest<Note> = Note.fetchRequest()
               do {
                   localNotesArray = try context.fetch(request)
               } catch {
                   print("Load error \(error)")
               }
        if localNotesArray.isEmpty {
            let firstNote = Note(context: context)
            firstNote.title = "Note one"
            firstNote.body = "My first note"
            notesArray.append(firstNote)
            collectionView.reloadData()
        }
    }

    // MARK: Present DetailVC
    
    // Go to DetailViewController to create new note
    @IBAction func addNoteBtnPressed(_ sender: UIBarButtonItem) {
        editMode = false
        presentDetailVC()
    }
    
    // Go to DetailViewController to edit existing note
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        editMode = true
        indexPathForEditingNote = indexPath
        let note = notesArray[indexPath.row]
        presentDetailVC(with: note)
    }
    
    // Presents DetailViewController
    private func presentDetailVC(with note: Note? = nil) {
        let detailVC = storyboard?.instantiateViewController(withIdentifier: detailID) as! DetailViewController
        detailVC.notesHandleDelegate = self
        if let noteToPass = note {
            detailVC.note = noteToPass
        }
        present(detailVC, animated: true, completion:  nil)
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notesArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? NoteCell else { return UICollectionViewCell()}
        let note = notesArray[indexPath.row]
        cell.noteTitle.text = note.title
        cell.noteBody.text = note.body
    
        return cell
    }
    
    // MARK: CoreData Methods
    
    private func saveNotes() {
        do {
            try context.save()
        } catch {
            print("Save error \(error)")
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    private func loadNotes() {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        do {
            notesArray = try context.fetch(request)
        } catch {
            print("Load error \(error)")
        }
    }

}

   // MARK: Layout settings

extension NotesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let insetsWidth = insetWidth * (numberOfCellsInRow + 1)
        let widthForCells = collectionView.frame.width - insetsWidth
        let cellWith = widthForCells / numberOfCellsInRow
        
        return CGSize(width: cellWith, height: cellWith)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return insetWidth
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return insetWidth
    }
}

   // MARK: NotesHandleDelegate Methods

extension NotesViewController: NotesHandleDelegate {

    func saveChanges(note: Note) {
        if editMode {
            guard let index = indexPathForEditingNote?.row else { return }
            notesArray[index] = note
            saveNotes()
        } else {
            notesArray.append(note)
            saveNotes()
        }
    }
    
    func deleteNote() {
        guard let index = indexPathForEditingNote?.row else { return }
        context.delete(notesArray[index])
        notesArray.remove(at: index)
        saveNotes()
    }
}
