import Foundation
import Ignite

@main
struct IgniteWebsite {
    static func main() {
        let site = MySite()

        do {
            try site.publish()
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct MySite: Site {
    var name = "CarsonGrossDev"
    var baseTitle = "Carson Gross"
    var url = URL("https://carsongrossdev.com")
    
    var builtInIconsEnabled = true
    var syntaxHighlighters = [SyntaxHighlighter.swift]
    var robotsConfiguration = Robots()
    var author = "Carson Gross"

    var homePage = Home()
    var tagPage = Tags()
    var theme = MyTheme()
    
    var pages: [any StaticPage] {
        Home()
        Posts()
        Projects()
    }
    
    var layouts: [any ContentPage] {
        Story()
        CustomPost()
    }
}


