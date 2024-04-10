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
        
        Section {
            Image("/images/project/SSC2024_Social_Static_16x9.jpg", description: "Swift Student Challenge 2024 Winner")
                .resizable()
                .frame(maxHeight: 300)
                .horizontalAlignment(.center)
            
            Image("/images/project/header.jpg", description: "Swift Student Challenge 2024 Winner")
                .resizable()
                .frame(maxHeight: 300)
                .horizontalAlignment(.center)
        }
        
        Text{
            "I love to build things! I won the Apple Swift Student Challenge in 2024, and most of my "
            Link("professional experience", target: URL("https://www.linkedin.com/in/carsongross/"))
             " and personal projects are iOS or Swift related, but I'm always exploring new languages and types of development."
         }
        .font(.lead)
        
        List {
            Link("GitHub", target: "https://github.com/carsongro")
            Link("Mastodon", target: "https://mastodon.social/@carsongross")
            Link("Twitter", target: "https://twitter.com/carsongrossdev")
            Link("LinkedIn", target: "https://www.linkedin.com/in/carsongross/")
        }
    }
}
