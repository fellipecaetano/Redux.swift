# Redux.swift

[![Version](https://img.shields.io/cocoapods/v/Redux.swift.svg?style=flat)](http://cocoapods.org/pods/Redux.swift)
[![License](https://img.shields.io/cocoapods/l/Redux.swift.svg?style=flat)](http://cocoapods.org/pods/Redux.swift)
[![Platform](https://img.shields.io/cocoapods/p/Redux.swift.svg?style=flat)](http://cocoapods.org/pods/Redux.swift)

Redux.swift is an implementation of a predictable state container, written in Swift. Inspired by [Redux](http://redux.js.org) and [ReSwift](https://github.com/ReSwift/ReSwift), it aims to enforce separation of concerns and a unidirectional data flow by keeping your entire app state in a single data structure that cannot be mutated directly, instead relying on an action dispatch mechanism to describe changes.

## Contents

- [Principles](#principles)
- [Usage](#usage)
- [Example](#example)
- [Testing](#testing)
- [Requirements](#requirements)
- [Installation](#installation)
- [Disclaimer](#disclaimer)
- [Acknowledgements](#acknowledgements)
- [Author](#author)
- [License](#license)

## Principles

- **Single source of truth**: the state of your whole application is stored in a single hierarchical data structure. This makes it easier to reason about state at any given point in time, simplifies state persistence and improves code readability since it's trivial to derive definitions for each branch of your state tree.
- **State is read-only**: state can only be mutated through dispatched **actions**, lightweight objects that describe what should be changed. Since mutations are centralized, inconsistencies are infrequent and race-conditions become easier to avoid.
- **Mutations are applied by pure functions**: actions are only descriptors of changes. The actual logic that determines how those changes are applied is performed by pure functions called **reducers**, which receive the current snapshot of a state branch and an action, and return a new snapshot of how the state should look after the change.

## Usage

Your app's **state** would ideally be defined as a lightweight `struct`:

```swift
struct CounterState {
    let counter: Int
}
```

As an example, operations that users might perform within your app would be described as **actions**:

```swift
struct IncrementAction: Action {
    let increment: Int
}
```

Then you would define a **store**, a data structure used to hold and safeguard your state. This store will receive dispatched actions and call your reducers to transform state based on those actions. A typical application would define only one store and hold it in memory for its lifetime:

```swift
let store = Store<CounterState>(initialState: CounterState(counter: 0)) { state, action in
    // ...
}
```

Actions describe *what* should change, but **reducers** decide *how* those changes will be applied:

```swift
let store = Store<CounterState>(initialState: CounterState(counter: 0)) { state, action in
    switch action {
    case let action as IncrementAction:
        return CounterState(counter: state.counter + action.increment)

    default:
        return state
    }
}
```

Actions are dispatched through the store, and resulting changes are propagated to **subscribers**:

```swift
let _ = store.subscribe { newState in
    // UI updates etc.
}

store.dispatch(IncrementAction(increment: 3))
```

Lastly, subscribers should **unsubscribe** when appropriate:

```swift
let unsubscribe = store.subscribe { //... }

// ...

unsubscribe()

```

## Example

Inside the `Example` directory you will find a sample application that presents a counter, which can be manipulated by increment and decrement buttons. To run it:

1. Clone the repository
2. Enter the `Example` directory
3. Run `carthage update --platform iOS`
4. Open `Example.xcodeproj` in Xcode
5. Select the `Example` target in the target selection dropdown near the Stop button
6. Build and run the application

## Testing

To run tests against the library:

1. Clone the repository
3. Open `Redux.xcworkspace` in Xcode
4. Select the `Redux` target in the target selection dropdown near the `Stop` button
5. Press `⌘U` or click `Test` from the `Product` menu

## Requirements

- iOS 9.0+
- Xcode 8.0+

## Installation

### CocoaPods

Redux.swift is available through [CocoaPods](http://cocoapods.org), a dependency manager for Cocoa projects. CocoaPods can be downloaded as a stand-alone app and can also be installed through [RubyGems](https://rubygems.org/):

```bash
$ gem install cocoapods
```

To integrate Redux.swift into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
target '<target_name>' do
  pod 'Redux.swift'
end
```

Then, install your dependencies through the CocoaPods app or by running the following command in the same directory as your `Podfile`:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following commands:

```bash
$ brew update
$ brew install carthage
```

To integrate Redux.swift into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "fellipecaetano/Redux.swift"
```

Run `carthage update` to build the framework and drag the built `Redux.framework` into your Xcode project.

### Swift Package Manager

You can integrate Redux.swift into your project through Swift Package Manager

#### Xcode 11 or later

To integrate Redux.swift directly from Xcode, go to:
`File > Swift Packages > Add Package Dependency` 

#### Before Xcode 11

Create `Package.swift` file.

```swift
// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "YourProject",
    dependencies: [
        .package(url: "https://github.com/fellipecaetano/Redux.swift.git", from: "6.0.0")
    ],
    targets: [
        .target("YourProject", dependencies: ["Redux"])
    ]
)
```

```bash
$ swift build
```

## Disclaimer

Redux.swift is very small and I strived for clarity when writing it, so hopefully the whole code can be easily understood. It is not meant to be a comprehensive translation of Redux, nor do I want it to replace mature and solid projects such as ReSwift. It is rather an experiment and an exercise, and I hope you will have as much fun using it as I did writing it.

## Acknowledgements

- [Dan Abramov](http://twitter.com/dan_abramov) and the team behind [Redux](http://redux.js.org)
- [Benjamin Encz](http://www.benjamin-encz.de/) and the team behind [ReSwift](https://github.com/ReSwift/ReSwift)

## Author

Fellipe Caetano, fellipe.caetano4@gmail.com

## License

Redux.swift is available under the MIT license. See the LICENSE file for more info.
