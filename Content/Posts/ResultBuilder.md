---
layout: CustomPost
tags: Swift, Post
image: TODO: PUT IMAGE HERE
lastModified: 2024-04-08
published: false
---
# Using @resultBuilder to Interface SwiftUI with UIKit

Before getting into this, I strongly recommend watching [this](https://developer.apple.com/videos/play/wwdc2021/10253/) WWDC video about `@resultBuilder` and DSL's in Swift. I'm by no means an expert in this topic, but I have founds something that I think is cool that result builders can do.

### The Original Code

This started when I was browing around and I came across [this](https://github.com/sebjvidal/Sports-UI-Demo) repository from Seb Vidal recreating the horizontal scrolling cards from the Apple Sports app. This is awesome but I thought that it would be cool to have a way to interact with this view in a SwiftUI-esque way, to be able to say "I want this horizontal scrolling view with each card representing some view that I *declare* later on" without having to know all of the implementation details of how it works.

### What I did

I do want to say that this may now even be the "best" way to solve this problem, but I find it a fun exploration of Swift's cool language features. I'm not going to show all of the implementation details inside of the `View`s and `ViewController`s because everyones are going to be different and the way they are configured will differ greatly across projects.

Firstly, I had to make some modifications to the `UIView`s and `UIViewController`s so that rather than having the demo views they had would take in an array of `[any View]` and then add them to themselves using a `UIHostingController` when they configure themselves.

Now to get into the fun stuff. I started by writing how I wanted to be able to use this view:

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

In this case, I want things to be *very* similar to how SwiftUI uses @ViewBuilder and `TupleView`, except I want some behavior that's a bit different. Instead of getting one view back from the `ForEach` I wanted to be able to get a seperate view from every iteration of the loop so I could add it to my array of `[any View]` in my `ViewController`. Heres what I mean:

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

The UIViewControllerRepresentable isn't technically needed, it's just and example of how this could work. The key detail here is the `@ListViewBuilder` in the `init`. This is what actually makes us able to capture the `views` in a list use the trailing closure syntax.

To get this to work we need to make our own `@resultBuiler`. Here's what mine looks like:

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

comes in and allows this functionality. This was only necessary for my example specifically because I wanted to seperate each element into it's own view, similar to how `List` and `ScrollView` do in SwiftUI.
