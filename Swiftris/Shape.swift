//
//  Shape.swift
//  Swiftris
//
//  Created by MoJ on 5/26/17.
//  Copyright © 2017 MoJ. All rights reserved.
//

import SpriteKit


let NumOrientations: UInt32 = 4

enum Orientation: Int, CustomStringConvertible {
    case Zero = 0, Ninety, OneEighty, TwoSeventy
    
    var description: String {
        switch self {
        case .Zero:
            return "0"
        case .Ninety:
            return "90"
        case .OneEighty:
            return "180"
        case .TwoSeventy:
            return "270"
        }
    }
    
    static func random() -> Orientation {
        return Orientation(rawValue: Int(arc4random_uniform(NumOrientations)))!
    }
    
    static func rotate(o: Orientation, clockWise: Bool) -> Orientation {
        var rotated = o.rawValue + (clockWise ? 1 : -1)
        
        if rotated > Orientation.TwoSeventy.rawValue {
            rotated = Orientation.Zero.rawValue
        } else if rotated < Orientation.Zero.rawValue {
            rotated = Orientation.TwoSeventy.rawValue
        }
        
        return Orientation(rawValue: rotated)!
    }
}

// The number of total shape types
let NumShapeTypes: UInt32 = 7

// Shape Block indexes
let FirstBlockIdx: Int = 0
let SecondBlockIdx: Int = 1
let ThirdBlockIdx: Int = 2
let FourthBlockIdx: Int = 3

class Shape: Hashable, CustomStringConvertible {
    
    // The color of the shape
    let color: BlockColor
    
    // The blocks of the shape
    var blocks = Array<Block>()
    
    // The current orientation of the shape
    var orientation: Orientation
    
    // The column and row representing the shape's anchor point
    var column, row: Int
    
    // Override
    var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [:]
    }
    
    // Override
    var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [:]
    }
    
    var bottomBlocks: Array<Block> {
        guard let bottomBlocks = bottomBlocksForOrientations[orientation] else {
            return []
        }
        return bottomBlocks
    }
    
    var hashValue: Int {
        return blocks.reduce(0) {$0.hashValue ^ $1.hashValue}
    }
    
    var description: String {
        return "\(color) block facing \(orientation): \(blocks[FirstBlockIdx]), \(blocks[SecondBlockIdx]), \(blocks[ThirdBlockIdx]), \(blocks[FourthBlockIdx])"
    }
    
    init(column: Int, row: Int, color: BlockColor, o: Orientation) {
        self.color = color
        self.column = column
        self.row = row
        self.orientation = o
        initializeBlocks()
    }
    
    convenience init(column:Int, row:Int) {
        self.init(column:column, row:row, color:BlockColor.random(), o:Orientation.random())
    }
    
    static func ==(lhs: Shape, rhs: Shape) -> Bool {
        return lhs.row == rhs.row && lhs.column == rhs.column
    }
    
    final func initializeBlocks() {
        guard let blockRowColumnTranslations = blockRowColumnPositions[orientation] else {
            return
        }
        
        blocks = blockRowColumnTranslations.map { (diff) -> Block in
            return Block(column: column + diff.columnDiff, row: row + diff.rowDiff, color: color)
        }
    }

}