//
//  SearchVC.swift
//  FoamyCool
//
//  Created by Kyrylo Danylov on 9/21/19.
//  Copyright © 2019 Kyrylo Danylov. All rights reserved.
//

import UIKit

class SearchVC: UIViewController {

    let tableView: UITableView = {
        let view = UITableView(frame: UIScreen.main.bounds, style: .plain)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.rowHeight = 110
        view.keyboardDismissMode = .onDrag
        view.tableFooterView = UIView(frame: .zero)
        view.separatorStyle = .none
        return view
    }()

    let placeholder: UILabel = {
        let label = UILabel()
        label.text = "There is nothing here, please make a search"
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.searchBarStyle = UISearchBar.Style.prominent
        search.placeholder = " Search..."
        search.translatesAutoresizingMaskIntoConstraints = false
        search.isTranslucent = false
        search.backgroundImage = UIImage()
        return search
    }()

    var navigationBar: UINavigationBar = {
        let screenWidth = UIScreen.main.bounds.width
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
        return navBar
    }()

    var safeArea: UILayoutGuide!
    var currentPage: Int = 1
    var requestInProgress: Bool = false
    var totalResults: Int = 0
    var textForSearch: String = ""
    var canFetchMoreResults: Bool = true
    let FetchThreshold = 5

    var data = [BeerItem]() {
        willSet {
            placeholder.isHidden = newValue.count != 0 ? true : false
        }
        didSet {
                tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        self.title = "Search"
        view.backgroundColor = .white
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(placeholder)
        searchBar.delegate = self
        safeArea = view.layoutMarginsGuide
        tableView.register(BeerCell.self, forCellReuseIdentifier: BeerCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        setLayout()
    }

    private func calcIndexPathsToReload(from newData: [BeerItem]) -> [IndexPath] {
        let startIndex = data.count - newData.count
        let endIndex = startIndex + newData.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }

    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        // 1
        guard let newIndexPathsToReload = newIndexPathsToReload else {
//            indicatorView.stopAnimating()
            tableView.isHidden = false
            tableView.reloadData()
            return
        }
        // 2
        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }

    func onFetchFailed(with reason: String) {
//        indicatorView.stopAnimating()

        let title = "Warning"
        let action = UIAlertAction(title: "OK", style: .default)
//        displayAlert(with: title , message: reason, actions: [action])
    }

    func getNewData() {
        guard !requestInProgress else {
            return
        }
        requestInProgress = true

        ServiceLayer.request(router: Router.searchForBeer(textForSearch, page: currentPage)) { (result: Result<searchBeerResponse, Error>) in
            switch result {
            case .success:
                guard let responseData = try? result.get() else { return }
                if let beerData = responseData.data {
                    if self.currentPage == 1 {
                        self.data = beerData
                    } else {
                        self.data.append(contentsOf: beerData)

                    }
                    self.currentPage += 1
                    self.requestInProgress = false
                    self.totalResults = responseData.numberOfPages ?? 0
                    self.canFetchMoreResults = (self.currentPage < self.totalResults)

                } else {
                    self.requestInProgress = false
                    self.data.removeAll()
                }
                self.tableView.reloadData()
            case .failure:
                print(result)
                self.requestInProgress = false
            }
        }
    }

    func setLayout() {

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            placeholder.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            ])
    }

    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}

extension SearchVC: UITableViewDataSource, UITableViewDelegate {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BeerCell.reuseIdentifier, for: indexPath) as! BeerCell
        let current = data[indexPath.row]
        cell.beerLabel.text = current.name
        cell.beerStyleLabel.text = current.style?.name

        if isLoadingCell(for: indexPath) {
//            cell.configure(with: .none)
        } else {
            if let icon = current.labels?.medium,
                let iconUrl = URL(string: icon) {
                getData(from: iconUrl) { data, response, error in
                    guard let data = data, error ==     nil else { return }
                    DispatchQueue.main.async() {
                        cell.beerIcon.image = UIImage(data: data)
                    }
                }
            }
        }

        cell.configure()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let infoVC = BeerInfoViewController()
        infoVC.beerId = data[indexPath.row].id
        self.navigationController?.pushViewController(infoVC, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (data.count - indexPath.row) == FetchThreshold && canFetchMoreResults {
            getNewData()
        }
    }
}

extension SearchVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        if !searchText.isEmpty {
            textForSearch = searchText
            currentPage = 1
            getNewData()
        }
    }
}

extension SearchVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            getNewData()
        }
    }
}

private extension SearchVC {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= data.count
    }

    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
}
