//
//  Map.m
//  spritedemo1
//
//  Created by Milos Jovanovic on 2015-04-03.
//  Copyright (c) 2015 ca.cbc. All rights reserved.
//

#import "Map.h"
@import UIKit;

/**
  1 2        1 2
 3 4 5       3 4 5
  6 7 8      6 7 8
 **/


@implementation Map


- (BOOL)hex:(CGPoint)hex isAdjacentToHex:(CGPoint)otherHex {
    return [self hexWithX:(int)hex.x andY:(int)hex.y isAdjacentToHexWithX:(int)otherHex.x andY:(int)otherHex.y];
}

- (BOOL)hexWithX:(int)x1 andY:(int)y1 isAdjacentToHexWithX:(int)x2 andY:(int)y2 {
    if (x2 >= x1-1 && x2 <= x1+1 && y2 >= y1-1 && y2 <= y1+1) {
        if (y1 % 2 == 0) {
            if (y2 != y1) {
                return x2 >= x1;
            } else {
                return YES;
            }
        } else {
            if (y2 != y1) {
                return x2 <= x1;
            } else {
                return YES;
            }
        }
    }
    return NO;
}

- (NSArray*)hexesBorderingHex:(CGPoint)hex {
    return [self hexesBorderingHexWithX:(int)hex.x andY:(int)hex.y];
}

- (NSArray*)hexesBorderingHexWithX:(int)x andY:(int)y {
    NSMutableArray* hexes = [NSMutableArray new];
    [hexes addObject:[NSValue valueWithCGPoint:CGPointMake(x+1, y)]];
    [hexes addObject:[NSValue valueWithCGPoint:CGPointMake(x-1, y)]];
    [hexes addObject:[NSValue valueWithCGPoint:CGPointMake(x, y+1)]];
    [hexes addObject:[NSValue valueWithCGPoint:CGPointMake(x, y-1)]];
    if (y%2==0) {
        [hexes addObject:[NSValue valueWithCGPoint:CGPointMake(x+1,y+1)]];
        [hexes addObject:[NSValue valueWithCGPoint:CGPointMake(x+1, y-1)]];
    } else {
        [hexes addObject:[NSValue valueWithCGPoint:CGPointMake(x-1,y+1)]];
        [hexes addObject:[NSValue valueWithCGPoint:CGPointMake(x-1, y-1)]];
    }
    return hexes;
}

- (BOOL)lineFromHex:(CGPoint)startingHex toHex:(CGPoint)middleHex approachesHex:(CGPoint)endHex {

    if (startingHex.x > middleHex.x && startingHex.x < endHex.x) {
        return NO;
    }
    if (startingHex.x < middleHex.x && startingHex.x > endHex.x) {
        return NO;
    }
    
    if (startingHex.y > middleHex.y && startingHex.y < endHex.y) {
        return NO;
    }
    if (startingHex.y < middleHex.y && startingHex.y > endHex.y) {
        return NO;
    }
    return YES;
}

- (NSArray*)pathFromHex:(CGPoint)startingHex toHex:(CGPoint)targetHex {
    return [self pathFromHex:startingHex toHex:targetHex withDepth:10 andCurrentPath:[NSMutableArray new]];
}
- (NSArray*)pathFromHex:(CGPoint)startingHex toHex:(CGPoint)targetHex withDepth:(int)depth andCurrentPath:(NSMutableArray*)oldPath {
    if (depth == 0) {
        return nil;
    }
    if (CGPointEqualToPoint(startingHex, targetHex)) {
        return @[[NSValue valueWithCGPoint:startingHex]];
    }
    
    if ([self hex:startingHex isAdjacentToHex:targetHex]) {
        return @[[NSValue valueWithCGPoint:startingHex], [NSValue valueWithCGPoint:targetHex]];
    }
    NSArray* shortestPath;
    NSMutableArray* newPath = [oldPath mutableCopy];
    [newPath addObject:[NSValue valueWithCGPoint:startingHex]];
    for (NSValue* hexV in [self hexesBorderingHex:startingHex]) {
        CGPoint hex = [hexV CGPointValue];
        if ([self lineFromHex:startingHex toHex:hex approachesHex:targetHex]) {
            BOOL hexAlreadyUsed = NO;
            for (NSValue* oldhex in oldPath) {
                if (CGPointEqualToPoint([oldhex CGPointValue], hex)) {
                    hexAlreadyUsed = YES;
                    break;
                }
            }
            if (!hexAlreadyUsed) {
                NSArray* path = [self pathFromHex:hex toHex:targetHex withDepth:depth-1 andCurrentPath:newPath];
                if (path && (!shortestPath || path.count < shortestPath.count)) {
                    shortestPath = path;
                    depth = MIN(depth, (int)shortestPath.count);
                }
            }
        }
    }
    if (shortestPath && CGPointEqualToPoint([[shortestPath lastObject] CGPointValue], targetHex)) {
        NSMutableArray* path = [NSMutableArray new];
        [path addObject:[NSValue valueWithCGPoint:startingHex]];
        [path addObjectsFromArray:shortestPath];
        return path;
    } else {
        return nil;
    }
}

//- (NSArray*)pathFromHexWithX:(int)startingX andY:(int)startingY toHexWithX:(int)targetX andY:(int)targetY {
//    NSArray* adjacentStart = [self hexesBorderingHexWithX:startingX andY:startingY];
//    
//    
//    
////    NSArray* adjacentTarget = [self hexesBorderingHexWithX:targetX andY:targetY];
//    
//}

@end
