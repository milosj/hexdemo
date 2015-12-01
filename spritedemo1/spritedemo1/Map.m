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


static const int MAP_W = 10;
static const int MAP_H = 10;

static const int NO_POINT = -100;

@interface Map(private)
-(float)perlinForX:(int)x andY:(int)y;
@end

@implementation Map


-(id)init {
    NSLog(@"Generating map...");
    if ((self = [super init])) {
        self.mapSize = CGSizeMake(MAP_W, MAP_H);
        self.rows = [NSMutableArray arrayWithCapacity:self.mapSize.height];
        self.allTiles = [NSMutableArray arrayWithCapacity:self.mapSize.width*self.mapSize.height];
        
        for (int y=0; y<self.mapSize.height; y++) {
            //NSString* line = @"";
            NSMutableArray *row = [NSMutableArray arrayWithCapacity:self.mapSize.width];
            [self.rows insertObject:row atIndex:y];
            for (int x=0; x<self.mapSize.width; x++) {
                NSNumber* h = [NSNumber numberWithInt:(int)([self perlinForX:x andY:y]*13.0f-3.25f-0.6)];
                [row  insertObject:h atIndex:x];
            }
            //NSLog(line);
            if (y % (MAP_H/10) == 0) {
                NSLog(@"%d percent done.", y/(MAP_H/10));
            }
        }
        NSLog(@"Completed.\n");
        //        NSLog(@"Connecting tiles...");
        //        int i = 0;
        //        for (MapTile* tile in self.allTiles) {
        //            [tile connectWithTiles:self];
        //            if (i % (MAP_H*MAP_W/10) == 0) {
        //                NSLog(@"%d percent done.", i/(MAP_H*MAP_W/100));
        //            }
        //
        //            i++;
        //        }
        //        NSLog(@"Smoothing terrain...");
        //        for (MapTile* tile in self.allTiles) {
        //            tile.texture = [tile calculateTexture];
        //        }
        //        NSLog(@"Completed.\n");
    }
    return self;
}

-(id)tileAtMapCoordinates:(CGPoint)coordinates {
    return [self tileAtMapX:coordinates.x andMapY:coordinates.y];
}

-(id)tileAtMapX:(int)x andMapY:(int)y {
    return [[self.rows objectAtIndex:y] objectAtIndex:x];
}

-(float)noiseForX:(float)x andY:(float)y {
    int n = x*y+10*x-y;
    srand(n*log(n));
    float z = (rand()%100)/100.0f;
    return z;
}

-(float)smoothNoiseForX:(float)x andY:(float)y {
    float corners = ( [self noiseForX:x-1 andY:y-1]+[self noiseForX:x+1 andY:y-1]+[self noiseForX:x-1 andY:y+1]+[self noiseForX:x+1 andY:y+1] )/4.0f;
    float sides   = ( [self noiseForX:x-1 andY:y] +[self noiseForX:x+1 andY: y]  +[self noiseForX:x andY:y-1]  +[self noiseForX:x andY:y+1] )/4.0f;
    float center  =  [self noiseForX:x andY:y];
    return 0.15f*corners + 0.35f*sides + 0.5f*center;
}

-(float)interpolateForX:(float)x andY:(float)y andTheta:(float)theta {
    float ft = theta * M_PI;
    float f = (1 - cos(ft)) * .5f;
    return  x*(1-f) + y*f;
}

-(float)interpolateNoiseForX:(float)x andY:(float)y {
    int integer_X    = round(x);
    float fractional_X = x - integer_X;
    
    int integer_Y    = round(y);
    float fractional_Y = y - integer_Y;
    
    float v1 = [self smoothNoiseForX:integer_X andY:integer_Y];
    float v2 = [self smoothNoiseForX:integer_X + 1 andY:integer_Y];
    float v3 = [self smoothNoiseForX:integer_X andY:integer_Y + 1];
    float v4 = [self smoothNoiseForX:integer_X + 1 andY:integer_Y + 1];
    
    float i1 = [self interpolateForX:v1 andY:v2 andTheta:fractional_X];
    float i2 = [self interpolateForX:v3 andY:v4 andTheta:fractional_X];
    
    return [self interpolateForX:i1 andY:i2 andTheta:fractional_Y];
}

-(float)perlinForX:(int)x andY:(int)y {
    float total = 0;
    
    for (int i=1; i<4; i++) {
        float frequency = pow(2, i);
        float amplitude = pow(0.5f, i);
        total += [self interpolateNoiseForX:(x/10.0f)*frequency andY:(y/10.0f)*frequency] * amplitude;
    }
    
    return total;
}

