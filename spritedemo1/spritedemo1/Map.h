//
//  Map.h
//  spritedemo1
//
//  Created by Milos Jovanovic on 2015-04-03.
//  Copyright (c) 2015 ca.cbc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreGraphics;

@interface Map : NSObject

- (BOOL)hex:(CGPoint)hex isAdjacentToHex:(CGPoint)otherHex;
- (BOOL)hexWithX:(int)x1 andY:(int)y1 isAdjacentToHexWithX:(int)x2 andY:(int)y2;
- (NSArray*)pathFromHex:(CGPoint)startingHex toHex:(CGPoint)targetHex;
@end
