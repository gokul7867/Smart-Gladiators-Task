//
//  QuoteCell.swift
//  QuotesApp
//
//  Created by gokul gokul on 16/04/26.
//

import UIKit

class QuoteCell: UICollectionViewCell {
    
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var accentView: UIView!
    @IBOutlet weak var quoteIcon: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var onFavoriteTapped: (() -> Void)?
    
    @IBAction private func favoriteTapped(_ sender: UIButton) {
        onFavoriteTapped?()
    }
    
    private let colors: [UIColor] = [
        .systemPurple,
        .systemOrange,
        .systemGreen,
        .systemBlue,
        .systemPink
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 6
        containerView.backgroundColor = .systemBackground
        accentView.layer.cornerRadius = 2
        quoteLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        quoteLabel.numberOfLines = 0
        authorLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        authorLabel.textColor = .secondaryLabel
        quoteIcon.image = UIImage(systemName: "quote.opening")
        quoteIcon.tintColor = .systemPurple
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
    }
    
    func configure(with quote: Quote, index: Int) {
        quoteLabel.text = quote.formattedQuote
        authorLabel.text = "- \(quote.formattedAuthor)"
        let color = colors[index % colors.count]
        accentView.backgroundColor = color
        let imageName = quote.isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        favoriteButton.tintColor = color
        quoteIcon.tintColor = color
        authorLabel.textColor = color
    }
    
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let collectionView = superview as? UICollectionView else {
            return super.preferredLayoutAttributesFitting(layoutAttributes)
        }
        setNeedsLayout()
        layoutIfNeeded()
        let inset: CGFloat = 20
        let targetWidth = collectionView.bounds.width - inset
        let targetSize = CGSize(
            width: targetWidth,
            height: UIView.layoutFittingCompressedSize.height
        )
        let size = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        var frame = layoutAttributes.frame
        frame.size.width = targetWidth
        frame.size.height = ceil(size.height)
        layoutAttributes.frame = frame
        return layoutAttributes
    }
    
}
