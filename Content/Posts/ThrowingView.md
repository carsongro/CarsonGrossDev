---
layout: CustomPost
tags: Swift, Post
image: /images/photos/errorstate.png
lastModified: 2024-04-08
---
# Simple Retry Error State View For SwiftUI

This is about a relatively simple view that I use for showing a "retry" error state when making a network request to get some data for a view. I'll walk through the problem that I'm aiming to solve in my projects, then show how I solved it using what I call a `ThrowingView`. The complete code can be found at the bottom of the page.

### The Problem

A common pattern that I've come across when building things in SwiftUI is when a view appears, I fetch data, and if that request (often a network request) fails, then I'd like to show some sort of error state to the users and have an option to retry as well. 

### The Current Approach

One way to approach this solution is to have some sort of boolean property capable of updating a view (Typically `@State` or a property in an `@Observable` object) that can be set to true to show the error state, then I make a network request and if the request fail, in the `catch` block I can set the property to true and show some sort of error view. In iOS 17 `ContentUnavailableView` make this process very nice. It may look something like this:

```swift
@State private var showingErrorState = false

var body: some View {
    if showingErrorState {
        ContentUnavailableView {
            Label("No Data", systemImage: "exclamationmark.circle.fill")
        } actions: {
            Button("Refresh", action: fetchData)
        }
    } else {
        SomeView()
            .onAppear(perform: fetchData)
    }
}

func fetchData() {
    Task {
        do {
            try await makeNetworkRequest()
            showingErrorState = false
        } catch {
            showingErrorState = true
        }
    }
}
```

And this code is perfectly fine, but if there are multiple views throughout the app that can have a view that doesn't display data because of a failed network request, rewriting the `@State` property and the `do` `catch` can get a bit repetitive. For me personally when something is repetitive like this I'm more likely not to do it, but handling error states is very important to the user experience so I made an easy to use solution I don't have an excuse to skip it.

### Solution

I wanted to make something that felt relatively familiar, so I started with defining a `Throwing View` in a very similar way as `ContentUnavailableView`.

```swift
public struct ThrowingView&lt;Content, Label, Description>: View where Content: View, Label : View, Description : View {
    @ViewBuilder private let content: Content
    @ViewBuilder private let label: () -> Label
    @ViewBuilder private let description: () -> Description
    @ViewBuilder private let operation: @Sendable () async throws -> Void
    
    public init(
        @ViewBuilder _ content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder description: @escaping () -> Description = { EmptyView() },
        operation: @escaping @Sendable () async throws -> Void
    ) {
        self.content = content()
        self.label = label
        self.description = description
        self.operation = operation
    }
    
    public var body: some View {
        // More to come...
    }
}
``` 

But there are some differences, mainly the addition of `content` and `operation`. In this case `content` is what will be shown when there is no failure, and `operation` is the work that can fail. But now we need the code that actually does the work and shows the error when it fails, so we add

```swift
@State private var showErrorState = false
```

as a property and then modify the content of the body

```swift
public var body: some View {
    if showErrorState {
        ContentUnavailableView(label: label, description: description) {
            Button("Retry", action: doOperation)
                .padding(6)
                .foregroundStyle(.secondary)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.secondary)
                )
        }
    } else {
        content
            .onAppear(perform: doOperation)
    }
}
```

and finally we need to define the function that does the work

```swift
private func doOperation() {
    Task {
        do {
            try await operation()
            showErrorState = false
        } catch {
            print(error.localizedDescription)
            showErrorState = true
        }
    }
}
```

Now we can use it in our other views! Our original example now looks like this:

```swift
var body: some View {
    ThrowingView {
        SomeView()
    } label: {
        Text("Error")
    } description: {
        Text("There was an error loading this page")
    } operation: {
        try await makeNetworkRequest()
    }
}
```

This is nice, and we can also make it a `ViewModifer` too

