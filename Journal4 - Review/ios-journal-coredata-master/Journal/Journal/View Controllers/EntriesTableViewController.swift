//
//  EntriesTableViewController.swift
//  Journal
//
//  Created by Cody Morley on 8/11/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import UIKit
import CoreData

class EntriesTableViewController: UITableViewController {
    var entryController = EntryController()
    
    //MARK: Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        entryController.frc.delegate = self
    }
    
    
    // MARK: - Tableview Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return entryController.frc.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return entryController.frc.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EntryCell", for: indexPath) as? EntryTableViewCell else { fatalError("Unable to dequeue cell.") }
        cell.entry = entryController.frc.object(at: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let entry = entryController.frc.object(at: indexPath)
        entryController.deleteEntry(entry)
        entryController.deleteEntryFromServer(entry,
                                              completion: { _ in })
    }
    
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        
        switch segue.identifier {
        case "CreateEntrySegue":
            if let navController = segue.destination as? UINavigationController,
                let createVC = navController.topViewController as? CreateEntryViewController {
                    createVC.entryController = entryController
            }
        case "DetailSegue":
            guard let indexPath = tableView.indexPathForSelectedRow else {
                NSLog("no index path or no row selected")
                return
            }
            if let detailVC = segue.destination as? EntryDetailViewController {
                detailVC.entry = entryController.frc.object(at: indexPath)
                detailVC.entryController = entryController
            }
        default:
            NSLog("Unknown segue. Check ID.")
            break
        }
    }
}


extension EntriesTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        @unknown default:
            break
        }
    }
}


