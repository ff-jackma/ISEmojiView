//
//  EmojiPopView.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation
import UIKit

internal protocol EmojiPopViewDelegate: AnyObject {
    
    /// called when the popView needs to dismiss itself
    func emojiPopViewShouldDismiss(emojiPopView: EmojiPopView)
    
}

internal class EmojiPopView: UIView {
    
    // MARK: - Internal variables
    
    /// the delegate for callback
    internal weak var delegate: EmojiPopViewDelegate?
    
    internal var currentEmoji: String = ""
    internal var emojiArray: [String] = []
    
    // MARK: - Private variables
    
    private var locationX: CGFloat = 0.0
    
    private var emojiButtons: [UIButton] = []
    private var emojisView: UIView = UIView()

    private var emojisX: CGFloat = 0.0
    private var emojisWidth: CGFloat = 0.0

    // MARK: - Init functions
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: EmojiPopViewSize.width, height: EmojiPopViewSize.height))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Override functions
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let result = point.x >= emojisX && point.x <= emojisX + emojisWidth && point.y >= 0 && point.y <= TopPartSize.height
        
        if !result {
            dismiss()
        }
        
        return result
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            setupUI()
            self.isHidden = false
        }
    }

    // MARK: - Internal functions

    internal func move(emojiFrame: CGRect, animation: Bool = true) {
        let emojiPopLocation = CGPoint(
            x: emojiFrame.origin.x - ((TopPartSize.width - BottomPartSize.width) / 2.0) + PartSpacing * 2.0,
            y: emojiFrame.origin.y - TopPartSize.height - PartSpacing * 2.0
        )

        move(location: emojiPopLocation, animation: animation)
    }
    
    internal func move(location: CGPoint, animation: Bool = true) {
        locationX = location.x
        setupUI()

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

        self.alpha = 0
        UIView.animate(withDuration: animation ? 0.08 : 0, animations: {
            self.alpha = 1
            self.frame = CGRect(x: location.x, y: locationY, width: self.frame.width, height: self.frame.height)
        }, completion: { complate in
            self.isHidden = false
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
    
    internal func setEmoji(_ emoji: Emoji) {
        self.currentEmoji = emoji.selectedEmoji ?? emoji.emoji
        self.emojiArray = emoji.emojis
    }

    internal func needRefreshEmoji(_ emoji: Emoji) -> Bool {
        if let selectedEmoji = emoji.selectedEmoji {
            return self.currentEmoji != selectedEmoji
        }
        return self.currentEmoji != emoji.emoji
    }

}

// MARK: - Private functions

extension EmojiPopView {
    
    private func createEmojiButton(_ emoji: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = EmojiFont
        button.setTitle(emoji, for: .normal)
        button.frame = CGRect(x: CGFloat(emojiButtons.count) * EmojiSize.width, y: 0, width: EmojiSize.width, height: EmojiSize.height)
        button.addTarget(self, action: #selector(selectEmojiType(_:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        return button
    }
    
    @objc private func selectEmojiType(_ sender: UIButton) {
        if let selectedEmoji = sender.titleLabel?.text {
            currentEmoji = selectedEmoji
            delegate?.emojiPopViewShouldDismiss(emojiPopView: self)
        }
    }
    
    private func setupUI() {
        isHidden = true
        
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        // adjust location of emoji bar if it is off the screen
        emojisWidth = TopPartSize.width + EmojiSize.width * CGFloat(emojiArray.count - 1)
        emojisX = 0.0 // the x adjustment within the popView to account for the shift in location
        let screenWidth = UIScreen.main.bounds.width
        if emojisWidth + locationX > screenWidth {
            emojisX = -CGFloat(emojisWidth + locationX - screenWidth + 8) // 8 for padding to border
        }
        // readjust in case someone is long-pressing right at the edge of the screen
        let halfWidth = TopPartSize.width / 2.0 - BottomPartSize.width / 2.0
        if emojisX + emojisWidth < halfWidth + BottomPartSize.width {
            emojisX += (halfWidth + BottomPartSize.width) - (emojisX + emojisWidth)
        }
        
        // path
        let path = maskPath()

        let color = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
                case .dark:
                    return .black
                default:
                    return .white
            }
        }

        // border
        let borderLayer = CAShapeLayer()
        borderLayer.path = path
        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.fillColor = color.cgColor
        borderLayer.lineWidth = 0
        layer.addSublayer(borderLayer)
        
        // mask
        let maskLayer = CAShapeLayer()
        maskLayer.path = path
        
        // content layer
        let contentLayer = CALayer()
        contentLayer.frame = bounds
        contentLayer.backgroundColor = color.cgColor
        contentLayer.mask = maskLayer
        layer.addSublayer(contentLayer)
        
        emojisView.removeFromSuperview()
        emojisView = UIView(
            frame: CGRect(
                x: emojisX + 8,
                y: PartSpacing * 2.0,
                width: CGFloat(emojiArray.count) * EmojiSize.width,
                height: EmojiSize.height
            )
        )

        // add buttons
        emojiButtons = []
        for emoji in emojiArray {
            let button = createEmojiButton(emoji)
            emojiButtons.append(button)
            emojisView.addSubview(button)
        }
        
        addSubview(emojisView)
    }
    
    func maskPath() -> CGMutablePath {
        let path = CGMutablePath()
        
        path.addRoundedRect(
             in: CGRect(
                 x: emojisX,
                 y: PartSpacing,
                 width: emojisWidth,
                 height: TopPartSize.height
             ),
             cornerWidth: 4,
             cornerHeight: 4
         )

        path.addRoundedRect(
            in: CGRect(
                x: TopPartSize.width / 2.0 - BottomPartSize.width / 2.0,
                y: TopPartSize.height,
                width: BottomPartSize.width,
                height: BottomPartSize.height + PartSpacing
            ),
            cornerWidth: 4,
            cornerHeight: 4
        )
        
        return path
    }
}