```swift
public struct ThrowingViewModifier&lt;Label, Description>: ViewModifier where Label : View, Description : View {
    @ViewBuilder private let label: () -> Label
    @ViewBuilder private let description: () -> Description
    @ViewBuilder private let operation: @Sendable () async throws -> Void
    
    public init(
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder description: @escaping () -> Description = { EmptyView() },
        operation: @escaping @Sendable () async throws -> Void
    ) {
        self.label = label
        self.description = description
        self.operation = operation
    }
    
    public func body(content: Content) -> some View  {
        ThrowingView {
            content
        } label: {
            label()
        } description: {
            description()
        } operation: {
            try await operation()
        }
    }
}

extension View {
    public func throwingView&lt;Label, Description>(
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder description: @escaping () -> Description = { EmptyView() },
        operation: @escaping @Sendable () async throws -> Void
    ) -> some View where Label : View, Description : View {
        modifier(ThrowingViewModifier(label: label, description: description, operation: operation))
    }
}
```

So now we could also use it like this

```swift
var body: some View {
    SomeView()
        .throwingView {
            Text("Error")
        } description: {
            Text("There was an error loading this page")
        } operation: {
            try await makeNetworkRequest()
        }
}
```

A little weird at the call sight, but it works!

### Complete Code

It may need to be tweaked a bit to suit other projects or needs, especially if you wish to have multiple actions besides just a single retry button.

```swift
public struct ThrowingView&lt;Content, Label, Description>: View where Content: View, Label : View, Description : View {
    @ViewBuilder private let content: Content
    @ViewBuilder private let label: () -> Label
    @ViewBuilder private let description: () -> Description
    @ViewBuilder private let operation: @Sendable () async throws -> Void
    
    @State private var showErrorState = false
    
    /// Creates an interface, consisting of a label and additional content, that you
    /// display when the content of your app is unavailable to users. When the content
    /// is available, it displays the default content.
    ///
    /// - Parameters:
    ///   - content: The content that is displayed without and error.
    ///   - label: The label that describes the view.
    ///   - description: The view that describes the interface.
    ///   - operation: The operation to perform in `onAppear` and retried when the button is pressed.
    public init(
        @ViewBuilder _ content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder description: @escaping () -> Description = { EmptyView() },
        operation: @escaping @Sendable () async throws -> Void
    ) {
        self.content = content()
        self.label = label
        self.description = description
        self.operation = operation
    }
    
    public var body: some View {
        if showErrorState {
            ContentUnavailableView(label: label, description: description) {
                Button("Retry", action: doOperation)
                    .padding(6)
                    .foregroundStyle(.secondary)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(.secondary)
                    )
            }
        } else {
            content
                .onAppear(perform: doOperation)
        }
    }
    
    private func doOperation() {
        Task {
            do {
                try await operation()
                showErrorState = false
            } catch {
                print(error.localizedDescription)
                showErrorState = true
            }
        }
    }
}

public struct ThrowingViewModifier&lt;Label, Description>: ViewModifier where Label : View, Description : View {
    @ViewBuilder private let label: () -> Label
    @ViewBuilder private let description: () -> Description
    @ViewBuilder private let operation: @Sendable () async throws -> Void
    
    /// Creates an interface, consisting of a label and additional content, that you
    /// display when the content of your app is unavailable to users. When the content
    /// is available, it displays the default content.
    ///
    /// - Parameters:
    ///   - label: The label that describes the view.
    ///   - description: The view that describes the interface.
    ///   - operation: The operation to perform in `onAppear` and retried when the button is pressed.
    public init(
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder description: @escaping () -> Description = { EmptyView() },
        operation: @escaping @Sendable () async throws -> Void
    ) {
        self.label = label
        self.description = description
        self.operation = operation
    }
    
    public func body(content: Content) -> some View  {
        ThrowingView {
            content
        } label: {
            label()
        } description: {
            description()
        } operation: {
            try await operation()
        }
    }
}

extension View {
    public func throwingView&lt;Label, Description>(
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder description: @escaping () -> Description = { EmptyView() },
        operation: @escaping @Sendable () async throws -> Void
    ) -> some View where Label : View, Description : View {
        modifier(ThrowingViewModifier(label: label, description: description, operation: operation))
    }
}

#Preview {
    enum PreviewError: Error {
        case error
    }
    
    return Color.clear
        .throwingView {
            Text("Error")
        } description: {
            Text("There was an error loading this page")
        } operation: {
            throw PreviewError.error
        }
}

#Preview {
    enum PreviewError: Error {
        case error
    }
    
    return ThrowingView {
        Color.clear
    } label: {
        Text("Error")
    } description: {
        Text("There was an error loading this page")
    } operation: {
        throw PreviewError.error
    }
}
```
