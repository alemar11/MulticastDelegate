import XCTest
@testable import MulticastDelegate

private protocol DispatcherDelegate: AnyObject {
  func didDispatch()
}

private final class Listener: DispatcherDelegate {
  var didDispatch_callsCount = 0
  let closure: () -> Void
  let limit: Int
  
  init(after: Int = 0, closure: (() -> Void)? = nil) {
    self.limit = after
    self.closure = closure ?? { }
  }
  
  func didDispatch() {
    didDispatch_callsCount += 1
    if didDispatch_callsCount >= limit {
      closure()
    }
  }
}

final class MulticastDelegate_Tests: XCTestCase {
  
  func test_ThatMainDelegateIsInvokedCorrectly() {
    let multicastdelegate = MulticastDelegate<DispatcherDelegate>()
    let expectation = self.expectation(description: "\(#function)\(#line)")
    let listener = Listener(after: 1) {
      expectation.fulfill()
    }
    
    multicastdelegate.set(mainDelegate: listener)
    multicastdelegate.invoke { $0.didDispatch() }
    
    waitForExpectations(timeout: 2)
    XCTAssertEqual(listener.didDispatch_callsCount, 1)
  }
  
  func test_ThatTheSameMainDelegateCannotBeAddedMultipleTimes() {
    let multicastdelegate = MulticastDelegate<DispatcherDelegate>()
    let expectation = self.expectation(description: "\(#function)\(#line)")
    let listener = Listener(after: 1) {
      expectation.fulfill()
    }
    
    multicastdelegate.set(mainDelegate: listener)
    multicastdelegate.set(mainDelegate: listener)
    multicastdelegate.set(mainDelegate: listener)
    multicastdelegate.invoke { $0.didDispatch() }
    
    waitForExpectations(timeout: 2)
    XCTAssertEqual(listener.didDispatch_callsCount, 1)
  }
  
  func test_ThatTheSameDelegateCannotBeAddedMultipleTimes() {
    let multicastdelegate = MulticastDelegate<DispatcherDelegate>()
    let expectation = self.expectation(description: "\(#function)\(#line)")
    let listener = Listener(after: 1) {
      expectation.fulfill()
    }
    
    multicastdelegate.add(additionalDelegates: listener)
    multicastdelegate.add(additionalDelegates: listener)
    multicastdelegate.add(additionalDelegates: listener)
    multicastdelegate.invoke { $0.didDispatch() }
    
    waitForExpectations(timeout: 2)
    XCTAssertEqual(multicastdelegate.additionalDelegates.count, 1)
    XCTAssertEqual(listener.didDispatch_callsCount, 1)
  }
  
  func test_ThatMultipleDelegatesAreInvokedCorrectly() {
    let multicastdelegate = MulticastDelegate<DispatcherDelegate>()
    let expectation1 = self.expectation(description: "\(#function)\(#line)")
    let listener1 = Listener(after: 1) {
      expectation1.fulfill()
    }
    
    let expectation2 = self.expectation(description: "\(#function)\(#line)")
    let listener2 = Listener(after: 1) {
      expectation2.fulfill()
    }
    
    let expectation3 = self.expectation(description: "\(#function)\(#line)")
    let listener3 = Listener(after: 1) {
      expectation3.fulfill()
    }
    
    multicastdelegate.add(additionalDelegates: listener1)
    multicastdelegate.add(additionalDelegates: listener2)
    multicastdelegate.add(additionalDelegates: listener3)
    multicastdelegate.invoke { $0.didDispatch() }
    
    waitForExpectations(timeout: 2)
    
    XCTAssertEqual(listener1.didDispatch_callsCount, 1)
    XCTAssertEqual(listener2.didDispatch_callsCount, 1)
    XCTAssertEqual(listener3.didDispatch_callsCount, 1)
  }
  
  func test_ThatRemovedDelegatedAreNotInvoked() {
    let multicastdelegate = MulticastDelegate<DispatcherDelegate>()
    let expectation1 = self.expectation(description: "\(#function)\(#line)")
    let listener1 = Listener(after: 3) {
      expectation1.fulfill()
    }
    
    let expectation2 = self.expectation(description: "\(#function)\(#line)")
    let listener2 = Listener(after: 2) {
      expectation2.fulfill()
    }
    
    let expectation3 = self.expectation(description: "\(#function)\(#line)")
    let listener3 = Listener(after: 1) {
      expectation3.fulfill()
    }
    
    multicastdelegate.add(additionalDelegates: listener1)
    multicastdelegate.add(additionalDelegates: listener2)
    multicastdelegate.add(additionalDelegates: listener3)
    multicastdelegate.invoke { $0.didDispatch() }
    multicastdelegate.remove(additionalDelegates: listener3)
    multicastdelegate.invoke { $0.didDispatch() }
    multicastdelegate.remove(additionalDelegates: listener2)
    multicastdelegate.invoke { $0.didDispatch() }
    
    waitForExpectations(timeout: 2)
    
    XCTAssertEqual(listener1.didDispatch_callsCount, 3)
    XCTAssertEqual(listener2.didDispatch_callsCount, 2)
    XCTAssertEqual(listener3.didDispatch_callsCount, 1)
  }
  
