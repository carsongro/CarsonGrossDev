import Foundation
import Ignite

struct Home: StaticPage {
    var title = "Home"

    func body(context: PublishingContext) -> [BlockElement] {
        Text("Welcome!")
            .font(.title1)
        
        Text {
            "Check out some "
            Link("cool projects", target: CoolStuff())
            ", Or stay here to see posts."
        }
        
        Text("Posts")
            .font(.title3)
        
        Section {
            for item in context.content(tagged: "Post") {
                ContentPreview(for: item)
                    .width(4)
                    .margin(.bottom)
            }
        }
        
        Text("Projects")
            .font(.title3)
        
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
