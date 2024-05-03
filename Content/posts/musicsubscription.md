---
layout: CustomPost
tags: Swift, Post
image: /images/photos/musickit.jpg
lastModified: 2024-04-09
---
# Offering MusicKit Subscriptions

I've been building a project lately that makes use of MusicKit, and something that I've found is important to consider is offering a way to offer a subscription to users at the right time. The complete code can be found at the end.

### The Challenge

The main challenge is that offering a subscriptions requires the management of a number of properties and methods and it can be cumbersome to have to repeat this process in more than one place. Here's one way that this can be done:

```swift
struct MyView: View {
    @State private var musicSubscription: MusicSubscription?
    @State private var isShowingSubscriptionOffer = false
    @State private var subscriptionOfferOptions: MusicSubscriptionOffer.Options = .default
    
    private var shouldOfferSubscription: Bool {
        let canBecomeSubscriber = musicSubscription?.canBecomeSubscriber ?? false
        return canBecomeSubscriber
    }
    
    public var body: some View {
        SomeView()
            .task {
                for await subscription in MusicSubscription.subscriptionUpdates {
                    musicSubscription = subscription
                }
            }
            .musicSubscriptionOffer(isPresented: $isShowingSubscriptionOffer, options: subscriptionOfferOptions)
    }
    
    /// Computes the presentation state for a subscription offer.
    private func handleSubscriptionOfferSelected() {
        isShowingSubscriptionOffer = true
    }
}
```

Of course there's more that can be done here and is ommitted for demonstration, but the general idea is that there's a lot going on here so it would definitely be nice to have a more reusable way to get access to the same options. The above code is perfectly fine, but we like to build cool things.

### Cool Solution

The idea is to have a way to easily offer a subscription to a user without having to repeat code, plus we want a solution that looks cool to use. Here's what I wanted to be able to do:

```swift
SubscriptionOfferableView {
    SomeView()
}
```
or
```swift
SomeView()
    .canOfferSubscription()
```
Basically something that doesn't take any extra effort to use but is also easy to understand what's going on. So to start I defined the general properties and the `struct` that I'd need to make this happen

```swift
public struct SubscriptionOfferableView&lt;Content: View>: View {
    private let content: Content
    
    @State private var musicSubscription: MusicSubscription?
    @State private var isShowingSubscriptionOffer = false
    @State private var subscriptionOfferOptions: MusicSubscriptionOffer.Options = .default
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    private var shouldOfferSubscription: Bool {
        let canBecomeSubscriber = musicSubscription?.canBecomeSubscriber ?? false
        return canBecomeSubscriber
    }
    
    public var body: some View {
        Group {
            if shouldOfferSubscription {
                content
                    .onTapGesture(perform: handleSubscriptionOfferSelected)
            } else {
                content
            }
        }
        .task {
            for await subscription in MusicSubscription.subscriptionUpdates {
                musicSubscription = subscription
            }
        }
        .musicSubscriptionOffer(isPresented: $isShowingSubscriptionOffer, options: subscriptionOfferOptions)
    }
    
    /// Computes the presentation state for a subscription offer.
    private func handleSubscriptionOfferSelected() {
        isShowingSubscriptionOffer = true
    }
}
```

This is good but there's a few extra things that we can add to make it work better with `MusicKit`. It would be nice to have a way to disable the underlying content so that the UI can reflect this state, and it would also be nice to pass additional information to `MusisKit` like the ID and type of item we are presenting the subscription offer from. So I add a few properties:

```swift
private let itemID: MusicItemID?
private let messageIdentifier: MusicSubscriptionOffer.MessageIdentifier

private var disabled = false

```

I also updated the `init`

```swift
init(
    itemID: MusicItemID? = nil,
    messageIdentifier: MusicSubscriptionOffer.MessageIdentifier = .join,
    @ViewBuilder content: () -> Content
) {
    self.itemID = itemID
    self.messageIdentifier = messageIdentifier
    self.content = content()
}
```

Updated the `body`

```swift
Group {
    if shouldOfferSubscription {
        content
            .disabled(disabled)
            .onTapGesture(perform: handleSubscriptionOfferSelected)
    } else {
        content
    }
}
.task {
    for await subscription in MusicSubscription.subscriptionUpdates {
        musicSubscription = subscription
    }
}
.musicSubscriptionOffer(isPresented: $isShowingSubscriptionOffer, options: subscriptionOfferOptions)
```

and finally added method for the disabled state and updated the one that handles the offer

