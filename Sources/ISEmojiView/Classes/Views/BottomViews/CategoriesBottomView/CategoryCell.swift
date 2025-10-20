//
//  ISEmojiCategoryCell.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation
import UIKit

private let HighlightedBackgroundViewSize = CGFloat(30)
//private let ImageActiveTintColor = UIColor(red: 95/255, green: 94/255, blue: 95/255, alpha: 1)
//private let ImageNonActiveTintColor = UIColor(red: 161/255, green: 165/255, blue: 172/255, alpha: 1)

internal class CategoryCell: UICollectionViewCell {
    
    // MARK: - Private variables

    private var ImageNonActiveTintColor: UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
                case .dark:
                    // rgba(112, 113, 116, 1)
                    return UIColor(red: 112/255, green: 113/255, blue: 116/255, alpha: 1)
                default:
                    // rgba(161, 165, 172, 1)
                    return UIColor(red: 161/255, green: 165/255, blue: 172/255, alpha: 1)
            }
        }
    }

    private var ImageActiveTintColor: UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
                case .dark:
                    // rgba(137, 138, 141, 1)
                    return UIColor(red: 137/255, green: 138/255, blue: 141/255, alpha: 1)
                default:
                    // rgba(95, 94, 95, 1)
                    return UIColor(red: 95/255, green: 94/255, blue: 95/255, alpha: 1)
            }
        }
    }

    private var highlightedBackgroundView: UIView = {
        let view = UIView()
        let colorAsset = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                // rgba(67, 67, 67, 1)
                return UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1)
            default:
                // rgba(201, 206, 214, 1)
                return UIColor(red: 201/255, green: 206/255, blue: 214/255, alpha: 1)
            }
        }
        view.backgroundColor = colorAsset
        view.isHidden = true
        return view
    }()
    
    private lazy var emojiImageView: UIImageView = {
        let emojiImageView = UIImageView()
        emojiImageView.contentMode = .center
        emojiImageView.tintColor = ImageNonActiveTintColor
        return emojiImageView
    }()
    
    // MARK: - Override functions
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override var isHighlighted: Bool {
        didSet {
            highlightedBackgroundView.isHidden = !isHighlighted
            emojiImageView.tintColor = isHighlighted ? ImageActiveTintColor : ImageNonActiveTintColor
        }
    }
    
    override var isSelected: Bool {
        didSet {
            highlightedBackgroundView.isHidden = !isSelected
            emojiImageView.tintColor = isSelected ? ImageActiveTintColor : ImageNonActiveTintColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = min(HighlightedBackgroundViewSize, contentView.bounds.width)
        highlightedBackgroundView.frame.size.width = size
        highlightedBackgroundView.frame.size.height = size
        highlightedBackgroundView.frame.origin.x = contentView.center.x - size/2
        highlightedBackgroundView.frame.origin.y = contentView.center.y - size/2
        
        highlightedBackgroundView.layer.cornerRadius = highlightedBackgroundView.frame.width/2
        
        emojiImageView.frame = contentView.bounds
    }

    // MARK: - Internal functions
    
    internal func setEmojiCategory(_ category: Category) {
        let image: UIImage?
        
        image = UIImage(named: category.iconName, in: Bundle.podBundle, compatibleWith: nil)
        emojiImageView.image = image?.withRenderingMode(.alwaysTemplate)
    }
    
    // MARK: - Private functions
    
    private func setupView() {
        contentView.addSubview(highlightedBackgroundView)
        contentView.addSubview(emojiImageView)
    }
    
}
