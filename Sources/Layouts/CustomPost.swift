//
// CustomPost.swift
// IgniteSamples
// https://www.github.com/twostraws/Ignite
// See LICENSE for license information.
//

import Foundation
import Ignite

struct CustomPost: ContentPage {
    func body(content: Content, context: PublishingContext) -> [any BlockElement] {
        if let image = content.image {
            Image(image, description: content.imageDescription)
                .resizable()
        }

        Text(content.title)
            .font(.title1)

        if content.hasTags {
            Text {
                content.tagLinks(in: context)
            }
            .font(.title3)
            .foregroundStyle(.cornflowerBlue)
        }

        Text(content.body)
    }
}
