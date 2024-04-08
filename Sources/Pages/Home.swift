import Foundation
import Ignite

struct Home: StaticPage {
    var title = "Home"

    func body(context: PublishingContext) -> [BlockElement] {
        Text("Welcome!")
            .font(.title1)
        
        Text("Posts")
            .font(.title3)
        
        Section {
            for item in context.allContent {
                ContentPreview(for: item)
                    .width(5)
                    .margin(.bottom)
            }
        }
        .margin(.bottom, .extraLarge)
    }
}
