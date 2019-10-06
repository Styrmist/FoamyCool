//
//  BreweryInfoViewController.swift
//  FoamyCool
//
//  Created by Kyrylo Danylov on 9/29/19.
//  Copyright © 2019 Kyrylo Danylov. All rights reserved.
//

import UIKit

class BreweryInfoViewController: UIViewController {

    var brewId: String!
    var brewName: String!
    var brewIcon: String?
    var brewDescription: String?
    var beerData: [BeerItem]?

    let imageSize: CGFloat = 120

    let brewImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "defaultBrewLabel")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let beerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let brewDescriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var safeArea: UILayoutGuide!

    override func viewDidLoad() {
        super.viewDidLoad()
        getBeerData()
        self.title = brewName
        beerLabel.text = "Beer"
        safeArea = view.layoutMarginsGuide
        tableView.register(BeerCell.self, forCellReuseIdentifier: BeerCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        if let icon = self.brewIcon,
            let iconUrl = URL(string: icon) {
            self.getData(from: iconUrl) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async() {
                    self.brewImage.image = UIImage(data: data)
                }
            }
        }
        self.brewDescriptionLabel.text = self.brewDescription ?? ""
        view.backgroundColor = .white
        view.addSubview(brewImage)
        view.addSubview(beerLabel)
        view.addSubview(brewDescriptionLabel)
        view.addSubview(tableView)
        setupLayout()
    }

    func getBeerData() {
        ServiceLayer.request(router: Router.getBeersForBreweryBy(id: brewId)) { (result: Result<searchBeerResponse, Error>) in
            switch result {
            case .success:
                guard let responseData = try? result.get() else { return }
                if let beerData = responseData.data {
                    self.beerData = beerData
                } else {
                    self.beerData?.removeAll()
                }
                self.tableView.reloadData()
            case .failure:
                print(result)
            }
        }
    }

    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            brewImage.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            brewImage.widthAnchor.constraint(equalToConstant: imageSize),
            brewImage.heightAnchor.constraint(equalToConstant: imageSize),
            brewImage.topAnchor.constraint(equalTo: safeArea.topAnchor, constant:  10),
            beerLabel.topAnchor.constraint(equalTo: brewImage.bottomAnchor, constant: 20),
            beerLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            beerLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant:  10),
            beerLabel.heightAnchor.constraint(equalToConstant: 20),
            brewDescriptionLabel.leadingAnchor.constraint(equalTo: brewImage.trailingAnchor, constant: 20),
            brewDescriptionLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 30),
            brewDescriptionLabel.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: 20),
            brewDescriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: safeArea.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: beerLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant:  10),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 10),
            //            beerDesctiption.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0),
            //            beerDesctiption.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            //            beerDesctiption.widthAnchor.constraint(equalToConstant: scrollView.frame.width),
            //            beerDesctiption.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            ])
    }
}

extension BreweryInfoViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beerData?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BeerCell.reuseIdentifier, for: indexPath) as! BeerCell
        guard let current = beerData?[indexPath.row] else { return cell }
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let infoVC = BeerInfoViewController()
        infoVC.beerId = beerData?[indexPath.row].id
        self.navigationController?.pushViewController(infoVC, animated: true)
    }
}
