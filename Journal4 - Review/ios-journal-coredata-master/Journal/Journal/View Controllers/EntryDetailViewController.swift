//
//  EntryDetailViewController.swift
//  Journal
//
//  Created by Cody Morley on 8/12/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import UIKit

class EntryDetailViewController: UIViewController {
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var bodyView: UITextView!
    @IBOutlet weak var moodControl: UISegmentedControl!
    
    var entryController: EntryController?
    var entry: Entry?
    var wasEdited: Bool = false
    
    
    //MARK: Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem
        updateViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if wasEdited {
            guard let entry = entry,
                let controller = entryController,
                let title = titleField.text,
                let body = bodyView.text,
                !title.isEmpty,
                !body.isEmpty,
                title != "",
                body != "" else {
                    NSLog("Not updated. Fields may not be empty.")
                    return
            }
            
            let mood = Mood.allCases[moodControl.selectedSegmentIndex]
            controller.updateEntry(entry,
                                   title: title,
                                   body: body,
                                   mood: mood)
            controller.sendEntryToServer(entry,
                                         completion: {})
        }
    }
    
    
    //MARK: Methods
    private func updateViews() {
        guard let entry = entry else {
            fatalError("No entry passed in prepare method.")
        }
        setUserInteraction()
        
        let mood = Mood(rawValue: entry.mood!)!
        let moodIndex = Mood.allCases.firstIndex(of: mood)!
        
        titleField.text = entry.title
        bodyView.text = entry.bodyText
        moodControl.selectedSegmentIndex = moodIndex
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing,
                         animated: animated)
        if isEditing {
            wasEdited = true
        }
        setUserInteraction()
    }
    
    private func setUserInteraction() {
        titleField.isUserInteractionEnabled = isEditing
        bodyView.isUserInteractionEnabled = isEditing
        moodControl.isUserInteractionEnabled = isEditing
        navigationItem.hidesBackButton = isEditing
    }
}
