//
//  ResultsSearchViewController.swift
//  MoviesApp
//
//  Created by Niyazov Makhmujan on 26.03.2023.
//

import UIKit

protocol ResultsSearchViewControllerDelegate: AnyObject {
    func resultsControllerDidTapItem(_ viewModel: PreviewViewModel)
}

class ResultsSearchViewController: UIViewController {

    public var titles: [Title] = [Title]()
    public weak var delegate: ResultsSearchViewControllerDelegate?
    
    public let searchResultCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.showsVerticalScrollIndicator = false
        collection.register(TitleCollectionCell.self, forCellWithReuseIdentifier: TitleCollectionCell.titleCellId)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupDataSourceAndDelegate()
    }
    
    private func setupLayout() {
        view.addSubview(searchResultCollection)
        
        NSLayoutConstraint.activate([
            searchResultCollection.topAnchor.constraint(equalTo: view.topAnchor),
            searchResultCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchResultCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchResultCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupDataSourceAndDelegate() {
        searchResultCollection.dataSource = self
        searchResultCollection.delegate = self
    }
}

extension ResultsSearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionCell.titleCellId,
                                                          for: indexPath) as? TitleCollectionCell else { return UICollectionViewCell() }
        let title = titles[indexPath.row]
        cell.configure(with: title.poster_path ?? "")
        return cell
    }
}

extension ResultsSearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2 - 1
        return CGSize(width: width, height: 270)
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
        let titleName = title.original_title ?? ""
        
        APIManager.shared.getMovie(with: titleName) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let videoElement):
                self.delegate?.resultsControllerDidTapItem(PreviewViewModel(title: title.original_title ?? "",
                                                                            youTubeView: videoElement,
                                                                            titleOverview: title.overview ?? ""))
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
