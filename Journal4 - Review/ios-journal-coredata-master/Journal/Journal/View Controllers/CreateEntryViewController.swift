//
//  CreateEntryViewController.swift
//  Journal
//
//  Created by Cody Morley on 8/11/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import UIKit

class CreateEntryViewController: UIViewController {
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var bodyView: UITextView!
    @IBOutlet weak var moodControl: UISegmentedControl!
    
    var entryController: EntryController?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func cancel(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        guard let controller = entryController,
            let title = titleField.text,
            let body = bodyView.text,
            !title.isEmpty,
            title != "",
            !body.isEmpty,
            body != "" else {
                NSLog("Need a title and body to save an Entry.")
                return
        }
        let moodIndex = moodControl.selectedSegmentIndex
        let mood = Mood.allCases[moodIndex]
        
        controller.createEntry(title: title,
                               body: body,
                               mood: mood)
        
        navigationController?.dismiss(animated: true,
                                      completion: nil)
    }
}
