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
    var name = "Carson Gross Dev"
    var baseTitle = "Carson Gross"
    var url = URL("https://www.example.com")
    var builtInIconsEnabled = true

    var author = "Carosn Gross"

    var homePage = Home()
    var theme = MyTheme()
}


