//
//  NavBar.swift
//  
//
//  Created by Carson Gross on 4/7/24.
//

import Foundation
import Ignite

/// An example navigation bar, demonstrating how to create reusable components.
struct NavBar: Component {
    func body(context: PublishingContext) -> [any PageElement] {
        NavigationBar(logo: Text("Carson Gross Dev").font(.title1)) {
            Link("GitHub", target: "https://github.com/carsongro")
            
            Link("About", target: About())

            Dropdown("Carson Gross") {
                Link("Mastodon", target: "https://mastodon.social/@carsongross")
                Link("Twitter", target: "https://twitter.com/carsongrossdev")
            }
        }
        .navigationItemAlignment(.trailing)
        .navigationBarStyle(.dark)
        .backgroundColor(.cornflowerBlue)
        .position(.fixedTop)
    }
}