  func test_ThatDelegatesAreInvokedCorrectlyOnceAddedButNotInvokedAfterDeletion() {
    let multicastdelegate = MulticastDelegate<DispatcherDelegate>()
    let expectation1 = self.expectation(description: "\(#function)\(#line)")
    let listener1 = Listener(after: 1) {
      expectation1.fulfill()
    }
    
    let expectation2 = self.expectation(description: "\(#function)\(#line)")
    let listener2 = Listener(after: 1) {
      expectation2.fulfill()
    }
    
    let expectation3 = self.expectation(description: "\(#function)\(#line)")
    let listener3 = Listener(after: 1) {
      expectation3.fulfill()
    }
    
    multicastdelegate.add(additionalDelegates: listener1)
    multicastdelegate.add(additionalDelegates: listener2)
    multicastdelegate.add(additionalDelegates: listener3)
    multicastdelegate.invoke { $0.didDispatch() }
    multicastdelegate.clear()
    multicastdelegate.invoke { $0.didDispatch() }
    
    waitForExpectations(timeout: 2)
    
    XCTAssertEqual(listener1.didDispatch_callsCount, 1)
    XCTAssertEqual(listener2.didDispatch_callsCount, 1)
    XCTAssertEqual(listener3.didDispatch_callsCount, 1)
  }
  
  func test_ThatAnAutoreleasedDelegateIsNotInvoked() {
    let multicastdelegate = MulticastDelegate<DispatcherDelegate>()
    let expectation1 = self.expectation(description: "\(#function)\(#line)")
    let listener1 = Listener(after: 1) {
      expectation1.fulfill()
    }
    multicastdelegate.add(additionalDelegates: listener1)
    
    autoreleasepool {
      let listener2 = Listener { XCTFail("A deallocated delegate shouldn't be called.") }
      multicastdelegate.add(additionalDelegates: listener2)
    }
    
    multicastdelegate.invoke { $0.didDispatch() }
    
    waitForExpectations(timeout: 2)
    XCTAssertEqual(listener1.didDispatch_callsCount, 1)
  }
  
  
  func test_ThatAWeakReferencedDelegateIsNotInvokedOnceDeallocated() {
    let expectation = self.expectation(description: "\(#function)\(#line)")
    expectation.isInverted = true
    var listener: Listener? = Listener(after: 0) { expectation.fulfill() }
    weak var weakListener = listener
    let multicastdelegate = MulticastDelegate<DispatcherDelegate>()
    
    multicastdelegate.add(additionalDelegates: listener!)
    listener = nil
    multicastdelegate.invoke { $0.didDispatch() }
    
    waitForExpectations(timeout: 2)
    XCTAssertNil(weakListener)
  }
  
  func test_ThatMultipleAutoreleasedDelegatesAreNotInvoked() {
    let multicastdelegate = MulticastDelegate<DispatcherDelegate>()
    autoreleasepool {
      (0...9).forEach { _ in
        let listener = Listener()
        multicastdelegate.add(additionalDelegates: listener)
      }
    }
    
    XCTAssertEqual(multicastdelegate.additionalDelegates.count, 0)
  }
  
  func test_ThatEachDelegateIsInvokedOnTheRightQueue() {
    let queue1 = DispatchQueue(label: "queue1")
    let key = DispatchSpecificKey<Int>()
    queue1.setSpecific(key: key, value: 1)
    
    let expectation1 = self.expectation(description: "\(#function)\(#line)")
    let listener1 = Listener(after: 1) {
      let value = DispatchQueue.getSpecific(key: key)
      XCTAssertEqual(value, 1)
      expectation1.fulfill()
    }
    
    let expectation2 = self.expectation(description: "\(#function)\(#line)")
    let listener2 = Listener(after: 1) {
      let value = DispatchQueue.getSpecific(key: key)
      XCTAssertEqual(value, 1)
      expectation2.fulfill()
    }
    
    let multicastdelegate = MulticastDelegate<DispatcherDelegate>()
    
    multicastdelegate.add(additionalDelegates: listener1)
    multicastdelegate.add(additionalDelegates: listener2)
    
    queue1.async {
      multicastdelegate.invoke { $0.didDispatch() }
    }
    
    waitForExpectations(timeout: 2)
  }
  
  func test_MulticastDelegateCopy() {
    let multicastdelegate = MulticastDelegate<DispatcherDelegate>()
    
    let expectation = self.expectation(description: "\(#function)\(#line)")
    let listener = Listener(after: 2) { expectation.fulfill() }
    let expectation2 = self.expectation(description: "\(#function)\(#line)")
    let listener2 = Listener(after: 1) { expectation2.fulfill() }
    
    multicastdelegate.add(additionalDelegates: listener)
    
    let multicastdelegateCopy = multicastdelegate // a copy shares the same multicastdelegate
    multicastdelegateCopy.invoke { $0.didDispatch() }
    multicastdelegateCopy.add(additionalDelegates: listener2)
    
    multicastdelegate.invoke { $0.didDispatch() }
    
    waitForExpectations(timeout: 2)
    XCTAssertEqual(listener.didDispatch_callsCount, 2)
    XCTAssertEqual(listener2.didDispatch_callsCount, 1)
  }
  
}

