//
//  LocationVC.swift
//  FoamyCool
//
//  Created by Kyrylo Danylov on 9/21/19.
//  Copyright © 2019 Kyrylo Danylov. All rights reserved.
//

import UIKit
import CoreLocation

class LocationVC: UIViewController {

    let tableView: UITableView = {
        let view = UITableView(frame: UIScreen.main.bounds, style: .plain)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.rowHeight = 80
        view.tableFooterView = UIView(frame: .zero)
        view.separatorStyle = .none
        return view
    }()

    let placeholder: UILabel = {
        let label = UILabel()
        label.text = "There are no breweries here"
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

    var data = [BreweryItem]() {
        willSet {
            placeholder.isHidden = newValue.count != 0 ? true : false
        }
    }

    let locationManager = CLLocationManager()
    var coords: (lat: Double, lon: Double) = (lat: 0, lon: 0) {
        willSet {
            locationChanged()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Location"
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(placeholder)
        safeArea = view.layoutMarginsGuide
        tableView.register(BreweryCell.self, forCellReuseIdentifier: BreweryCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.startMonitoringVisits()
        setLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        locationManager.startUpdatingLocation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        locationManager.stopUpdatingLocation()
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

    func locationChanged() {
        ServiceLayer.request(router: Router.getBreweriesByLocation(lat: String(coords.lat), lng: String(coords.lon))) { (result: Result<SearchBreweryResponse, Error>) in
            switch result {
            case .success:
                guard let responseData = try? result.get() else { return }
                if let brewData = responseData.data {
                    self.data = brewData
                } else {
                    self.data.removeAll()
                }
                self.tableView.reloadData()
            case .failure:
                print(result)
            }
        }
    }
}

extension LocationVC: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BreweryCell.reuseIdentifier, for: indexPath) as! BreweryCell
        let current = data[indexPath.row]
        cell.brewLabel.text = current.name
        cell.configure()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let infoVC = BreweryInfoViewController()
        let current = data[indexPath.row]
        infoVC.brewId = current.breweryId
        infoVC.brewName = current.name
        infoVC.brewIcon = current.brewery?.images?.squareMedium
        infoVC.brewDescription = current.brewery?.description
        self.navigationController?.pushViewController(infoVC, animated: true)
    }
}

extension LocationVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last?.coordinate else { return }
        coords = (lat: lastLocation.latitude, lon: lastLocation.longitude)
    }
}
