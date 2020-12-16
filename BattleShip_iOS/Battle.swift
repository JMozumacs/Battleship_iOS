//
//  Battle.swift
//  BattleShip_iOS
//
//  Created by Arturs Sosnars on 16/12/2020.
//

import Foundation

class Battle {
    
    typealias BoardType = [[BoardTile]]
    
    enum BoardTile: CustomStringConvertible {
        case water, miss
        case undamaged(Ship)
        case damaged(Ship)
        case sunk(Ship)
        
        var description: String {
            switch self {
            case .water:
                return " "
            case .miss:
                return "~"
            case .undamaged(let s):
                return s.rawValue
            case .damaged(_):
                return "X"
            case .sunk(let s):
                return s.rawValue.lowercased()
            }
        }
        
        var isUndamaged: Bool {
            switch self {
            case .undamaged(_):
                return true
            default:
                return false
            }
        }
        
        var isShip: Bool {
            switch self {
            case .undamaged(_), .damaged(_), .sunk(_):
                return true
            default:
                return false
            }
        }
    }
    
    enum Ship: String {
        case Carrier = "A", Battleship = "B", Submarine = "S", Cruiser = "C", Destroyer = "D"
        
        var shipLength: Int {
            switch self {
            case .Carrier:
                return 5
            case .Battleship:
                return 4
            case .Cruiser, .Submarine:
                return 3
            case .Destroyer:
                return 2
            }
        }
        
        static var allShips: [Ship] {
            return [Carrier, Battleship, Submarine, Cruiser, Destroyer]
        }
        
        static var nrOfShips: Int {
            return allShips.count
        }
    }
    
    enum GameState: String {
        case Setup = "Setup", SetupComlete = "Setup Complete", Playing = "Playing", GameOver = "Game Over"
    }
    
    enum Message: String {
        case Hit, Miss
        case ShipNotAllowedHere = "Ship Not Allowed Here", ShipAlreadyPlaced = "Ship Already Placed"
        case ShipPlaced = "Ship Placed", AllShipsPlaced = "All Ships Placed"
        case GameStarted = "Game Has Started", NotThisPlayersTurn = "Not This Players Turn"
        case GameNotInPlay = "Game Not In Play", HitSameSpot = "Hit Same Spot", MissSameSpot = "Miss Same Spot"
    }
    
    struct Operation {
        let message: Message
        let battle: Battle
        let justSunk: Ship?
        
        init(message: Message, battle: Battle, justSunk: Ship? = .none) {
            self.message = message
            self.battle = battle
            self.justSunk = justSunk
        }
    }
    
    enum Player: String {
        case Player1 = "Player 1", Player2 = "Player 2"
    }
    
    struct BattleStore {
        enum BoardState {
            case BoardSetup, BoardSetupComplete
        }
        
        private var board1: BoardType
        private var board2: BoardType
        
        init(yDim: Int = 8, xDim: Int = 8) {
            let emptyRow = [BoardTile](repeating: BoardTile.water, count: xDim)
            board1 = BoardType(repeating: emptyRow, count: yDim)
            board2 = board1
        }
        
        //update the board for player
        mutating func setBoard(_ board: BoardType, for player: Player) {
            switch player {
            case .Player1:
                board1 = board
            case .Player2:
                board2 = board
            }
        }
        
        func boardForPlayer(_ player: Player) -> BoardType {
            return player == Player.Player1 ? board1 : board2
        }
        
        func stateForPlayer(_ player: Player) -> BoardState {
            return BattleStore.numberOfShipsOnBoard(boardForPlayer(player)) == Ship.nrOfShips ? .BoardSetupComplete : .BoardSetup
        }
        
        func setupComplete() -> Bool {
            return stateForPlayer(Player.Player1) == .BoardSetupComplete && stateForPlayer(Player.Player2) == .BoardSetupComplete
        }
        
        static func isShipUndamaged(_ ship: Ship, board: BoardType) -> Bool {
            let shipSections = board.reduce([], +).filter{$0.isUndamaged && $0.description.uppercased() == ship.rawValue}
            return shipSections.count > 0
        }
        
