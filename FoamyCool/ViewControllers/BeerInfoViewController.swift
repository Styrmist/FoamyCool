//
//  BeerInfoViewController.swift
//  FoamyCool
//
//  Created by Kyrylo Danylov on 9/29/19.
//  Copyright © 2019 Kyrylo Danylov. All rights reserved.
//

import UIKit

class BeerInfoViewController: UIViewController {
    var beerId: String!
    var beerData: BeerItem!

    let imageSize: CGFloat = 120

    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let beerImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let beerStyleLabel = UILabel()
    let beerDesctiption = UILabel()

    var safeArea: UILayoutGuide!

    override func viewDidLoad() {
        super.viewDidLoad()
        getBeerData()
        safeArea = view.layoutMarginsGuide
        view.backgroundColor = .white
        view.addSubview(beerImage)
        view.addSubview(beerStyleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(beerDesctiption)
        setupLayout()
    }

    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    func getBeerData() {
        ServiceLayer.request(router: Router.getBeerBy(id: beerId)) { (result: Result<getBeerByIdResponse, Error>) in
            switch result {
            case .success:
                guard let responseData = try? result.get() else { return }
                print(responseData)
                if let data = responseData.data {
                    self.beerData = data
                    self.title = data.name
                    self.beerStyleLabel.text = data.style?.name
                    self.beerDesctiption.text = data.description ?? "This one has no description"
                    if let icon = data.labels?.medium,
                        let iconUrl = URL(string: icon) {
                        self.getData(from: iconUrl) { data, response, error in
                            guard let data = data, error == nil else { return }
                            DispatchQueue.main.async() {
                                self.beerImage.image = UIImage(data: data)	
                            }
                        }
                    }
                } else {
                    //TODO: create alert with ability to retry
                    print()
                }

            case .failure:
                print(result)
            }
        }
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            beerImage.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            beerImage.widthAnchor.constraint(equalToConstant: imageSize),
            beerImage.heightAnchor.constraint(equalToConstant: imageSize),
            beerImage.topAnchor.constraint(equalTo: safeArea.topAnchor, constant:  10),
            beerStyleLabel.leadingAnchor.constraint(equalTo: beerImage.trailingAnchor, constant: 20),
            beerStyleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            beerStyleLabel.trailingAnchor.constraint(lessThanOrEqualTo: safeArea.trailingAnchor, constant: -10),
            scrollView.topAnchor.constraint(equalTo: beerImage.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant:  10),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 10),
            beerDesctiption.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0),
            beerDesctiption.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            beerDesctiption.widthAnchor.constraint(equalToConstant: scrollView.frame.width),
        ])
    }
}
