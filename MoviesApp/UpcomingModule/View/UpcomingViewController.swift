//
//  UpcomingViewController.swift
//  MoviesApp
//
//  Created by Niyazov Makhmujan on 26.03.2023.
//

import UIKit

class UpcomingViewController: UIViewController {
    
    private var titles: [Title] = [Title]()

    private let upcomingTable: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.indentifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupDataSourceAndDelegate()
        fetchUpcomingData()
        
        view.backgroundColor = .systemBackground
        title = "Upcoming"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
    }
    
    private func setupLayout() {
        view.addSubview(upcomingTable)
        
        NSLayoutConstraint.activate([
            upcomingTable.topAnchor.constraint(equalTo: view.topAnchor),
            upcomingTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            upcomingTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            upcomingTable.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
    private func setupDataSourceAndDelegate() {
        upcomingTable.dataSource = self
        upcomingTable.delegate = self
    }
    
    private func fetchUpcomingData() {
        APIManager.shared.upcomingMovies { [weak self] result in
            switch result {
            case .success(let titles):
                self?.titles = titles
                DispatchQueue.main.async {
                    self?.upcomingTable.reloadData()
                }
            case .failure(let error):
                print("Error Upcoming: ", error.localizedDescription)
            }
        }
    }
    
}

extension UpcomingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.indentifier,
                                                       for: indexPath) as? TitleTableViewCell else { return UITableViewCell() }
        let titles = titles[indexPath.row]
        cell.configure(with: TitleViewModel(releaseData: titles.release_date ?? "",
                                               titleName: (titles.original_title ?? titles.original_name) ?? "Unknown",
                                               posterURL: titles.poster_path ?? ""))
        return cell
    }
}

extension UpcomingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let title = titles[indexPath.row]
        guard let titleName = title.original_title ?? title.original_name else { return }
        
        APIManager.shared.getMovie(with: titleName) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let videoElement):
                DispatchQueue.main.async {
                    let vc = PreviewViewController()
                    vc.configure(with: PreviewViewModel(title: titleName,
                                                        youTubeView: videoElement,
                                                        titleOverview: title.overview ?? "")
                    )
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
