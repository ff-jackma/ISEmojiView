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
    
    private let EmojisDisplayMaxCount: Int = 7
    private var EmojisViewMaxWidth: CGFloat {
        return EmojiSize.width * CGFloat(EmojisDisplayMaxCount)
    }
    
    var locationX: CGFloat = 0.0
    
    private var emojiButtons: [UIButton] = []
    private var emojisX: CGFloat = 0.0
    private var emojisWidth: CGFloat = 0.0
    
    // MARK: - Init functions
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: EmojiPopViewSize.width, height: EmojiPopViewSize.height))
        setupEmojisView()
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
            updateUI()
        }
    }

    @objc private func selectEmojiType(_ sender: UIButton) {
        if let selectedEmoji = sender.titleLabel?.text {
            currentEmoji = selectedEmoji
            delegate?.emojiPopViewShouldDismiss(emojiPopView: self)
        }
    }

    // MARK: - UI

    private func setupEmojisView() {
        addSubview(emojisView)
    }

    func updateUI() {
        if emojiArray.count == 0 {
            return
        } else if emojiArray.count == 1 {
            emojisWidth = TopPartSize.width
            emojisX = (TopPartSize.width - EmojiSize.width) / 2.0
        } else {
            emojisWidth = min(EmojisViewMaxWidth, CGFloat(emojiArray.count) * EmojiSize.width)

            // adjust location of emoji bar if it is off the screen
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
        }

        updateLayer()
        updateEmojisView()
   }

    private var borderLayer: CAShapeLayer?
    private var contentLayer: CALayer?
    private func updateLayer() {
        // remove old layers
        borderLayer?.removeFromSuperlayer()
        contentLayer?.removeFromSuperlayer()

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
        self.borderLayer = borderLayer

        // mask
        let maskLayer = CAShapeLayer()
        maskLayer.path = path

        // content layer
        let contentLayer = CALayer()
        contentLayer.frame = bounds
        contentLayer.backgroundColor = color.cgColor
        contentLayer.mask = maskLayer
        layer.addSublayer(contentLayer)
        self.contentLayer = contentLayer
    }

    private func maskPath() -> CGMutablePath {
        let path = CGMutablePath()

        // width 0 means not valid
        guard emojisWidth > 0 else {
            return path
        }

        var x = emojisX
        if emojiArray.count == 1 {
            x = 0
        }
        path.addRoundedRect(
             in: CGRect(
                 x: x,
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

    private func updateEmojisView() {
        bringSubviewToFront(emojisView)
        // emojis view
        emojisView.frame = CGRect(
            x: emojisX,
            y: PartSpacing * 2.0,
            width: emojisWidth,
            height: EmojiSize.height
        )
        emojisView.contentSize = CGSize(
            width: CGFloat(emojiArray.count) * EmojiSize.width,
            height: EmojiSize.height
        )
        emojisView.contentOffset = .zero

        emojisView.subviews.forEach { $0.removeFromSuperview() }

        // add buttons
        emojiButtons = []
        for emoji in emojiArray {
            let button = createEmojiButton(emoji)
            emojiButtons.append(button)
            emojisView.addSubview(button)
        }
    }

    private func createEmojiButton(_ emoji: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = EmojiFont
        button.setTitle(emoji, for: .normal)
        button.frame = CGRect(x: CGFloat(emojiButtons.count) * EmojiSize.width, y: 0, width: EmojiSize.width, height: EmojiSize.height)
        button.addTarget(self, action: #selector(selectEmojiType(_:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        return button
    }

    lazy var emojisView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        return view
    }()
}
