# Redux.swift

[![CI Status](http://img.shields.io/travis/fellipecaetano/Redux.swift.svg?style=flat)](https://travis-ci.org/fellipecaetano/Redux.swift)
[![Version](https://img.shields.io/cocoapods/v/Redux.swift.svg?style=flat)](http://cocoapods.org/pods/Redux.swift)
[![License](https://img.shields.io/cocoapods/l/Redux.swift.svg?style=flat)](http://cocoapods.org/pods/Redux.swift)
[![Platform](https://img.shields.io/cocoapods/p/Redux.swift.svg?style=flat)](http://cocoapods.org/pods/Redux.swift)

Redux.swift is an implementation of a predictable state container, written in Swift. Inspired by [Redux](http://redux.js.org) and [ReSwift](https://github.com/ReSwift/ReSwift), it aims to enforce separation of concerns and a unidirectional data flow by keeping your entire app state in a single data structure that cannot be mutated directly, instead relying on an action dispatch mechanism to describe changes.

Redux.swift is very small and I strived for clarity when writing it, so hopefully the whole code can be easily understood. It is not meant to be a comprehensive translation of Redux, nor do I want it to replace mature and solid projects such as ReSwift. It is rather an experiment and an exercise, and I hope you will have as much fun using it as I did writing it.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Redux.swift is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Redux.swift"
```

## Author

Fellipe Caetano, fellipe.caetano4@gmail.com

## License

Redux.swift is available under the MIT license. See the LICENSE file for more info.
