//
//  Swiftris.swift
//  Swiftris
//
//  Created by MoJ on 5/26/17.
//  Copyright © 2017 MoJ. All rights reserved.
//

let NumColumns = 10
let NumRows = 20

let StartingColumn = 4
let StartingRow = 0

let PreviewColumn = 12
let PreviewRow = 1

protocol SwiftrisDelegate {
    // Invoked when the current round of Swiftris ends
    func gameDidEnd(swiftris: Swiftris)
    
    // Invoked after a new game has begun
    func gameDidBegin(swiftris: Swiftris)
    
    // Invoked when the falling shape has become part of the game board
    func gameShapeDidLand(swiftris: Swiftris)
    
    // Invoked when the falling shape has changed its location
    func gameShapeDidMove(swiftris: Swiftris)
    
    // Invoked when the falling shape has changed its location after being dropped
    func gameShapeDidDrop(swiftris: Swiftris)
    
    // Invoked when the game has reached a new level
    func gameDidLevelUp(swiftris: Swiftris)
}

class Swiftris {
    
    var blockArray: Array2D<Block>
    var nextShape: Shape?
    var fallingShape: Shape?
    
    /*
     Swiftris notifies the delegate of events throughout the course of the game. 
     In this case, GameViewController will attach itself as the delegate to update
     the user interface and react to game state changes whenever something occurs 
     inside of the Swiftris class.
     
     Swiftris will work on a trial-and-error basis. The user interface, 
     GameViewController, will ask Swiftris to move its falling shape either down, 
     left, or right. Swiftris will accept this request, move the shape and then detect 
     whether its new position is legal. If so, the shape will remain, otherwise it will 
     revert to its original location.
     
    */
    var delegate:SwiftrisDelegate?
    
    init() {
        blockArray = Array2D<Block>(columns: NumColumns, rows: NumRows)
        fallingShape = nil
        nextShape = nil
    }
    
    func beginGame() {
        if (nextShape == nil) {
            nextShape = Shape.random(startingColumn: PreviewColumn, startingRow: PreviewRow)
        }
        delegate?.gameDidBegin(swiftris: self)
    }
    
    func newShape() -> (fallingShape:Shape?, nextShape:Shape?) {
        fallingShape = nextShape
        nextShape = Shape.random(startingColumn: PreviewColumn, startingRow: PreviewRow)
        fallingShape?.moveTo(column: StartingColumn, row: StartingRow)
        
        // The game ends when a new shape located at the designated starting location collides with existing blocks.
        guard detectIllegalPlacement() == false else {
            nextShape = fallingShape
            nextShape!.moveTo(column: PreviewColumn, row: PreviewRow)
            endGame()
            return (nil, nil)
        }
        
        return (fallingShape, nextShape)
    }
    
    
    func detectIllegalPlacement() -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        for block in shape.blocks {
            if block.column < 0 || block.column >= NumColumns || block.row < 0 || block.row >= NumRows {
                return true
            } else if blockArray[block.column, block.row] != nil {
                return true
            }
        }
        return false
    }
    
    func endGame() {
        delegate?.gameDidEnd(swiftris: self)
    }

    
}
