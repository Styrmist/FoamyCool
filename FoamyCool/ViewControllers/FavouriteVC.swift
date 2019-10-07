//
//  FavouriteVC.swift
//  FoamyCool
//
//  Created by Kyrylo Danylov on 9/21/19.
//  Copyright © 2019 Kyrylo Danylov. All rights reserved.
//

import UIKit

class FavouriteVC: UIViewController {

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
        label.text = "There is nothing here, first fav something"
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var navigationBar: UINavigationBar = {
        let screenWidth = UIScreen.main.bounds.width
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
        return navBar
    }()

    var safeArea: UILayoutGuide!

    var data = [BeerItem]() {
        willSet {
            placeholder.isHidden = newValue.count != 0 ? true : false
        }
        didSet {
            tableView.reloadData()
        }
    }

    var savedIds: [String] = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        savedIds = UserDefaults.standard.savedBeerIds
        for id in savedIds {
            getBeer(by: id)
        }
        tableView.delegate = self
        tableView.dataSource = self
        self.title = "Favourite"
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(placeholder)
        safeArea = view.layoutMarginsGuide
        tableView.register(BeerCell.self, forCellReuseIdentifier: BeerCell.reuseIdentifier)
        setLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let newIds = UserDefaults.standard.savedBeerIds
        let difference = Set(savedIds).symmetricDifference(newIds)
        for item in difference {
            if savedIds.contains(item) {
                savedIds.removeAll(where: { $0 == item})
                data.removeAll(where: { $0.id == item})
            } else {
                savedIds.append(item)
                getBeer(by: item)
            }
        }
    }

    func getBeer(by beerId: String) {
        ServiceLayer.request(router: Router.getBeerBy(id: beerId)) { (result: Result<GetBeerByIdResponse, Error>) in
            switch result {
            case .success:
                guard let responseData = try? result.get() else { return }
                if let beerData = responseData.data {
                    self.data.append(beerData)
                } else {
                    self.data.removeAll()
                }
                self.tableView.reloadData()
            case .failure:
                print(result)
            }
        }
    }

    func setLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            placeholder.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            ])
    }

    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}

extension FavouriteVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BeerCell.reuseIdentifier, for: indexPath) as! BeerCell
        let current = data[indexPath.row]
        cell.beerLabel.text = current.name
        cell.beerStyleLabel.text = current.style?.name
        if let icon = current.labels?.medium,
            let iconUrl = URL(string: icon) {
            getData(from: iconUrl) { data, response, error in
                guard let data = data, error ==     nil else { return }
                DispatchQueue.main.async() {
                    cell.beerIcon.image = UIImage(data: data)
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
}
