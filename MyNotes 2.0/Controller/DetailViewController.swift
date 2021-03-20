//
//  DetailViewController.swift
//  MyNotes 2.0
//
//  Created by Sergey Golovin on 19.03.2021.
//  Copyright © 2021 GoldenWindGames LLC. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var notesHandleDelegate: NotesHandleDelegate!
    var note: Note?
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyLbl: UILabel!
    @IBOutlet weak var bodyTextView: UITextView! 
    @IBOutlet weak var noteImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if note == nil {
           setEmptyNote()
        }
        setEditStyleUI()
        setDismissKeyboardGesture()

    }
    // Presents UIImagePickerController
    @IBAction func LoadImgBtnPressed(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    // Deletes note
    @IBAction func deleteBtnPressed(_ sender: UIButton) {
        notesHandleDelegate.deleteNote()
        dismiss(animated: true, completion: nil)
    }
    
    // Saves note
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        configureNote()
        if let note = note {
            notesHandleDelegate.saveChanges(note: note)
        }
        dismiss(animated: true, completion: nil)
    }
    
    // Sets empty note when view loads
    private func setEmptyNote() {
        note = Note(context: context)
        note?.title = ""
        note?.body = ""
        note?.image = nil
    }
    
    // Sets text fields and imageView when note is editing
    private func setEditStyleUI() {
        titleTextField.text = note?.title
        bodyTextView.text = note?.body
        guard let imageData = note?.image else { return }
        noteImageView.image = UIImage(data: imageData)
    }
    
    // Sets note's properties by data from text fields and imageView
    private func configureNote() {
        let title = titleTextField.text!
        let body = bodyTextView.text!
        let noteImage = noteImageView.image?.jpegData(compressionQuality: 1)
        
        note?.title = title
        note?.body = body
        note?.image = noteImage
    }
    
    // MARK: - Dismiss keyboard
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
}

  // MARK: - UIImagePicker

extension DetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        DispatchQueue.main.async {
            self.noteImageView.image = image
        }
    }
    
}
