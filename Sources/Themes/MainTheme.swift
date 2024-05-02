import Foundation
import Ignite

struct MyTheme: Theme {
    func render(page: Page, context: PublishingContext) -> HTML {
        HTML {
            Head(for: page, in: context)

            Body {
                NavBar()

                page.body
   
                CustomIgniteFooter()
            }
            .padding(.vertical, 100)
            
        }
    }
}
