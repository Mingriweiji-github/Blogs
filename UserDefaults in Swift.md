# UserDefaults in Swift

In this article we’ll cover:

- What is `UserDefaults`?
- What kind of data should we save to `UserDefaults`?
- How `UserDefaults` is implemented internally?
- Design type-safe key-value storage, based on `UserDefaults` and Swift property wrappers.
- Observe `UserDefaults` value changes.

## UserDefaults Overview

`UserDefaults` manages the persistent storage of key-value pairs in a `.plist` file.

`UserDefaults` storage is limited to the so-called property-list data types [[1\]](https://developer.apple.com/library/archive/documentation/General/Conceptual/DevPedia-CocoaCore/PropertyList.html): `Data`, `String`, `Date`, `Bool`, `Int`, `Double`, `Float`, `Array`, `Dictionary` and `URL` (the only non-property-list-type). It is also possible to store arbitrary objects by encoding them into a `Data` object first.

> Here is the full list of supported types from the `UserDefaults` source code: [common Swift types](https://github.com/apple/swift-corelibs-foundation/blob/ef6f96ee82ea0f54252071c0ecadf5f01be9aecc/Foundation/UserDefaults.swift#L58), [uncommon Swift types](https://github.com/apple/swift-corelibs-foundation/blob/ef6f96ee82ea0f54252071c0ecadf5f01be9aecc/Foundation/UserDefaults.swift#L63), [NS- / CF- bridging types](https://github.com/apple/swift-corelibs-foundation/blob/e49beda4e4bd49e8ab541015d78b82a0a1957bc5/Foundation/Bridging.swift), plus `NSNumber` (non-bridging, but still supported).

There is no hard limit on the size of data that we can store to `UserDefaults`, except for the [1MB on tvOS](https://developer.apple.com/documentation/foundation/userdefaults/1617187-sizelimitexceedednotification).

Nonetheless, it is not recommended to store large chunks of data, because reads and writes become more expensive the more data `UserDefaults` contains. The reason for that is that the defaults use a single `.plist` file per domain (and typically per app), which becomes bloated if we store big chunks of data there.

It is also not recommended to store custom objects for the following reasons:

- Arbitrary data types must be archived and unarchived to and from `Data`, which is expensive.
- Arbitrary data types will likely become incompatible with newer versions of your app.

According to Apple, the best approach to `UserDefaults` is to store user preferences and app configuration as simple values [[1\]](https://developer.apple.com/documentation/foundation/userdefaults), [[2\]](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/UserDefaults/Introduction/Introduction.html#//apple_ref/doc/uid/10000059i).

## UserDefaults Internal Structure

Let’s dig into [swift-corelibs-foundation](https://github.com/apple/swift-corelibs-foundation) to find out how `UserDefaults` works behind the scenes.

`UserDefaults` saves data on a per-domain basis. This means that each domain has a corresponding `.plist` file, where the associated data is persisted.

*Domain* is just a plain string. If you peek into `UserDefaults` internals, you’ll discover that it’s [also called suite](https://github.com/apple/swift-corelibs-foundation/blob/ef6f96ee82ea0f54252071c0ecadf5f01be9aecc/Foundation/UserDefaults.swift#L87). Both names refer to the same concept, so we’ll continue calling it *domain*.

By default, every app [has 8 domains](https://github.com/apple/swift-corelibs-foundation/blob/155f1ce1965effe55289477507a6f9fbdc8fe333/CoreFoundation/Preferences.subproj/CFApplicationPreferences.c#L422), which are organized into the so-called search list. The search list is initialized when we read or write values [for the first time](https://github.com/apple/swift-corelibs-foundation/blob/155f1ce1965effe55289477507a6f9fbdc8fe333/CoreFoundation/Preferences.subproj/CFApplicationPreferences.c#L437.). We are free to add more domains if we want more granular control over `UserDefaults` storage.

The domains from the search list are [merged into a single dictionary](https://github.com/apple/swift-corelibs-foundation/blob/155f1ce1965effe55289477507a6f9fbdc8fe333/CoreFoundation/Preferences.subproj/CFApplicationPreferences.c#L265), which is an expensive operation. The dictionary is re-computed each time the value is added, updated or removed from the user defaults. This gives us another insight about the user defaults performance:

> `UserDefaults` performs best when the writes are rare and reads are frequent.

When we [set a value](https://github.com/apple/swift-corelibs-foundation/blob/ef6f96ee82ea0f54252071c0ecadf5f01be9aecc/Foundation/UserDefaults.swift#L128) to `UserDefaults`, it calls [_CFApplicationPreferencesSet](https://github.com/apple/swift-corelibs-foundation/blob/155f1ce1965effe55289477507a6f9fbdc8fe333/CoreFoundation/Preferences.subproj/CFApplicationPreferences.c#L326) from [CFApplicationPreferences.c](https://github.com/apple/swift-corelibs-foundation/blob/155f1ce1965effe55289477507a6f9fbdc8fe333/CoreFoundation/Preferences.subproj/CFApplicationPreferences.c), which is a bunch of scary C code with some comments dated [1999](https://github.com/apple/swift-corelibs-foundation/blob/155f1ce1965effe55289477507a6f9fbdc8fe333/CoreFoundation/Preferences.subproj/CFApplicationPreferences.c#L334). `CFApplicationPreferences` manages the dictionary representation of user defaults across all registered domains with some caching involved.

The app preferences delegate per-domain work to [CFPreferences.c](https://github.com/apple/swift-corelibs-foundation/blob/fff248991adb386b1a16d94d0e2eacd5d08d76af/CoreFoundation/Preferences.subproj/CFPreferences.c). It [reads and writes XML files to the disk](https://github.com/apple/swift-corelibs-foundation/blob/ef6f96ee82ea0f54252071c0ecadf5f01be9aecc/CoreFoundation/Preferences.subproj/CFXMLPreferencesDomain.c#L48) and does the caching.

> `UserDefaults` has two levels of caching: the domain level and the app level.

## Implementing Key-Value Storage

Now that we know what is `UserDefaults`, let’s do some actual work and implement key-value storage, based on `UserDefaults` and property wrappers.

> The current section requires basic understanding of property wrappers. I recommend reading [The Complete Guide to Property Wrappers in Swift 5](https://www.vadimbulavin.com/swift-5-property-wrappers/) to get yourself up to speed.

First, let’s implement a wrapper, which saves and loads values to and from `UserDefaults`:

```
@propertyWrapper
struct UserDefault<T: PropertyListValue> {
    let key: Key

    var wrappedValue: T? {
        get { UserDefaults.standard.value(forKey: key.rawValue) as? T }
        set { UserDefaults.standard.set(newValue, forKey: key.rawValue) }
    }
}
```

Notice that we are constraining `T` to be of `PropertyListValue` type. It is the marker protocol for all property-list data types:

> This code is inspired by the `UserDefault` implementation from [Burritos](https://github.com/guillermomuntaner/Burritos/tree/master/Sources/UserDefault).

```
// The marker protocol
protocol PropertyListValue {}

extension Data: PropertyListValue {}
extension String: PropertyListValue {}
extension Date: PropertyListValue {}
extension Bool: PropertyListValue {}
extension Int: PropertyListValue {}
extension Double: PropertyListValue {}
extension Float: PropertyListValue {}

// Every element must be a property-list type
extension Array: PropertyListValue where Element: PropertyListValue {}
extension Dictionary: PropertyListValue where Key == String, Value: PropertyListValue {}
```

The `UserDefault` wrapper uses statically typed keys, declared as follows:

```
struct Key: RawRepresentable {
    let rawValue: String
}

extension Key: ExpressibleByStringLiteral {
    init(stringLiteral: String) {
        rawValue = stringLiteral
    }
}
```

The new keys can be conveniently declared in an extension:

```
extension Key {
    static let isFirstLaunch: Key = "isFirstLaunch"
}
```

`Storage` is a thin abstraction layer on top of `UserDefaults`:

```
struct Storage {
    @UserDefault(key: .isFirstLaunch)
    var isFirstLaunch: Bool
}
```

We can use `Storage` as follows:

```
var storage = Storage()

storage.isFirstLaunch = true
print(storage.isFirstLaunch) // true
```

## Observing UserDefaults Value Changes

Since `UserDefaults` typically represent system-wide preferences, it’s common to respond to their changes from different parts of your app. In this section let’s extend the `UserDefault` property wrapper to allow observation of value changes.

We begin by implementing `DefaultsObservation`, which listens to `UserDefaults` changes [via KVO](https://developer.apple.com/documentation/objectivec/nsobject/1412787-addobserver):

```
class DefaultsObservation: NSObject {
    let key: Key
    private var onChange: (Any, Any) -> Void

    // 1
    init(key: Key, onChange: @escaping (Any, Any) -> Void) {
        self.onChange = onChange
        self.key = key
        super.init()
        UserDefaults.standard.addObserver(self, forKeyPath: key.rawValue, options: [.old, .new], context: nil)
    }
    
    // 2
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let change = change, object != nil, keyPath == key.rawValue else { return }
        onChange(change[.oldKey] as Any, change[.newKey] as Any)
    }
    
    // 3
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: key.rawValue, context: nil)
    }
}
```

1. The observation accepts a type-safe `Key` and an `onChange` callback. It eagerly begins listening to the `UserDefaults` value changes, specified by the key.
2. The `observeValue()` method is called by the KVO system automatically, when the value, specified by the `key`, is changed. The method accepts a `change` dictionary, from where we extract the old and new values and pass them to the `onChange` callback.
3. Unsubscribe from KVO when the observation is deallocated.

We add the new method `observe()` to the property wrapper, which returns an instance of observation. To be able to call it from the outside of `Storage`, we expose the wrapper type itself via the `projectedValue`:

```
@propertyWrapper
struct UserDefault<T: PropertyListValue> {
    var projectedValue: UserDefault<T> { return self }
    
    func observe(change: @escaping (T?, T?) -> Void) -> NSObject {
        return DefaultsObservation(key: key) { old, new in
            change(old as? T, new as? T)
        }
    }

    // The rest of the code is unchanged
}
```

Now we can subscribe to `UserDefaults` changes like this:

```
var storage = Storage()

var observation = storage.$isFirstLaunch.observe { old, new in
    print(old, new)
}

storage.isFirstLaunch = false

// Prints `nil false`
```

## Summary

Here are the key things to remember about `UserDefaults`:

- `UserDefaults` is built around dictionaries and `.plist` files.
- `UserDefaults` is best suited for small subsets of data and simple data types.
- `UserDefaults` performs best when the writes are rare and the reads are frequent.

Swift 5 is the game-changer for `UserDefaults`. With the help of property wrappers, we’ve designed type-safe key-value storage, which allows us to observe value changes.



Github:https://github.com/GesanTung/iOSTips