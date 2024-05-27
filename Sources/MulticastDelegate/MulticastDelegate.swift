import Foundation
import os.lock

/// Holds a collection of *weak* delegates and call all of them when invoked.
public struct MulticastDelegate<T>: Sendable {
  
  private struct Delegates {
    let mainDelegate = NSHashTable<AnyObject>.weakObjects()
    let additionalDelegates = NSHashTable<AnyObject>.weakObjects()
  }
  
  private let delegates = OSAllocatedUnfairLock(uncheckedState: Delegates())
  
  /// The main delegate.
  public var mainDelegate: T? {
    delegates.withLock { $0.mainDelegate.allObjects.map { $0 as! T }.first }
  }
  
  /// The additional delegates.
  public var additionalDelegates: [T] {
    delegates.withLock { $0.additionalDelegates.allObjects.map { $0 as! T } }
  }
  
  /// Invokes all delegates, including the main and additional delegates.
  /// - Parameter action: The action to be performed for all delegates.
  public func invoke(_ action: (T) -> Void) {
    mainDelegate.map { action($0) }
    
    for additionalDelegate in additionalDelegates {
      action(additionalDelegate)
    }
  }
  
  /// Sets the main delegate. If is nil, removes the main delegate.
  /// - Parameter mainDelegate: The main delegate.
  public func set(mainDelegate: T?) {
    delegates.withLock {
      $0.mainDelegate.removeAllObjects()
      
      if let delegate = mainDelegate {
        $0.mainDelegate.add(delegate as AnyObject)
      }
    }
  }
  
  /// Replaces the current additional delegates with another collection of delegates.
  /// - Parameter additionalDelegates: The new additional delegates.
  public func set(additionalDelegates: T...) {
    delegates.withLock {
      $0.additionalDelegates.removeAllObjects()
      for additionalDelegate in additionalDelegates{
        $0.additionalDelegates.add(additionalDelegate as AnyObject)
      }
    }
  }
  
  /// Adds new additional delegates.
  /// - Parameter additionalDelegate: The additional delegate.
  public func add(additionalDelegates: T...) {
    delegates.withLock {
      for additionalDelegate in additionalDelegates {
        $0.additionalDelegates.add(additionalDelegate as AnyObject)
      }
    }
  }
  
  /// Removes delegates from the additional delegates.
  /// - Parameter additionalDelegate: The delegate to be removed.
  public func remove(additionalDelegates: T...) {
    delegates.withLock {
      for additionalDelegate in additionalDelegates {
        $0.additionalDelegates.remove(additionalDelegate as AnyObject)
      }
    }
  }
  
  /// Removes all the delegates
  public func clear() {
    delegates.withLock {
      $0.mainDelegate.removeAllObjects()
      $0.additionalDelegates.removeAllObjects()
    }
  }
}
