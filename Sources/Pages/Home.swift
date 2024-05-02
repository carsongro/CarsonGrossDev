//
//  Home.swift
//
//
//  Created by Carson Gross on 4/8/24.
//

import Foundation
import Ignite

struct Home: StaticPage {
    var title = "Home"

    func body(context: PublishingContext) -> [BlockElement] {
        Text("Home")
            .font(.title1)
        
        Text {
            "Hi! I'm Carson and I build iOS apps and backends usually in Swift (including this website). I have a B.S. in Business Administration with Computer Science Integration. I've built features for the Ancestry iOS app, launched some of "
            Link("my own apps ", target: "https://apps.apple.com/us/developer/carson-gross/id1702281177")
            "on the App Store, and I'm an "
            Image(systemName: "apple")
            " Swift Student Challenge 2024 Winner. I'm very passionate about building tools to "
            Link("make full stack iOS development more efficient ", target: "https://github.com/carsongro/Ceto")
            "and "
            Link("animations in SwiftUI", target: "https://twitter.com/carsongrossdev/status/1783285909091463410")
            ". If I'm not programming, I'm lifting weights, running, or reading!"
         }
        .font(.body)
    }
}
