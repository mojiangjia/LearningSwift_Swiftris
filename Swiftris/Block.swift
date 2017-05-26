//
//  Block.swift
//  Swiftris
//
//  Created by MoJ on 5/26/17.
//  Copyright © 2017 MoJ. All rights reserved.
//

import SpriteKit


let NumberOfColors: UInt32 = 6

// BlockColor type is Int and it implements the CustomStringConvertible protocol.
// Classes, structures and enums that implement CustomStringConvertible are capable of generating human-readable strings when debugging or printing their value to the console.
enum BlockColor: Int, CustomStringConvertible {

    // list of enumerable options, one for each color beginning with Blue at 0 and ending at 5 with Yellow
    case Blue = 0, Orange, Purple, Red, Teal, Yellow
    
    // A computed property is one that behaves like a typical variable, but when accessing it, a code block generates its value each time. We could have put this inside of a function named, getSpriteName() but a computed property is the better design choice.
    var spriteName: String {
        switch self {
        case .Blue:
            return "blue"
        case .Orange:
            return "orange"
        case .Purple:
            return "purple"
        case .Red:
            return "red"
        case .Teal:
            return "teal"
        case .Yellow:
            return "yellow"
        }
    }
    
    var description: String {
        return self.spriteName
    }
    
    static func random() -> BlockColor {
        return BlockColor(rawValue:Int(arc4random_uniform(NumberOfColors)))!
    }
}


class Block: Hashable, CustomStringConvertible {

    let color: BlockColor
    
    var column: Int
    var row: Int
    var sprite: SKSpriteNode?
    
    var spriteName: String {return color.spriteName}
    
    // return the exclusive-or of our row and column properties to generate a unique integer for each Block
    var hashValue: Int {return self.column ^ self.row}
    
    var description: String {return "\(color): [\(column), \(row)]"}
    
    init(column: Int, row: Int, color: BlockColor) {
        self.column = column
        self.row = row
        self.color = color
    }
    
    // It returns true if both Blocks are in the same location and of the same color. The Hashable protocol inherits from the Equatable protocol, which requires us to provide this operator.
    static func ==(lhs: Block, rhs: Block) -> Bool {
        return lhs.color.rawValue == rhs.color.rawValue && lhs.column == rhs.column && lhs.row == rhs.row
    }
}