```swift
/// Computes the presentation state for a subscription offer.
private func handleSubscriptionOfferSelected() {
    subscriptionOfferOptions.messageIdentifier = messageIdentifier
    subscriptionOfferOptions.itemID = itemID
    isShowingSubscriptionOffer = true
}

/// Can disable the underlying content if a subsription should be offered.
/// - Parameter disabled: A boolean indicating whether the underlying content is disabled or not.
/// - Returns: `SubscriptionOfferableView`
public func contentDisabled(_ disabled: Bool = true) -> SubscriptionOfferableView {
    var view = self
    view.disabled = disabled
    return view
}
```

And to use it as a view modifier

```swift
public struct SubscriptionOfferableModifier: ViewModifier {
    let itemID: MusicItemID?
    let messageIdentifier: MusicSubscriptionOffer.MessageIdentifier
    let disableContent: Bool
    
    public func body(content: Content) -> some View {
        SubscriptionOfferableView(itemID: itemID, messageIdentifier: messageIdentifier) {
            content
        }
        .contentDisabled(disableContent)
    }
}

extension View {
    public func canOfferSubscription(
        for itemID: MusicItemID? = nil,
        messageIdentifier: MusicSubscriptionOffer.MessageIdentifier = .join,
        disableContent: Bool = false
    ) -> some View {
        modifier(SubscriptionOfferableModifier(itemID: itemID, messageIdentifier: messageIdentifier, disableContent: disableContent))
    }
}
```

So that's it, this isn't an Earth-shattering discovery by any means but it's definitely a nice way to present subscription offers in app.

Here is the completed version

```swift
public struct SubscriptionOfferableView&lt;Content: View>: View {
    private let itemID: MusicItemID?
    private let messageIdentifier: MusicSubscriptionOffer.MessageIdentifier
    private let content: Content
    
    @State private var musicSubscription: MusicSubscription?
    @State private var isShowingSubscriptionOffer = false
    @State private var subscriptionOfferOptions: MusicSubscriptionOffer.Options = .default
    
    private var disabled = false
    
    init(
        itemID: MusicItemID? = nil,
        messageIdentifier: MusicSubscriptionOffer.MessageIdentifier = .join,
        @ViewBuilder content: () -> Content
    ) {
        self.itemID = itemID
        self.messageIdentifier = messageIdentifier
        self.content = content()
    }
    
    private var shouldOfferSubscription: Bool {
        let canBecomeSubscriber = musicSubscription?.canBecomeSubscriber ?? false
        return canBecomeSubscriber
    }
    
    public var body: some View {
        Group {
            if shouldOfferSubscription {
                content
                    .disabled(disabled)
                    .onTapGesture(perform: handleSubscriptionOfferSelected)
            } else {
                content
            }
        }
        .task {
            for await subscription in MusicSubscription.subscriptionUpdates {
                musicSubscription = subscription
            }
        }
        .musicSubscriptionOffer(isPresented: $isShowingSubscriptionOffer, options: subscriptionOfferOptions)
    }
    
    /// Computes the presentation state for a subscription offer.
    private func handleSubscriptionOfferSelected() {
        subscriptionOfferOptions.messageIdentifier = messageIdentifier
        subscriptionOfferOptions.itemID = itemID
        isShowingSubscriptionOffer = true
    }
    
    /// Can disable the underlying content if a subsription should be offered.
    /// - Parameter disabled: A boolean indicating whether the underlying content is disabled or not.
    /// - Returns: `SubscriptionOfferableView`
    public func contentDisabled(_ disabled: Bool = true) -> SubscriptionOfferableView {
        var view = self
        view.disabled = disabled
        return view
    }
}

public struct SubscriptionOfferableModifier: ViewModifier {
    let itemID: MusicItemID?
    let messageIdentifier: MusicSubscriptionOffer.MessageIdentifier
    let disableContent: Bool
    
    public func body(content: Content) -> some View {
        SubscriptionOfferableView(itemID: itemID, messageIdentifier: messageIdentifier) {
            content
        }
        .contentDisabled(disableContent)
    }
}

extension View {
    public func canOfferSubscription(
        for itemID: MusicItemID? = nil,
        messageIdentifier: MusicSubscriptionOffer.MessageIdentifier = .join,
        disableContent: Bool = false
    ) -> some View {
        modifier(SubscriptionOfferableModifier(itemID: itemID, messageIdentifier: messageIdentifier, disableContent: disableContent))
    }
}
```
