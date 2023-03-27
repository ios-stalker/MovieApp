//
//  DownloadsViewController.swift
//  MoviesApp
//
//  Created by Niyazov Makhmujan on 26.03.2023.
//

import UIKit

class DownloadsViewController: UIViewController {
    
    private var titles: [TitleItem] = [TitleItem]()
    private let downloadsTableView: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.indentifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.showsVerticalScrollIndicator = false
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupDataSourceAndDelegate()
        fetchLocalStorageForDownload()
        view.backgroundColor = .systemBackground
        title = "Downloads"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("downloaded"),
                                               object: nil,
                                               queue: nil) { _ in
            self.fetchLocalStorageForDownload()
        }
    }
    

    private func setupLayout() {
        view.addSubview(downloadsTableView)
        
        NSLayoutConstraint.activate([
            downloadsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            downloadsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            downloadsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            downloadsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupDataSourceAndDelegate() {
        downloadsTableView.dataSource = self
        downloadsTableView.delegate = self
    }
    
    private func fetchLocalStorageForDownload() {
        CoreDataManager.shared.fetchingTitlesFromDataBase { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let titles):
                self.titles = titles
                DispatchQueue.main.async {
                    self.downloadsTableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension DownloadsViewController: UITableViewDataSource {
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

extension DownloadsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            CoreDataManager.shared.deleteTitle(with: titles[indexPath.row]) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success():
                    print("Deleted form data base")
                case .failure(let error):
                    print(error.localizedDescription)
                }
                self.titles.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        default:
            break
        }
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
