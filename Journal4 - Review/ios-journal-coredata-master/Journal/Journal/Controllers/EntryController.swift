//
//  EntryController.swift
//  Journal
//
//  Created by Cody Morley on 8/11/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import CoreData



class EntryController {
    //MARK: Types
    enum HTTPMethod: String {
        case delete = "DELETE"
        case get = "GET"
        case put = "PUT"
    }
    
    enum NetworkError: Error {
        case badResponse
        case otherError
    }
    
    typealias ErrorHandler = (Result<Bool, NetworkError>) -> Void
    
    
    //MARK: Properties
    private var baseURL = URL(string: "https://journal-8ffed.firebaseio.com/")!
    
    lazy var frc: NSFetchedResultsController<Entry> = {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        let moodSortDescriptor = NSSortDescriptor(key: "mood", ascending: true)
        let dateSortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        fetchRequest.sortDescriptors = [moodSortDescriptor, dateSortDescriptor]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: CoreDataStack.shared.mainContext,
                                             sectionNameKeyPath: "mood",
                                             cacheName: nil)
        do {
            try frc.performFetch()
        } catch {
            fatalError("Unable to fetch menu Items from frc.")
        }
        return frc
    }()
    
    
    //MARK: Inits
    init() {
        fetchEntriesFromServer {}
    }
    
    
    //MARK: CRUD Methods
    func createEntry(title: String, body: String, mood: Mood) {
        let newEntry = Entry(title: title,
                             bodyText: body,
                             mood: mood,
                             context: CoreDataStack.shared.mainContext)
        let context = CoreDataStack.shared.mainContext
        context.performAndWait {
            do {
                try context.save()
            } catch {
                NSLog("Ruh roh. couldn't save your entry: \(error)")
                return
            }
        }
        sendEntryToServer(newEntry, completion: {
            NSLog("Entry successfully created and posted to firebase.")
        })
    }
    
    func updateEntry(_ entry: Entry, title: String, body: String, mood: Mood) {
        entry.title = title
        entry.bodyText = body
        entry.mood = mood.rawValue
        CoreDataStack.shared.save(context: CoreDataStack.shared.backgroundContext)
    }
    
    func deleteEntry(_ entry: Entry) {
        let context = CoreDataStack.shared.mainContext
        context.perform {
            do {
                context.delete(entry)
                try context.save()
            } catch {
                NSLog("Unable to save managed object context after deleting. \(error)")
                return
            }
        }
    }
    
    
    //MARK: HTTP Methods
    func fetchEntriesFromServer(completion: @escaping () -> Void) {
        let getRequest = getFetchRequest()
        URLSession.shared.dataTask(with: getRequest) { data, response, error in
            if let error = error {
                NSLog("Something unexpected happened during fetch request: \(error.localizedDescription) \(error)")
                completion()
            }
            
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200 else {
                    NSLog("Bad or no response from firebase for fetch request.")
                    completion()
                    return
            }
            
            guard let data = data else {
                NSLog("No data returned from fetch request.")
                completion()
                return
            }
            
            do {
                var entryReps = [EntryRep]()
                let decodedReps = try JSONDecoder().decode([String : EntryRep].self, from: data)
                for (_, entryRep) in decodedReps {
                    entryReps.append(entryRep)
                }
                self.updateEntries(with: entryReps)
                completion()
            } catch {
                NSLog("Unable to decode Entry reps. Here's what happened: \(error.localizedDescription) \(error)")
                completion()
            }
        }.resume()
    }
    
    func sendEntryToServer(_ entry: Entry, completion: @escaping () -> Void) {
        let postRequest: URLRequest? = prepareEntryForPost(entry)
        guard let request = postRequest else {
            NSLog("Couldn't get valid request.")
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                NSLog("There was an error posting your request: \(error.localizedDescription) \(error)")
                completion()
            }
            
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200 else {
                    NSLog("bad or no response from server.")
                    completion()
                    return
            }
            
            NSLog("Posted entry")
            completion()
        }.resume()
    }
    
    func deleteEntryFromServer(_ entry: Entry, completion: @escaping ErrorHandler = { _ in }) {
        let deleteRequest = getDeleteRequest(entry)
        
        URLSession.shared.dataTask(with: deleteRequest) { _, response, error in
            if let error = error {
                NSLog("Error with your deletion request: \(error.localizedDescription) \(error)")
                completion(.failure(.otherError))
            }
            
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200 else {
                    NSLog("Bad or no response from server.")
                    completion(.failure(.badResponse))
                    return
            }
            NSLog("Deleted entry: \(String(describing:entry.identifier))")
            completion(.success(true))
        }.resume()
    }
    
    private func updateEntries(with reps: [EntryRep]) {
        let repIDs = reps.map({ $0.identifier })
        let repsByID = Dictionary(uniqueKeysWithValues: zip(repIDs, reps))
        var entriesToCreate = repsByID
        
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        let predicate = NSPredicate(format: "identifier IN %@", repIDs)
        fetchRequest.predicate = predicate
        let context = CoreDataStack.shared.backgroundContext
        
        context.performAndWait {
            do {
                let entryMatches = try context.fetch(fetchRequest)
                for entry in entryMatches {
                    guard let id = entry.identifier,
                        let rep = entriesToCreate[id] else { continue }
                    self.update(with: rep, to: entry)
                    entriesToCreate.removeValue(forKey: id)
                }
            } catch {
                NSLog("Fetch Request Error. Here's what happened: \(error.localizedDescription) \(error)")
                return
            }
            
            for rep in entriesToCreate.values {
                Entry(from: rep, context: context)
            }
            CoreDataStack.shared.save(context: context)
        }
    }
    
    
    private func update(with rep: EntryRep, to entry: Entry) {
        entry.title = rep.title
        entry.bodyText = rep.bodyText
        entry.mood = rep.mood
    }
    
    private func getFetchRequest() -> URLRequest {
        let url = baseURL.appendingPathExtension("json")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        return request
    }
    
    private func getDeleteRequest(_ entry: Entry) -> URLRequest {
        let url = baseURL.appendingPathComponent("\(String(describing: entry.identifier))").appendingPathExtension("json")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.delete.rawValue
        return request
    }
    
    private func prepareEntryForPost(_ entry: Entry) -> URLRequest? {
        let url = baseURL.appendingPathComponent("\(String(describing: entry.identifier))").appendingPathExtension("json")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.put.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encodedEntry = try JSONEncoder().encode(entry.rep)
            request.httpBody = encodedEntry
            return request
        } catch {
            NSLog("There was an error encoding entry \(String(describing: entry.identifier)): \(error.localizedDescription) \(error)")
            return nil
        }
    }
}
