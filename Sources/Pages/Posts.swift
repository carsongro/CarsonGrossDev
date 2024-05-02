import Foundation
import Ignite

struct Posts: StaticPage {
    var title = "Posts"

    func body(context: PublishingContext) -> [BlockElement] {
        Text("Posts")
            .font(.title3)
        
        Section {
            for item in context.content(tagged: "Post").sorted(by: { $0.date }, order: .reverse) {
                ContentPreview(for: item)
                    .width(4)
                    .margin(.bottom)
            }
        }
    }
}
