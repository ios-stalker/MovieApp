//
//  SearchViewController.swift
//  MoviesApp
//
//  Created by Niyazov Makhmujan on 26.03.2023.
//

import UIKit

class SearchViewController: UIViewController {
    
    private var titles: [Title] = [Title]()
    
    private let searchController: UISearchController = {
        let search = UISearchController(searchResultsController: ResultsSearchViewController())
        search.searchBar.placeholder = "Search for a movie or Tv show..."
        search.searchBar.searchBarStyle = .minimal
        return search
    }()

    private let discoverTableView: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.indentifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    override func viewDidLoad() {
        setupLayout()
        setupDataSourceAndDelegate()
        super.viewDidLoad()
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground
        navigationItem.searchController = searchController
        navigationController?.navigationBar.tintColor = .white
        
        searchController.searchResultsUpdater = self
    }
    
    private func setupLayout() {
        view.addSubview(discoverTableView)
        
        NSLayoutConstraint.activate([
            discoverTableView.topAnchor.constraint(equalTo: view.topAnchor),
            discoverTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            discoverTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            discoverTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func fetchDicoverMovies() {
        APIManager.shared.getDiscoverMovies { [weak self] result in
            switch result {
            case .success(let titles):
                self?.titles = titles
                DispatchQueue.main.async {
                    self?.discoverTableView.reloadData()
                }
            case .failure(let error):
                print("Error: ", error.localizedDescription)
            }
        }
    }
    
    private func setupDataSourceAndDelegate() {
        discoverTableView.dataSource = self
        discoverTableView.delegate = self
    }
    
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.indentifier,
                                                       for: indexPath) as? TitleTableViewCell else { return UITableViewCell () }
        let title = titles[indexPath.row]
        let model = TitleViewModel(releaseData: title.release_date ?? "",
                                   titleName: title.original_name ?? title.original_title ?? "Unknown",
                                   posterURL: title.poster_path ?? "")
        cell.configure(with: model)
        return cell
    }
    
    
}

extension SearchViewController: UITableViewDelegate {
    
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        guard let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              query.trimmingCharacters(in: .whitespaces).count >= 3,
              let resultsController = searchController.searchResultsController as? ResultsSearchViewController else { return }
        resultsController.delegate = self
        
        APIManager.shared.search(with: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let titles):
                    resultsController.titles = titles
                    resultsController.searchResultCollection.reloadData()
                case .failure(let error):
                    print("Error: ", error.localizedDescription)
                }
            }
        }
    }
}

extension SearchViewController: ResultsSearchViewControllerDelegate {
    func resultsControllerDidTapItem(_ viewModel: PreviewViewModel) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let vc = PreviewViewController()
            vc.configure(with: viewModel)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

