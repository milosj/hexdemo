//
//  Map.h
//  spritedemo1
//
//  Created by Milos Jovanovic on 2015-04-03.
//  Copyright (c) 2015 ca.cbc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreGraphics;

typedef NS_ENUM(NSUInteger, direction) {
    any = -1,
    nw = 0,
    ne = 1,
    e  = 2,
    se = 3,
    sw = 4,
    w  = 5
};



@interface Map : NSObject

- (BOOL)hex:(CGPoint)hex isAdjacentToHex:(CGPoint)otherHex;
- (BOOL)hexWithX:(int)x1 andY:(int)y1 isAdjacentToHexWithX:(int)x2 andY:(int)y2;
- (NSArray*)pathFromHex:(CGPoint)startingHex toHex:(CGPoint)targetHex;
- (id)tileAtMapX:(int)x andMapY:(int)y;
- (id)tileAtMapCoordinates:(CGPoint)coordinates;
- (NSArray*)vectorize;

@property(strong, nonatomic) NSMutableArray *allTiles;
@property(strong, nonatomic) NSMutableArray *rows;
@property(assign, nonatomic) CGSize mapSize;

@end
