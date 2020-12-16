//
//  GridCell.swift
//  BattleShip_iOS
//
//  Created by Janis Mozumacs on 15/12/2020.
//

import UIKit

class GridCell: UICollectionViewCell {

    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(with tile: Battle.BoardTile) {
        title.text = tile.description
    }

}