        static func isShipOnBoard(_ ship: Ship, _ board: BoardType) -> Bool {
            let shipSections = board.reduce([], +).filter{$0.isShip && $0.description.uppercased() == ship.rawValue}
            return shipSections.count > 0
        }
        
        static func numberOfShipsOnBoard(_ board: BoardType) -> Int {
            let shipSections = board.reduce([], +).filter{$0.isShip}.map{$0.description.uppercased()}
            return Set(shipSections).count
        }
        
        static func numberOfUndamagedShipsOnBoard(_ board: BoardType) -> Int {
            let shipSections = board.reduce([], +).filter{$0.isUndamaged}.map{$0.description.uppercased()}
            return Set(shipSections).count
        }
        
        static let dimYx = {(board: BoardType) -> (yDim :Int, xDim: Int) in (yDim: board.count, xDim: board.count > 0 ? board[0].count : 0)}
        
        static func pairsForBoard(_ board: BoardType) -> [(y: Int, x: Int)] {
            let dim = dimYx(board)
            return (0 ..< dim.yDim).map {y in (0 ..< dim.xDim).map{(y: y, x: $0)}}.reduce([], +)
        }
        
        static func pairsForShip(_ ship: Ship, on board: BoardType) -> [(y: Int, x: Int)] {
            let pairs = BattleStore.pairsForBoard(board)
            return pairs.filter {y, x in
                switch board[y][x] {
                case .undamaged(ship), .damaged(ship), .sunk(ship): return true
                default: return false
                }
            }
        }
        
        // sink every section of a ship
        static func sinkShip(ship: Ship, on board: BoardType) -> BoardType {
            var vBoard = board
            for pair in BattleStore.pairsForShip(ship, on: board) {
                vBoard[pair.y][pair.x] = .sunk(ship)
            }
            return vBoard
        }
        
        // checks that the generated pairs are over water
        private static func pairsOverWaterForBoard(_ board: BoardType, pairs: [(y:Int, x:Int)]) -> [(y:Int, x:Int)]? {
            let dim = dimYx(board)
            for (y, x) in pairs {
                if x < 0 || y < 0 || x >= dim.xDim || y >= dim.yDim {
                    return nil
                }
                switch board[y][x] {
                case .water: continue
                default: return nil
                }
            }
            return pairs
        }
        
        // generate pairs for a ship and check all the ship is over water
        static func pairsOverWaterForBoard(board: BoardType, isVertical: Bool, y: Int, x: Int, len: Int) -> [(y:Int, x:Int)]? {
            if isVertical {
                return BattleStore.pairsOverWaterForBoard(board, pairs: (y ..< y + len).map { (y: $0, x: x) })
            } else {
                return BattleStore.pairsOverWaterForBoard(board, pairs: (x ..< x + len).map { (y: y, x: $0) })
            }
        }
    }
    
    private let battleStore: BattleStore
    private let playerLastShot: Player?
    let gameState: GameState
    
    private init(battleStore: BattleStore, gameState: GameState, playerLastShot: Player?) {
        self.battleStore = battleStore
        self.playerLastShot = playerLastShot
        self.gameState = gameState
    }
    
    convenience init(yDim: Int = 10, xDim: Int = 10) {
        self.init(battleStore: BattleStore(yDim: yDim, xDim: xDim), gameState: .Setup, playerLastShot: .none)
    }
    
    private func NewBattle(player: Player, board: BoardType, firedOnByPlayer: Player? = .none, didLose: Bool = false) -> Battle {
        var newBattleStore = battleStore
        newBattleStore.setBoard(board, for: player)
        
        let newGameState: GameState
        switch gameState {
        case .Setup where newBattleStore.setupComplete():
            newGameState = .SetupComlete
        case .SetupComlete where firedOnByPlayer != nil:
            newGameState = .Playing
        case .Playing where didLose:
            newGameState = .GameOver
        default:
            newGameState = gameState
        }
        
        return Battle(battleStore: newBattleStore, gameState: newGameState, playerLastShot: firedOnByPlayer ?? playerLastShot)
    }
    