- (NSString*)stringForDirection:(direction)d {
    NSString* directionDescription;
    switch (d) {
        case ne:
            directionDescription = @"ne";
            break;
        case nw:
            directionDescription = @"nw";
            break;
        case w:
            directionDescription = @"w";
            break;
        case sw:
            directionDescription = @"sw";
            break;
        case se:
            directionDescription = @"se";
            break;
        case e:
            directionDescription = @"e";
            break;
        default:
            break;
    }
    return directionDescription;
}

- (BOOL)direction:(direction)a isOppositeOf:(direction)b {
    if (a == any || b == any) {
        return NO;
    }
    if (a == b) {
        return NO;
    }
    direction smaller = (a < b) ? a : b;
    direction larger = (a < b) ? b : a;
    if (smaller == nw && larger == se ) {
        return YES;
    } else if (smaller == ne && larger == sw) {
        return YES;
    } else if (smaller == e && larger == w) {
        return YES;
    }
    return NO;
}

- (direction)directionOppositeOfDirection:(direction)a {
    if (a == any) {
        return any;
    }
    if (a > se) {
        return a-3;
    } else {
        if (a == nw) {
            return ne;
        } else if (a == ne) {
            return sw;
        } else if (a == e) {
            return w;
        }
    }
    return any;
}

- (direction)directionClockwiseFromDirection:(direction)a {
    if (a == any) {
        return any;
    }
    if (a < w) {
        return a+1;
    }
    return nw;
}

- (direction)directionCounterClockwiseFromDirection:(direction)a {
    if (a==any) {
        return any;
    }
    if (a > nw) {
        return a-1;
    }
    return w;
}

- (NSArray*)directionsClockwiseFromDirection:(direction)startingDirection {
    NSMutableArray* directions = [NSMutableArray new];
    [directions addObject:[NSNumber numberWithLong:startingDirection]];
    direction next = [self directionClockwiseFromDirection:startingDirection];
    while (next != startingDirection) {
        [directions addObject:[NSNumber numberWithLong:next]];
        next = [self directionClockwiseFromDirection:next];
    }
    return directions;
}


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
    NSMutableArray* hexes = [NSMutableArray arrayWithCapacity:6];

    
    
    if (y%2==0) {
        if (y+1<MAP_H) {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(x, y+1)] atIndex:nw];
        } else {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(NO_POINT, NO_POINT)] atIndex:nw];
        }
        if (x+1<MAP_W && y+1<MAP_H) {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(x+1,y+1)] atIndex:ne];
        } else {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(NO_POINT, NO_POINT)] atIndex:ne];
        }
        if (x+1<MAP_W) {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(x+1, y)] atIndex:e];
        } else {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(NO_POINT, NO_POINT)] atIndex:e];
        }
        if (x+1<MAP_W && y>0) {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(x+1, y-1)] atIndex:se];
        } else {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(NO_POINT, NO_POINT)] atIndex:se];
        }
        if (y>0) {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(x, y-1)] atIndex:sw];
        } else {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(NO_POINT, NO_POINT)] atIndex:sw];
        }
        if (x>0) {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(x-1, y)] atIndex:w];
        } else {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(NO_POINT, NO_POINT)] atIndex:w];
        }
        
    } else {
        if (x>0 && y+1<MAP_H) {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(x-1,y+1)] atIndex:nw];
        } else {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(NO_POINT, NO_POINT)] atIndex:nw];
        }
        if (y+1<MAP_H) {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(x, y+1)] atIndex:ne];
        } else {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(NO_POINT, NO_POINT)] atIndex:ne];
        }
        if (x+1<MAP_W) {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(x+1, y)] atIndex:e];
        } else {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(NO_POINT, NO_POINT)] atIndex:e];
        }
        if (y>0) {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(x, y-1)] atIndex:se];
        } else {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(NO_POINT, NO_POINT)] atIndex:se];
        }
        if (x>0 && y>0) {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(x-1, y-1)] atIndex:sw];
        } else {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(NO_POINT, NO_POINT)] atIndex:sw];
        }
        if (x>0) {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(x-1, y)] atIndex:w];
        } else {
            [hexes insertObject:[NSValue valueWithCGPoint:CGPointMake(NO_POINT, NO_POINT)] atIndex:w];
        }
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

