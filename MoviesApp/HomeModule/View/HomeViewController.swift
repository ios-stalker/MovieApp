//
//  HomeViewController.swift
//  MoviesApp
//
//  Created by Niyazov Makhmujan on 26.03.2023.
//

import UIKit

class HomeViewController: UIViewController {

    let sectionTitles: [String] = ["Trending Movies", "Trending Tv", "Popular", "Upcoming Movies", "Top Rated"]
    private let sectionsCategories = SectionsCategories.trendingMovies
    private var randomTrendingMovies: Title?
    private var headerView: HeroHeaderView?
    
    private let homeTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(HomeCell.self, forCellReuseIdentifier: HomeCell.homeID)
        table.showsVerticalScrollIndicator = false
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupDelegateAndDataSource()
        setupTabeHeaderView()
        view.backgroundColor = .systemBackground
    }
    
    private func setupDelegateAndDataSource() {
        homeTableView.dataSource = self
        homeTableView.delegate = self
    }
    
    private func setupTabeHeaderView() {
        headerView = HeroHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 500))
        homeTableView.tableHeaderView = headerView
        
        APIManager.shared.getDiscoverMovies { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let titles):
                let selectedTitle = titles.randomElement()
                self.randomTrendingMovies = selectedTitle
                self.headerView?.configure(with: TitleViewModel(releaseData: selectedTitle?.release_date ?? "",
                                                                titleName: selectedTitle?.original_title ?? "",
                                                                posterURL: selectedTitle?.poster_path ?? "")
                )
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func setupLayout() {
        view.addSubview(homeTableView)
        
        NSLayoutConstraint.activate([
            homeTableView.topAnchor.constraint(equalTo: view.topAnchor),
            homeTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            homeTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            homeTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeCell.homeID,
                                                       for: indexPath) as? HomeCell else { return UITableViewCell() }
        
        cell.delegate = self
        
        switch indexPath.section {
        case SectionsCategories.trendingMovies.rawValue:
            APIManager.shared.getTrendingMovies { result in
                switch result {
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print("Error Trending Movies: ", error.localizedDescription)
                }
            }
        case SectionsCategories.trendingTv.rawValue:
            APIManager.shared.getTrendingTv { result in
                switch result {
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print("Error Trending Tv:  ", error.localizedDescription)
                }
            }
        case SectionsCategories.popular.rawValue:
            APIManager.shared.getPopular { result in
                switch result {
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print("Error Popular: ", error.localizedDescription)
                }
            }
        case SectionsCategories.upcoming.rawValue:
            APIManager.shared.upcomingMovies { result in
                switch result {
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print("Error Upcoming: ", error.localizedDescription)
                }
            }
        case SectionsCategories.topRated.rawValue:
            APIManager.shared.getTopRated { result in
                switch result {
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print("Error Top Rated: ", error.localizedDescription)
                }
            }
        default:
            break
        }
    
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.frame = CGRect(x: header.bounds.origin.x + 20,
                                         y: header.bounds.width,
                                         width: 100,
                                         height: header.bounds.height)
        header.textLabel?.textColor = .white
        header.textLabel?.text = header.textLabel?.text?.capitalizeFirstLetter()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultOffset = view.safeAreaInsets.top
        let offset = scrollView.contentOffset.y + defaultOffset
        
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
    }
}

extension HomeViewController: HomeCellDelegate {
    func homeCellDidTapCell(_ cell: HomeCell, viewModel: PreviewViewModel) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let viewController = PreviewViewController()
            viewController.configure(with: viewModel)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
