//
//  TitleCollectionCell.swift
//  MoviesApp
//
//  Created by Niyazov Makhmujan on 26.03.2023.
//

import UIKit
import SDWebImage

class TitleCollectionCell: UICollectionViewCell {
    
    static let titleCellId = "titleCellId"
    
    private let poster: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView.addSubview(poster)
        
        NSLayoutConstraint.activate([
            poster.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            poster.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            poster.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            poster.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    public func configure(with model: String) {
        guard let imageUrl = URL(string: "\(Constants.imageUrl)\(model)") else { return }
        poster.sd_setImage(with: imageUrl, completed: nil)
    }
    
}
