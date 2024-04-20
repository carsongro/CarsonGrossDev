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
            "I love to build stuff! I've been using Swift and building for Apple platforms for 2+ years, and I won the Apple Swift Student Challenge in 2024! My professional experience and personal projects are Swift and iOS related, but I'm always exploring new things."
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
