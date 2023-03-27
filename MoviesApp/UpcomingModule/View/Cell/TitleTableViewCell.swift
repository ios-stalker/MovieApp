//
//  TitleTableViewCell.swift
//  MoviesApp
//
//  Created by Niyazov Makhmujan on 26.03.2023.
//

import UIKit
import SDWebImage

class TitleTableViewCell: UITableViewCell {

    static let indentifier = "indentifier"
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byCharWrapping
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byCharWrapping
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let posterImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        [titleLabel, posterImage, playButton, releaseDateLabel].forEach { contentView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            posterImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            posterImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            posterImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            posterImage.widthAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 25),
            titleLabel.leadingAnchor.constraint(equalTo: posterImage.trailingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            releaseDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            releaseDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with model: TitleViewModel) {
        guard let imageUrl = URL(string: "\(Constants.imageUrl)\(model.posterURL)") else { return }
        posterImage.sd_setImage(with: imageUrl, completed: nil)
        titleLabel.text = model.titleName
        releaseDateLabel.text = model.releaseData
        
    }

}
