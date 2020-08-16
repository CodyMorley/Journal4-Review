//
//  EntryRep.swift
//  Journal
//
//  Created by Cody Morley on 8/13/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import Foundation

struct EntryRep: Codable {
    let identifier: String
    let timeStamp: Date
    var title: String
    var bodyText: String
    var mood: String
}
