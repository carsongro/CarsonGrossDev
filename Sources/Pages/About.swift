//
//  About.swift
//
//
//  Created by Carson Gross on 4/8/24.
//

import Foundation
import Ignite

struct About: StaticPage {
    var title = "About"

    func body(context: PublishingContext) -> [BlockElement] {
        Text("About me")
            .font(.title1)
        
        Text("I love to build things! Most of my experience and personal projects are iOS or Swift related, but I'm always exploring new languages and types of development.")
            .font(.lead)
        
        List {
            Link("GitHub", target: "https://github.com/carsongro")
            Link("Mastodon", target: "https://mastodon.social/@carsongross")
            Link("Twitter", target: "https://twitter.com/carsongrossdev")
            Link("LinkedIn", target: "https://www.linkedin.com/in/carsongross/")
        }
    }
}
