![ISEmojiView logo](/logo@2x.jpg)
[![Version](https://img.shields.io/cocoapods/v/ISEmojiView.svg?style=flat)](http://cocoapods.org/pods/ISEmojiView)
[![License](https://img.shields.io/cocoapods/l/ISEmojiView.svg?style=flat)](http://cocoapods.org/pods/ISEmojiView)
[![Platform](https://img.shields.io/cocoapods/p/ISEmojiView.svg?style=flat)](http://cocoapods.org/pods/ISEmojiView)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![SPM supported](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat")](https://swift.org/package-manager/)


English | [中文](/README_zh.md)

An easy to use Emoji keyboard for iOS.

Has been rewritten with swift, the old *Objective-C* version on branch [oc](https://github.com/isaced/ISEmojiView/tree/oc).

<img src="/screenshot1.png" width="375" height="667"> <img src="/screenshot2.png" width="375" height="667">

## Features

- [x] Written in Swift
- [x] Custom emojis
- [x] Multiple skin tone support (  🏻 🏼 🏽 🏾 🏿 )
- [x] Categories bottom bar (like iOS system emoji Keyboard)
- [x] Recently used emoji
- [x] Dark Mode ([#58](https://github.com/isaced/ISEmojiView/issues/58))
- [x] SwiftUI support.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- Swift 5
- iOS8+
- Xcode 10

## Usage

### Installation

#### Swift Package Manager

via [Swift Package Manager](https://swift.org/package-manager/) Install to your project，Add in Package.swift：

```swift
.package(name: "ISEmojiView", url: "https://github.com/isaced/ISEmojiView.git", .upToNextMinor(from: "0.3.0")),
```

In Xcode：

- File > Swift Packages > Add Package Dependency
- Add https://github.com/isaced/ISEmojiView.git
- Select "Up to Next Major" with "0.3.0"

#### Cocoapods

```Ruby
# Swift
pod 'ISEmojiView'

# Objective-C (Deprecated)
pod 'ISEmojiView', '0.0.1'
```

#### Carthage

```Ruby
github "isaced/ISEmojiView"
```

### Import

```Swift
import ISEmojiView
```

### Initialization

```Swift
let keyboardSettings = KeyboardSettings(bottomType: .categories)
let emojiView = EmojiView(keyboardSettings: keyboardSettings)
emojiView.translatesAutoresizingMaskIntoConstraints = false
emojiView.delegate = self
textView.inputView = emojiView
```

### Delegate

Implement `<EmojiViewDelegate>`

```Swift
// callback when tap a emoji on keyboard
func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
    textView.insertText(emoji)
}

// callback when tap change keyboard button on keyboard
func emojiViewDidPressChangeKeyboardButton(_ emojiView: EmojiView) {
    textView.inputView = nil
    textView.keyboardType = .default
    textView.reloadInputViews()
}
    
// callback when tap delete button on keyboard
func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {
    textView.deleteBackward()
}

// callback when tap dismiss button on keyboard
func emojiViewDidPressDismissKeyboardButton(_ emojiView: EmojiView) {
    textView.resignFirstResponder()
}
```

### Customize

#### KeyboardSettings

This is a class to describe keyboard settings. Available properties:

- `bottomType` - type of bottom view. Available variants: `.pageControl`, `.categories`. See `BottomType` enum. Default `.pageControl`.
- `customEmojis` - array of custom emojis. To describe emojis you have to use `EmojiCategory` class.
- `isShowPopPreview` - long press to pop preview effect like iOS10 system emoji keyboard. Default is true.
- `countOfRecentsEmojis` - the max number of recent emojis, if set 0, nothing will be shown. Default is 50.
- `needToShowAbcButton` - need to show change keyboard button. This button is located in `Categories` bottom view.

### SwiftUI
Doesn't work on macOS SwiftUI natively.

```Swift
import ISEmojiView

EmojiView_SwiftUI()
    .frame(width: 300, height: 500)
    .padding()
```

`countOfRecentsEmojis`, `needToShowAbcButton`, `needToShowDeleteButton`, `updateRecentEmojiImmediately` can be passed to EmojiView_SwiftUI as parameters.

## Updating Emoji Resources

ISEmojiView uses plist files to store Emoji data. When Unicode Consortium releases new versions of Emoji, you can use the provided Python script to generate updated plist files.

### Steps:

1. Download the latest `emoji-test.txt` file from [Unicode Emoji Test Data](https://unicode.org/Public/emoji/) (e.g., version 15.0, 16.0, etc.)

2. Run the `build_emoji_plist_groups.py` script:

```bash
cd Sources/ISEmojiView/Assets
python3 build_emoji_plist_groups.py \
  --emoji-test /path/to/emoji-test.txt \
  --out ISEmojiList_iOS26.0.plist
```

3. The script will automatically:
   - Parse the emoji-test.txt file
   - Group emojis into predefined categories (Smileys & People, Animals & Nature, Food & Drink, etc.)
   - Cluster skin tone variants (e.g., 👋, 👋🏻, 👋🏼 will be grouped together)
   - Generate a plist file in ISEmojiView format

4. Add the generated plist file to your project and use the new emoji list in your code

### Script Details:

`build_emoji_plist_groups.py` supports the following arguments:
- `--emoji-test`: Required, path to the Unicode emoji-test.txt file
- `--out`: Required, output path for the plist file

The generated plist format:
```
[
  {
    "title": "Smileys & People",
    "emojis": ["😀", ["👋", "👋🏻", "👋🏼", "👋🏽", "👋🏾", "👋🏿"], ...]
  },
  ...
]
```

Where a single string represents an emoji without skin tone variants, and an array represents a collection of emojis with skin tone variants.

## Others

If you are looking for a React Native solution, take a look at this [brendan-rius/react-native-emoji-keyboard](https://github.com/brendan-rius/react-native-emoji-keyboard)

## License

MIT
