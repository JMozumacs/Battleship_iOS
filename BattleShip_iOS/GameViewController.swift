//
//  GameViewController.swift
//  BattleShip_iOS
//
//  Created by Janis Mozumacs on 15/12/2020.
//

import UIKit

class GridCellItem {
    
}

class GameViewController: UIViewController {
    
    var gameDataSource: [GridCellItem] = []
    
    @IBOutlet weak var gridCollection: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        gridCollection.register(UINib(nibName: "GridCell", bundle: .main), forCellWithReuseIdentifier: "GridCell")
    }


    @IBAction func startAction(_ sender: Any) {
        
    }
}

extension GameViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = gameDataSource
    }
}
