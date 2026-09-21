import SwiftUI

/// Property wrapper matching Point-Free’s public `@LazyState` / `LazyState { … }` shape.
///
/// Backed by SwiftUI’s public, undocumented `LazyState` type (iOS 17+). That is the
/// same storage the `@State` macro uses for lazy, once-per-identity initialization.
/// Unlike `@State`, it is valid to create this wrapper in a view `init` from parent
/// data — the thunk is not run until the value is first read, and it is not run again
/// while the view’s identity stays alive.
///
/// See: https://www.pointfree.co/blog/posts/223-beta-preview-lazystate
@propertyWrapper
struct LazyState<Value>: DynamicProperty {
    private var storage: SwiftUI.LazyState<Value>

    /// Point-Free / SwiftUI shape: `_model = LazyState { Model(from: parent) }`.
    init(_ thunk: @escaping () -> Value) {
        storage = SwiftUI.LazyState(initialValue: thunk)
    }

    var wrappedValue: Value {
        get { storage.wrappedValue }
        nonmutating set { storage.wrappedValue = newValue }
    }

    var projectedValue: Binding<Value> {
        storage.projectedValue
    }
}
