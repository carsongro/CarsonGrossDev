---
layout: CustomPost
tags: Swift, Post
image: /images/photos/Swift_logo_color.svg
lastModified: 2024-04-20
---
# Using @resultBuilder to Interface SwiftUI with UIKit

Before getting into this, I strongly recommend watching [this](https://developer.apple.com/videos/play/wwdc2021/10253/) WWDC video about `@resultBuilder` and DSL's in Swift. I'm by no means an expert in this topic, but I found some cool stuff that they can do.

### The Original Code

This started when I was browing around and I came across [this](https://github.com/sebjvidal/Sports-UI-Demo) repository from Seb Vidal recreating the horizontal scrolling cards from the Apple Sports app. This is awesome but I thought that it would be cool to have a way to interact with this view in a SwiftUI-esque way, to be able to say "I want this horizontal scrolling view with each card representing some view that I *declare* but I don't want to know the implementation details," I wanted to be able to use the view with the SwiftUI trailing closure syntax and have it configure everything for me (how many cards to use, what card to display, when to dismiss, etc.) without any additional work.

### What I did

I do want to say that this might not be the "best" to way to solve this problem, but I find it a fun exploration of Swift's cool language features. I'm not going to show all of the implementation details inside of the `View`s and `ViewController`s because the implementation details aren't as cool and ultimately every project's going to differ a lot in this regard. But for this project specifically, I had to make some modifications to the `UIView`s and `UIViewController`s so that rather than having the demo views they used from UIKit, they now would would take in an `[any View]` and then add them using a `UIHostingController` that took up the whole view when they configure themselves.

Now to get into the fun stuff. I started by writing how I wanted to be able to use the view:

```swift
HScrollCardView {
    ForEach(0..&lt;10) { _ in
        Rectangle()
            .foregroundStyle([.purple, .blue, .indigo, .mint].randomElement()!)
    }
    
    Text("Another Example View")
        .backgroundStyle(.red)
}
```

In this case, I want things to be *very* similar to how SwiftUI uses @ViewBuilder and `TupleView`, except I want some behavior that's a bit different. Instead of getting one view back from the `ForEach` I wanted to be able to get a seperate view from every iteration of the loop so I could add it to my array of `[any View]` in my `ViewController`. This way the `SUIDetailViewController` would make a seperate card for each item in the `ForEach` so that I could have a dynamic number of cards. Here's an example of how the initializer uses the `@ListViewBuilder`:

```swift
struct HScrollCardView: UIViewControllerRepresentable {
    let currentPage: Int
    let views: [any View]
    
    init(currentPage: Int = 0, @ListViewBuilder _ views: () -> [any View]) {
        self.currentPage = currentPage
        self.views = views()
    }
    
    func makeUIViewController(context: Context) -> SUIDetailViewController {
        let vc = SUIDetailViewController()
        vc.views = views
        vc.currentPage = currentPage
        return vc
    }
    
    func updateUIViewController(_ uiViewController: SUIDetailViewController, context: Context) {
        
    }
}
```

The key detail here is the `@ListViewBuilder` in the `init`. This is what actually makes us able to capture the `views` in a list use the trailing closure syntax.

However, to get the desired behavior of seperating each item from the `ForEach` into their own separate views, we need to make our own `@resultBuiler`. Here's what mine looks like:

```swift
@resultBuilder
enum ListViewBuilder {
    static func buildEither(first component: [any View]) -> [any View] {
        return component
    }
    
    static func buildEither(second component: [any View]) -> [any View] {
        return component
    }
    
    static func buildOptional(_ component: [any View]?) -> [any View] {
        return component ?? []
    }
    
    static func buildExpression&lt;T>(_ expression: T) -> [any View] where T: View {
        return [expression]
    }
    
    static func buildExpression&lt;Data, RowContent>(_ expression: ForEach&lt;Data, Data.Element, RowContent>) -> [any View] where Data : RandomAccessCollection, RowContent : View {
        return expression.data.map(expression.content)
    }
    
    static func buildExpression&lt;Data, RowContent>(_ expression: ForEach&lt;Data, Data.Element.ID, RowContent>) -> [any View] where Data : RandomAccessCollection, Data.Element : Identifiable, RowContent : View {
        return expression.data.map(expression.content)
    }
    
    static func buildExpression(_ expression: ()) -> [any View] {
        return []
    }

    static func buildBlock(_ views: [any View]...) -> [any View] {
        return views.flatMap { $0 }
    }
}
```

The main factors that enable this to work are the `buildExpression` functions for the `ForEach`s. If we only had the one 

```swift
static func buildExpression&lt;T>(_ expression: T) -> [any View] where T: View {
    return [expression]
}
```
then our builder wouldn't be able to extract each view individually from the `ForEach`, so that's where the 

```swift
static func buildExpression&lt;Data, RowContent>(_ expression: ForEach&lt;Data, Data.Element, RowContent>) -> [any View] where Data : RandomAccessCollection, RowContent : View {
    return expression.data.map(expression.content)
}

static func buildExpression&lt;Data, RowContent>(_ expression: ForEach&lt;Data, Data.Element.ID, RowContent>) -> [any View] where Data : RandomAccessCollection, Data.Element : Identifiable, RowContent : View {
    return expression.data.map(expression.content)
}

static func buildBlock(_ views: [any View]...) -> [any View] {
    return views.flatMap { $0 }
}
```

comes in and allows this functionality. This was only necessary for my example specifically because I wanted to seperate each element into it's own view.

And that's mostly it. A pretty tame use of `@resultBuilder` but I found the end result interesting. It's always fun to play with Swift and bend the rules of how we think about things.
