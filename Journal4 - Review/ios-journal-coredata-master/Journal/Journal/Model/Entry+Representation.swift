//
//  Entry+Representation.swift
//  Journal
//
//  Created by Cody Morley on 8/13/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import CoreData

extension Entry {
    
    var rep: EntryRep? {
        guard let id = self.identifier,
            let title = self.title,
            let body = self.bodyText,
            let mood = self.mood,
            let timeStamp = self.timeStamp else {
                NSLog("One or more necessary properties missing. Cannot create codable representation.")
                return nil
        }
        
        let rep = EntryRep(identifier: id,
                           timeStamp: timeStamp,
                           title: title,
                           bodyText: body,
                           mood: mood)
        return rep
    }
    
    @discardableResult convenience init(from rep: EntryRep, context: NSManagedObjectContext) {
        self.init(title: rep.title,
                  bodyText: rep.bodyText,
                  mood: Mood(rawValue: rep.mood)!,
                  timeStamp: Date(),
                  identifier: UUID().uuidString,
                  context: context)
    }
}
