//
//  EntryTableViewCell.swift
//  Journal
//
//  Created by Cody Morley on 8/11/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import UIKit

class EntryTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var previewLabel: UILabel!
    
    var entry: Entry? {
        didSet {
            updateViews()
        }
    }
    
    
    private func updateViews() {
        guard let entry = entry else { return }
        var formatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy, h:mm a"
            return formatter
        }
        let dateString = formatter.string(from: entry.timeStamp!)
        
        titleLabel.text = entry.title
        dateLabel.text = dateString
        previewLabel.text = entry.bodyText
    }
}
