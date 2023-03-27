//
//  HomeCell.swift
//  MoviesApp
//
//  Created by Niyazov Makhmujan on 26.03.2023.
//

import UIKit

protocol HomeCellDelegate: AnyObject {
    func homeCellDidTapCell(_ cell: HomeCell, viewModel: PreviewViewModel)
}

class HomeCell: UITableViewCell {

    static let homeID = "homeID"
    weak var delegate: HomeCellDelegate?
    private var titles: [Title] = [Title]()
    
    private let homeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TitleCollectionCell.self,
                                forCellWithReuseIdentifier: TitleCollectionCell.titleCellId)
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupDataSourceAndDelegate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with model: [Title]) {
        self.titles = model
        DispatchQueue.main.async { [weak self] in
            self?.homeCollectionView.reloadData()
        }
    }
    
    private func setupDataSourceAndDelegate() {
        homeCollectionView.dataSource = self
        homeCollectionView.delegate = self
    }
    
    private func setupLayout() {
        contentView.addSubview(homeCollectionView)
        
        NSLayoutConstraint.activate([
            homeCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            homeCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            homeCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            homeCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func downloadTitleAt(indexPath: IndexPath) {
        
        CoreDataManager.shared.downloadTitle(with: titles[indexPath.row]) { result in
            switch result {
            case .success():
                NotificationCenter.default.post(name: NSNotification.Name("downloaded"), object: nil)
               // print("ok")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}

extension HomeCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionCell.titleCellId,
                                                            for: indexPath) as? TitleCollectionCell else { return UICollectionViewCell() }
        guard let image = titles[indexPath.row].poster_path else { return UICollectionViewCell() }
        cell.configure(with: image)
        return cell
    }
}

extension HomeCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2 - 1
        return CGSize(width: width, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let title = titles[indexPath.row]
        guard let titleName = title.original_title ?? title.original_name else { return }
        
        APIManager.shared.getMovie(with: titleName + "trailer") { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let videoElement):
                let title = self.titles[indexPath.row]
                guard let overview = title.overview else { return }
                let viewModel = PreviewViewModel(title: titleName, youTubeView: videoElement, titleOverview: overview)
                self.delegate?.homeCellDidTapCell(self, viewModel: viewModel)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil,
                                                previewProvider: nil) { _ in
            let downloadAction = UIAction(title: "Download",
                                          subtitle: nil,
                                          image: nil,
                                          identifier: nil,
                                          discoverabilityTitle: nil,
                                          state: .off) { [weak self] _ in
                self?.downloadTitleAt(indexPath: indexPath)
            }
            return UIMenu(title: "",
                          image: nil,
                          identifier: nil,
                          options: .displayInline,
                          children: [downloadAction])
        }
        return config
    }
}