    func addShip(_ ship: Ship, player: Player, y: Int, x: Int, isVertical: Bool = false) -> Operation {
        let board = battleStore.boardForPlayer(player)
        switch battleStore.stateForPlayer(player) {
        case .BoardSetupComplete:
            return Operation(message: .AllShipsPlaced, battle: self)
        case .BoardSetup where BattleStore.isShipOnBoard(ship, board):
            return Operation(message: .ShipAlreadyPlaced, battle: self)
        default:
            break
        }
        
        if let pairs = BattleStore.pairsOverWaterForBoard(board: board, isVertical: isVertical, y: y, x: x, len: ship.shipLength) {
            var vBoard = board
            for (x, y) in pairs {
                vBoard[y][x] = BoardTile.undamaged(ship)
            }
            
            return Operation(message: .ShipPlaced, battle: NewBattle(player: player, board: vBoard))
        } else {
            return Operation(message: .ShipNotAllowedHere, battle: self)
        }
    }
    
    func shootAtPlayer(_ player: Player, y: Int, x: Int) -> Operation {
        let firingPlayer = player == Player.Player1 ? Player.Player1 : Player.Player2
        switch gameState {
        case .Playing, .SetupComlete:
            switch playerLastShot {
            case .some(firingPlayer):
                return Operation(message: .NotThisPlayersTurn, battle: self)
            default:
                break
            }
        default:
            return Operation(message: .GameNotInPlay, battle: self)
        }
        
        var vBoard = battleStore.boardForPlayer(player)
        var vDidLose = false
        var vJustSank: Ship? = .none
        let message: Message
        switch vBoard[y][x] {
        case let .undamaged(ship):
            message = .Hit
            vBoard[y][x] = .damaged(ship)
            if !BattleStore.isShipUndamaged(ship, board: vBoard) {
                vBoard = BattleStore.sinkShip(ship: ship, on: vBoard)
                vDidLose = BattleStore.numberOfUndamagedShipsOnBoard(vBoard) == 0
                vJustSank = ship
            }
        case .damaged(_), .sunk(_):
            message = .HitSameSpot
        case .water:
            message = .Miss
            vBoard[y][x] = .miss
        case .miss:
            message = .MissSameSpot
        }
        
        return Operation(message: message,
                         battle: NewBattle(player: player, board: vBoard, firedOnByPlayer: firingPlayer, didLose: vDidLose),
                         justSunk: vJustSank)
    }
    
    func randomBoardForPlayer(_ player: Player, ships: [Ship] = Ship.allShips) -> Operation {
        if ships.count == 0 {
            return Operation(message: .AllShipsPlaced, battle: self)
        }
        let board = battleStore.boardForPlayer(player)
        let ship = ships[0]
        let restOfShips = Array(ships.dropFirst())
        
        let potencialPossitions = BattleStore.pairsForBoard(board)
        let pairs: [(y: Int, x: Int)]
        let isVertical: Bool = arc4random() % 2 == 0
        pairs = potencialPossitions.filter{BattleStore.pairsOverWaterForBoard(board: board, isVertical: isVertical, y: $0.y, x: $0.x, len: ship.shipLength) != nil}
        
        let randomPairs = pairs.sorted{_, _ in arc4random() % 2 == 0}
        for pair in randomPairs {
            let battleOperation = addShip(ship, player: player, y: pair.y, x: pair.x)
            if battleOperation.message == .ShipNotAllowedHere {
                NSLog("Pair geeration error")
            }
            switch battleOperation.battle.randomBoardForPlayer(player, ships: restOfShips) {
            case let battleOperation where battleOperation.message == .AllShipsPlaced:
                return battleOperation
            default:
                break
            }
        }
        return Operation(message: .ShipNotAllowedHere, battle: self)
    }
    
    func boardForPlayer(_ player: Player) -> BoardType {
        return battleStore.boardForPlayer(player)
    }
    
    func whoWon() -> Player? {
        switch gameState {
        case .GameOver:
            return playerLastShot
        default:
            return nil
        }
    }
    
}

func !=(a:Battle.BoardTile, b:Battle.BoardTile) -> Bool {
    return !(==)(a, b)
}

func ==(a:Battle.BoardTile, b:Battle.BoardTile) -> Bool {
    switch(a, b) {
    case (.water, .water), (.miss, .miss):
        return true
    case let (s1, s2):
        return s1.description == s2.description
    }
}
