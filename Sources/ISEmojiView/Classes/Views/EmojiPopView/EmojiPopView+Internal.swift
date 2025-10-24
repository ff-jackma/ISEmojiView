//
//  EmojiPopView+Internal.swift
//  Pods
//
//  Created by jackma on 2025/10/24.
//

extension EmojiPopView {

    internal func move(emojiFrame: CGRect, animation: Bool = true) {
        let emojiPopLocation = CGPoint(
            x: emojiFrame.origin.x - ((TopPartSize.width - BottomPartSize.width) / 2.0) + PartSpacing * 2.0,
            y: emojiFrame.origin.y - TopPartSize.height - PartSpacing * 2.0
        )

        move(location: emojiPopLocation, animation: animation)
    }

    internal func move(location: CGPoint, animation: Bool = true) {
        locationX = location.x
        updateUI()

        var locationY = location.y
        // 平移+翻转视图
        if location.y < -12 {
            locationY += TopPartSize.height + PartSpacing * 2.0
            self.transform = CGAffineTransform(scaleX: 1, y: -1)
            self.emojisView.transform = CGAffineTransform(scaleX: 1, y: -1)
        } else {
            self.transform = .identity
            self.emojisView.transform = .identity
        }

        self.isHidden = false
        self.alpha = 0
        UIView.animate(withDuration: animation ? 0.08 : 0, animations: {
            self.alpha = 1
            self.frame = CGRect(x: location.x, y: locationY, width: self.frame.width, height: self.frame.height)
        })
    }

    internal func dismiss() {
        UIView.animate(withDuration: 0.08, animations: {
            self.alpha = 0
        }, completion: { complate in
            self.isHidden = true
            self.currentEmoji = ""
            self.emojiArray = []
        })
    }

    internal func needRefreshEmoji(_ emoji: Emoji) -> Bool {
        if let selectedEmoji = emoji.selectedEmoji {
            return self.currentEmoji != selectedEmoji
        }
        return self.currentEmoji != emoji.emoji
    }

    internal func setEmoji(_ emoji: Emoji) {
        self.currentEmoji = emoji.selectedEmoji ?? emoji.emoji
        self.emojiArray = emoji.emojis
    }
}
