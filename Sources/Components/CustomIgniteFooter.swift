//
//  File.swift
//  
//
//  Created by Carson Gross on 5/2/24.
//

import Foundation
import Ignite

/// Displays "Created by Ignite", with a link back to the Ignite project on GitHub.
/// Including this is definitely not required for your site, but it's most appreciated 🙌
public struct CustomIgniteFooter: Component {
    public init() { }

    public func body(context: PublishingContext) -> [any PageElement] {
        Text {
            Link("App Store", target: "https://apps.apple.com/us/developer/carson-gross/id1702281177")
            " \u{2022} "
            Link("GitHub", target: "https://github.com/carsongro")
            " \u{2022} "
            Link("Mastodon", target: "https://mastodon.social/@carsongross")
            " \u{2022} "
            Link("Twitter", target: "https://twitter.com/carsongrossdev")
            " \u{2022} "
            Link("LinkedIn", target: "https://www.linkedin.com/in/carsongross/")
        }
        .horizontalAlignment(.center)
        .margin(.top, .extraLarge)
        
        Text {
            "Created with "
            Link("Ignite", target: URL("https://github.com/twostraws/Ignite"))
        }
        .horizontalAlignment(.center)
    }
}
