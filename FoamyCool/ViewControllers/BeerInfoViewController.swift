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
        view.image = UIImage(named: "defaultBeerLabel")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let categoryLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let beerStyleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let beerDesctiption: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    let favouriteButton: UIButton = {
        let button = UIButton()
        let size: CGFloat = 50
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(favPressed), for: .touchUpInside)
        button.widthAnchor.constraint(equalToConstant: size).isActive = true
        button.heightAnchor.constraint(equalToConstant: size).isActive = true
        return button
    }()

    var isFavourite: Bool = false {
        willSet {
            let image = UIImage(named: newValue ? "isFavourite" : "notFavourite")
            favouriteButton.setImage(image, for: .normal)
        }
    }

    var safeArea: UILayoutGuide!

    override func viewDidLoad() {
        super.viewDidLoad()
        getBeerData()
        categoryLabel.text = "Category"
        safeArea = view.layoutMarginsGuide
        self.isFavourite = UserDefaults.standard.isFavourite(id: beerId)
        view.backgroundColor = .white
        view.addSubview(beerImage)
        view.addSubview(categoryLabel)
        view.addSubview(beerStyleLabel)
        view.addSubview(beerDesctiption)
        view.insertSubview(favouriteButton, aboveSubview: beerDesctiption)
        setupLayout()
    }

    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    func getBeerData() {
        ServiceLayer.request(router: Router.getBeerBy(id: beerId)) { (result: Result<getBeerByIdResponse, Error>) in
            switch result {
            case .success:
                DispatchQueue.main.async {
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
                        print()
                    }
                }
            case .failure:
                print(result)
            }
        }
    }

    @objc func favPressed() {
        if isFavourite {
            UserDefaults.standard.removeElement(id: beerId)
        } else {
            UserDefaults.standard.addElement(id: beerId)
        }
        isFavourite.toggle()
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            beerImage.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            beerImage.widthAnchor.constraint(equalToConstant: imageSize),
            beerImage.heightAnchor.constraint(equalToConstant: imageSize),
            beerImage.topAnchor.constraint(equalTo: safeArea.topAnchor, constant:  10),
            categoryLabel.leadingAnchor.constraint(equalTo: beerImage.trailingAnchor, constant: 20),
            categoryLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 30),
            categoryLabel.trailingAnchor.constraint(lessThanOrEqualTo: safeArea.trailingAnchor),
            beerStyleLabel.leadingAnchor.constraint(equalTo: beerImage.trailingAnchor, constant: 20),
            beerStyleLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 10),
            beerStyleLabel.trailingAnchor.constraint(lessThanOrEqualTo: safeArea.trailingAnchor),
            beerDesctiption.topAnchor.constraint(equalTo: beerImage.bottomAnchor, constant: 20),
            beerDesctiption.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            beerDesctiption.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant:  10),
            beerDesctiption.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 10),
            favouriteButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20),
            favouriteButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
        ])
    }
}
