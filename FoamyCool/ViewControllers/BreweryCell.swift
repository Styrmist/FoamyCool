//
//  BreweryCell.swift
//  FoamyCool
//
//  Created by Kyrylo Danylov on 9/29/19.
//  Copyright © 2019 Kyrylo Danylov. All rights reserved.
//

import UIKit

class BreweryCell: UITableViewCell, ReuseIdentifying {

    let brewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
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
        self.addSubview(brewLabel)
        self.addSubview(nextArrow)
        setupLayouts()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        brewLabel.text = ""
        setupLayouts()
    }

    func setupLayouts() {
        NSLayoutConstraint.activate([
            nextArrow.heightAnchor.constraint(equalToConstant: self.frame.height / 2),
            nextArrow.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            nextArrow.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            nextArrow.widthAnchor.constraint(equalToConstant: self.frame.height / 2),
            brewLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            brewLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            brewLabel.trailingAnchor.constraint(lessThanOrEqualTo: nextArrow.leadingAnchor, constant: -10),
            ])
    }

}
