//
//  TagPage.swift
//
//
//  Created by Carson Gross on 4/8/24.
//

import Foundation
import Ignite

struct Tags: TagPage {
    func body(tag: String?, context: PublishingContext) -> [any BlockElement] {
        if let tag {
            Text(tag)
                .font(.title1)
        } else {
            Text("All tags")
                .font(.title1)
        }

        let articles = context.content(tagged: tag)

        List {
            for article in articles {
                Link(article)
            }
        }
    }
}
