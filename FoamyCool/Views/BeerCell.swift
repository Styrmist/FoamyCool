//
//  BeerCell.swift
//  FoamyCool
//
//  Created by Kyrylo Danylov on 9/28/19.
//  Copyright © 2019 Kyrylo Danylov. All rights reserved.
//

import UIKit

class BeerCell: UITableViewCell, ReuseIdentifying {
    let imageSize: CGFloat = 100

    let beerIcon:  UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "defaultBeerLabel")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let beerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let beerStyleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        return label
    }()

    let nextArrow: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "nextArrow")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure() {
        self.addSubview(beerIcon)
        self.addSubview(beerLabel)
        self.addSubview(beerStyleLabel)
        self.addSubview(nextArrow)
        setupLayouts()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        beerIcon.image = UIImage(named: "defaultBeerLabel")
        beerLabel.text = ""
        beerStyleLabel.text = ""
        setupLayouts()
    }

    func setupLayouts() {
        NSLayoutConstraint.activate([
            nextArrow.heightAnchor.constraint(equalToConstant: self.frame.height / 2),
            nextArrow.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            nextArrow.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            nextArrow.widthAnchor.constraint(equalToConstant: self.frame.height / 2),
            beerIcon.heightAnchor.constraint(equalToConstant: imageSize),
            beerIcon.widthAnchor.constraint(equalToConstant: imageSize),
            beerIcon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            beerIcon.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            beerLabel.leadingAnchor.constraint(equalTo: beerIcon.trailingAnchor, constant: 10),
            beerLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            beerLabel.trailingAnchor.constraint(lessThanOrEqualTo: nextArrow.leadingAnchor, constant: -10),
            beerStyleLabel.leadingAnchor.constraint(equalTo: beerLabel.leadingAnchor),
            beerStyleLabel.topAnchor.constraint(equalTo: beerLabel.bottomAnchor, constant: 20),
            beerStyleLabel.trailingAnchor.constraint(lessThanOrEqualTo: nextArrow.leadingAnchor, constant: -10),
            ])
    }
}