#if os(macOS) || os(iOS)

import AVFoundation

final class NotWeakableClasses_Tests: XCTestCase {
  
  /// https://developer.apple.com/library/archive/releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html#//apple_ref/doc/uid/TP40011226
  /// https://developer.apple.com/library/archive/releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html
  /// Which classes don’t support weak references?
  /// You cannot currently create weak references to instances of the following classes:
  /// NSATSTypesetter, NSColorSpace, NSFont, NSMenuView, NSParagraphStyle, NSSimpleHorizontalTypesetter, and NSTextView.
  /// Note: In addition, in OS X v10.7, you cannot create weak references to instances of NSFontManager, NSFontPanel, NSImage, NSTableCellView, NSViewController, NSWindow, and NSWindowController. In addition, in OS X v10.7 no classes in the AV Foundation framework support weak references.
  func testWeakReferenceMacOS() {
    /// macOS
    ///
    /// NSFontManager
    /// NSFontPanel
    /// NSTextView
    /// NSFont do NOT support Objective-C weak references.
    /// AVFoundation
    ///
    /// iOS
    ///
    /// AVFoundation
    
#if os(macOS)
    var fontManager: NSFontManager? = NSFontManager()
    weak var weakFontManager = fontManager
    fontManager = nil
    XCTAssertNotNil(weakFontManager, "NSFontManager can't be weak")
    
    var fontPanel: NSFontPanel? = NSFontPanel()
    weak var weakFontPanel = fontPanel
    fontPanel = nil
    XCTAssertNotNil(weakFontPanel, "NSFontPanel can't be weak")
    
    var textView: NSTextView? = NSTextView()
    weak var weakTextView = textView
    textView = nil
    XCTAssertNotNil(weakTextView, "NSTextView can't be weak")
    
    var font: NSFont? =  NSFont.menuFont(ofSize: 1.0)
    weak var weakFont = font
    font = nil
    XCTAssertNotNil(weakFont, "NSFont menuFont(ofSize:) return a font that can't be weak")
    
    var window: NSWindow? = NSWindow()
    weak var weakWindow = window
    window = nil
    XCTAssertNotNil(weakWindow, "NSWindow can't be weak")
    
    // 'NSATSTypesetter' is incompatible with 'weak' references
    //    var typeSetter: NSATSTypesetter? = NSATSTypesetter()
    //    weak var weakTypeSetter = typeSetter
    //    typeSetter = nil
    //    XCTAssertNil(weakTypeSetter)
#elseif os(iOS)
    var audioSession: AVAudioSession? = AVAudioSession()
    weak var weakAudioSession = audioSession
    audioSession = nil
    XCTAssertNotNil(weakAudioSession, "AVAudioSession classes can't be weak")
#endif
    
    var audioPlayer: AVAudioPlayer? = AVAudioPlayer()
    weak var weakAudioPlayer = audioPlayer
    audioPlayer = nil
    XCTAssertNil(weakAudioPlayer)
    
    var player: AVPlayer? = AVPlayer()
    weak var weakPlayer = player
    player = nil
    XCTAssertNil(weakPlayer)
    
#if os(macOS)
    var font2: NSFont? = NSFont(name: "font", size: 1.0)  // It works using NSFont(name:size:)
    weak var weakFont2 = font2
    font2 = nil
    XCTAssertNil(weakFont2)
    
    var image: NSImage? = NSImage()
    weak var weakImage = image
    image = nil
    XCTAssertNil(weakImage)
    
    var paragraphStyle: NSParagraphStyle? = NSParagraphStyle()
    weak var weakParagraphStyle = paragraphStyle
    paragraphStyle = nil
    XCTAssertNil(weakParagraphStyle)
    
    var tableViewCell: NSTableCellView? = NSTableCellView()
    weak var weakTableViewCell = tableViewCell
    tableViewCell = nil
    XCTAssertNil(weakTableViewCell)
    
    var windowController: NSWindowController? = NSWindowController()
    weak var weakWindowController = windowController
    windowController = nil
    XCTAssertNil(weakWindowController)
    
    var viewController: NSViewController? = NSViewController()
    weak var weakViewController = viewController
    viewController = nil
    XCTAssertNil(weakViewController)
    
    // 10.14 - NSColorSpace now supports Objective-C weak references.
    
    var colorSpace: NSColorSpace? = NSColorSpace()
    weak var weakColorSpace = colorSpace
    colorSpace = nil
    XCTAssertNil(weakColorSpace)
#endif
  }
}
#endif