- (NSArray*)vectorize {
    //keep track of finished hexes
    NSMutableArray* doneRows = [NSMutableArray arrayWithCapacity:MAP_H];
    for (int y=0; y<MAP_H; y++) {
        NSMutableArray* doneRow = [NSMutableArray arrayWithCapacity:MAP_W];
        for (int x=0; x<MAP_W; x++) {
            [doneRow addObject:[NSNumber numberWithInt:0]];
        }
        [doneRows addObject:doneRow];
    }

    //track paths for each height level
    NSMutableArray* pathsForHeight = [NSMutableArray array];
    for (int i=0; i<4; i++) {
        [pathsForHeight addObject:[NSMutableArray new]];
    }
    
    CGPoint (^pointForPath)(CGPoint) = ^CGPoint(CGPoint originalPoint) {
        return CGPointMake(originalPoint.x*100, originalPoint.y*100);
    };
    
    //calculate largest path from starting point at starting height
    UIBezierPath* (^largestPath)(CGPoint,int) = ^UIBezierPath* (CGPoint startingPoint,int startingHeight){
        UIBezierPath* largest = [UIBezierPath new];
        [largest moveToPoint:pointForPath(startingPoint)];
        int nPoints = 0;
        NSMutableArray* allPoints = [NSMutableArray new]; //all points in this path
        [allPoints addObject:[NSValue valueWithCGPoint:startingPoint]];
        int allPointsCursor = 0;
        CGPoint currentPoint = startingPoint;
        direction currentDirection = any;
        direction orientationOfLine = nw;
        BOOL endPointFound = NO; //end point for this polygon
        while (!endPointFound) { //close the poly
//            NSLog(@"\n\t CURRENT POINT %.0f,%.0f", currentPoint.x, currentPoint.y);
            BOOL foundNext = NO;
            NSArray* neighbours = [self hexesBorderingHex:currentPoint];
//            NSLog(@"\n\t neighbours %@", neighbours);
            NSArray* directions = [self directionsClockwiseFromDirection:orientationOfLine]; //get directions of neighbouring hexes sorted clockwise starting with direction of the orientation of line that we're tracing the path in
            for (NSNumber* nextDir in directions) { //clockwise through neighbours
                direction d = [nextDir intValue];
                CGPoint neighbourPoint = [neighbours[d] CGPointValue];
                if (neighbourPoint.x != NO_POINT && neighbourPoint.y != NO_POINT) {
                    NSMutableArray* completedRow = doneRows[(int)neighbourPoint.y];
                    int completedHeight = [completedRow[(int)neighbourPoint.x] intValue];
//                    NSLog(@"\n\t\t looking in direction %@ at (%f, %f)\n\t\t\t completedHeight:%d, completedRow:%@", [self stringForDirection:d], neighbourPoint.x, neighbourPoint.y, completedHeight, completedRow);
                    if (completedHeight < startingHeight) {
                        int neighbourH = [[self tileAtMapCoordinates:neighbourPoint] intValue];
//                        NSLog(@"\n\t\t neighbour %f,%f at %d", neighbourPoint.x, neighbourPoint.y, neighbourH);
                        if (neighbourH >= startingHeight) { //if height matches
                            if (CGPointEqualToPoint(startingPoint, neighbourPoint)) { //if looped back to start
//                                NSLog(@"\n\t\t\t !!!Found starting point!!!");
                                [largest addLineToPoint:pointForPath(currentPoint)];
                                nPoints++;
                                [largest addLineToPoint:pointForPath(neighbourPoint)];
                                nPoints++;
                                [allPoints addObject:[NSValue valueWithCGPoint:currentPoint]];
                                [allPoints addObject:[NSValue valueWithCGPoint:neighbourPoint]];
                                allPointsCursor = ((int)allPoints.count)-1;
                                endPointFound = YES;
                                foundNext = YES;
                                break;
                            } else {
                                //mark point as done
                                int x = (int)neighbourPoint.x;
                                completedRow[x] = [NSNumber numberWithInt:startingHeight];
//                                NSLog(@"\n\t\t\t Marking tile %f,%f complete", neighbourPoint.x, neighbourPoint.y);
                                
                                if (currentDirection == d) { //moving in the right direction - keep going
//                                    NSLog(@"\n\t\t\t Keeping direction %@", [self stringForDirection:d]);
                                } else if (currentDirection == any) { //no direction asigned, use this one
                                    currentDirection = d; //assign direction
                                    orientationOfLine = [self directionCounterClockwiseFromDirection:d];
//                                    NSLog(@"\n\t\t\t New direction %@, line orientation %@", [self stringForDirection:d], [self stringForDirection:orientationOfLine]);
                                } else { //line segment ends, change direction and draw
//                                    CGPoint prevPoint = [[allPoints lastObject] CGPointValue]; //for logging only
//                                    NSLog(@"\n\t\t\t Adding line (%.0f,%.0f)->(%.0f,%.0f)", prevPoint.x, prevPoint.y, currentPoint.x, currentPoint.y);
                                    
                                    orientationOfLine = [self directionCounterClockwiseFromDirection:d];
                                    currentDirection = d; //change direction
//                                    NSLog(@"\n\t\t\t New direction %@, line orientation %@", [self stringForDirection:d], [self stringForDirection:orientationOfLine]);
                                    
                                    [largest addLineToPoint:pointForPath(currentPoint)]; //update path
                                    [allPoints addObject:[NSValue valueWithCGPoint:currentPoint]]; //keep track of point
                                    allPointsCursor = ((int)allPoints.count)-1;
                                    nPoints++;
                                }
                                foundNext = YES;
                                currentPoint = neighbourPoint; //check neighbours of this point next
//                                NSLog(@"\n\t\t\t New current point %f, %f", currentPoint.x, currentPoint.y);
                                break;
                            }
                        }
                    }
                }
            }
//            NSLog(@"\n\t ALL POINTS (%d) %@", allPointsCursor, allPoints);
            if (!foundNext) {
                CGPoint lastPoint = [allPoints[allPointsCursor] CGPointValue]; //backtrack
                if (CGPointEqualToPoint(lastPoint, currentPoint)) {
                    [largest addLineToPoint:pointForPath(currentPoint)];
                    [allPoints addObject:[NSValue valueWithCGPoint:currentPoint]];
                    nPoints++;
                    endPointFound = YES;
//                    NSLog(@"No previous point, closing");
                } else {
//                    NSLog(@"\n\t\t\t BACKTRACKING (%.0f,%.0f)->(%.0f,%.0f)", currentPoint.x, currentPoint.y, lastPoint.x, lastPoint.y);
                    [largest addLineToPoint:pointForPath(currentPoint)];
                    allPointsCursor--;
                    [allPoints addObject:[NSValue valueWithCGPoint:currentPoint]];
                    currentPoint = lastPoint;
                    currentDirection = any;
                    orientationOfLine = [self directionOppositeOfDirection:orientationOfLine];
                    nPoints++;
                }
            }
        }

            //current direction is any
            //current hex has no w and nw jobs
            //while (nextPointNotFound)
                //grabneighbouring hexes
                //filter hexes with h >= starting h
                //if current direction != any
                    //find first hex starting with nw and moving clockwise
                    //if none break and exit
                    //else
                        //current point = hex
                        //if hex is not in current direction
                            //point found
                            //current direction = any
                            //break
                        //else
                            //point not found
            

        if (nPoints == 0) {
            return nil;
        }
        NSLog(@"\n\n*************************************\n DONE FOR h=%d %@", startingHeight, allPoints);
        return largest;
    };
    
    UIBezierPath* (^nextJob)(void) = ^UIBezierPath* {
        int x =0 ;
        int y = 0;
        NSMutableArray* markAsDone = [NSMutableArray new];
        NSMutableArray* markAsDoneValues = [NSMutableArray new];
        for (NSMutableArray* doneRow in doneRows) {
            x=0;
            [markAsDone removeAllObjects];
            [markAsDoneValues removeAllObjects];
            for (NSNumber* completedH in doneRow) {
                CGPoint nextPoint = CGPointMake(x, y);
                NSNumber* h = (NSNumber*)[self tileAtMapX:x andMapY:y];
                NSMutableArray* paths = pathsForHeight[[h intValue]];
                BOOL pointContained = NO;
                for (UIBezierPath* existingPath in paths) { //check that point isn't already covered by a path of same level
                    if ([existingPath containsPoint:pointForPath(nextPoint)]) { //if existing path already covers this point
                        pointContained = YES;
                        [markAsDone addObject:[NSNumber numberWithInt:x]];
                        [markAsDoneValues addObject:[h copy]];
                        break;
                    }
                }
                if (!pointContained && [completedH intValue] < [h intValue]) {
                    UIBezierPath* path = largestPath(CGPointMake(x, y), [completedH intValue]+1);
                    [paths addObject:path];
                    return path;
                }
                x++;
            }
            int i = 0;
            for (NSNumber* doneX in markAsDone) {
                doneRow[[doneX intValue]] = markAsDoneValues[i];
                i++;
            }
            y++;
        }
        return nil;
    };
    

    
    UIBezierPath* nextPath = nextJob();
    while (nextPath) {
//        [paths addObject:nextPath];
        nextPath = nextJob();
    }
    
    return pathsForHeight;
}

- (NSString*)description {
    NSEnumerator* en = [self.rows reverseObjectEnumerator];
    NSArray* row = [en nextObject];
    NSString* desc = @"\n";
    while (row) {
        for (NSNumber* col in row) {
            desc = [NSString stringWithFormat:@"%@ %d", desc, [col intValue]];
        }
        desc = [NSString stringWithFormat:@"%@\n",desc];
        row = [en nextObject];
    }
    return desc;
}

@end
