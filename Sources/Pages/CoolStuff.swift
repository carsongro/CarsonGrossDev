//
//  CoolStuff.swift
//
//
//  Created by Carson Gross on 4/9/24.
//

import Foundation
import Ignite

struct CoolStuff: StaticPage {
    var title = "Cool Stuff"

    func body(context: PublishingContext) -> [BlockElement] {
        Text("Here are some fun projects I've made")
            .font(.title1)
        
        Text {
            "This is only a few projects, to check out more of what I've build, go to my "
            Link("GitHub!", target: URL("https://github.com/carsongro"))
        }
        .font(.lead)
        
        Section {
            for item in context.content(tagged: "Project") {
                ContentPreview(for: item)
                    .width(4)
                    .margin(.bottom)
            }
        }
        .margin(.bottom, .extraLarge)
    }
}
