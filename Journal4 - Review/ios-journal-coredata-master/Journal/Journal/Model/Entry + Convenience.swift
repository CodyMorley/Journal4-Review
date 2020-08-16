//
//  Entry + Convenience.swift
//  Journal
//
//  Created by Cody Morley on 8/11/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import CoreData

enum Mood: String, CaseIterable {
    case neutral = "😐"
    case happy = "😁"
    case angry = "🤬"
}


extension Entry {
    
    
    @discardableResult convenience init(title: String,
                                        bodyText: String,
                                        mood: Mood,
                                        timeStamp: Date = Date(),
                                        identifier: String = UUID().uuidString,
                                        context: NSManagedObjectContext) {
        self.init(context: context)
        self.title = title
        self.bodyText = bodyText
        self.mood = mood.rawValue
        self.timeStamp = timeStamp
        self.identifier = identifier
    }
}
