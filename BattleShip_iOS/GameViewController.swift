//
//  GameViewController.swift
//  BattleShip_iOS
//
//  Created by Janis Mozumacs on 15/12/2020.
//

import UIKit

class GameViewController: UIViewController {
    
    var battle = Battle(yDim: 8, xDim: 8)
    var currentPlayer: Battle.Player = .Player1
    
    @IBOutlet weak var gridCollection: UICollectionView! {
        didSet {
            gridCollection.delegate = self
            gridCollection.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gridCollection.register(UINib(nibName: "GridCell", bundle: .main), forCellWithReuseIdentifier: "GridCell")
        gridCollection.layer.borderColor = UIColor.black.cgColor
        gridCollection.layer.borderWidth = 1
        
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        flow.minimumInteritemSpacing = 0;
        flow.minimumLineSpacing = 0;
        
        gridCollection.collectionViewLayout = flow
    }


    @IBAction func startAction(_ sender: Any) {
        // restarts game
        battle = Battle(yDim: 8, xDim: 8)
        gridCollection.reloadData()
    }
}

extension GameViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let board = battle.boardForPlayer(.Player1)
        return board.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let board = battle.boardForPlayer(.Player1)
        return board[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let board = battle.boardForPlayer(.Player1)
        let tile = board[indexPath.row][indexPath.section]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as? GridCell ?? GridCell()
        
        cell.setup(with: tile)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
         return 0
     }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Double(collectionView.frame.width) / Double(battle.boardForPlayer(currentPlayer).count)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
   
    }
}
