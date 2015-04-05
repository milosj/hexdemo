//
//  ArrowNode.m
//  spritedemo1
//
//  Created by Milos Jovanovic on 2015-04-03.
//  Copyright (c) 2015 ca.cbc. All rights reserved.
//

#import "ArrowNode.h"
#import "GameScene.h"
#import "HexNode.h"
#import "UIBezierPath+Interpolation.h"
#import "CGPointExtension.h"



@implementation ArrowNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.strokeColor = [UIColor whiteColor];
        self.fillColor = [UIColor redColor];
        self.lineWidth = 3;
        self.thickness = 10.0f;
        self.arrowheadScale = 2.5f;
    }
    return self;
}


- (void)setArrowPath:(NSArray *)path {
    NSMutableArray* points = [NSMutableArray new];
    
    NSMutableArray* forwardPoints = [NSMutableArray new];
    NSMutableArray* backwardPoints = [NSMutableArray new];
    
    CGPoint lastPoint = CGPointZero;
    CGPoint lastPPoint = CGPointZero;
    CGPoint lastNPoint = CGPointZero;
    CGPoint firstPoint = CGPointZero;
    
    CGPoint arrownpoint = CGPointZero;
    CGPoint arrowppoint = CGPointZero;
    CGPoint arrowfpoint = CGPointZero;
    int i=0;

    for (NSValue* hex in path) {
        CGPoint wposition = [GameScene coordinatesForGamePositionX:[hex CGPointValue].x andY:[hex CGPointValue].y];
        CGPoint adjposition = CGPointMake(wposition.x + HEX_W/2, wposition.y+0.75*HEX_H/2);
        if (hex == [path lastObject]) {
            adjposition = [hex CGPointValue];
        }
        
        if (!CGPointEqualToPoint(lastPoint, CGPointZero)) {
            CGFloat deltaX = (adjposition.x-lastPoint.x);
            if (deltaX == 0) { //watch out for that Inf
                deltaX = 0.000000000001;
            }
            CGFloat gradient =(adjposition.y-lastPoint.y)/deltaX;

            CGFloat gradientsq = powf(gradient, 2);
            CGFloat ymodifier = self.thickness/sqrtf(1+gradientsq);
            CGFloat xmodifier = gradient*self.thickness/sqrtf(1+gradientsq);
            CGPoint ppoint = CGPointZero;
            CGPoint npoint = CGPointZero;
            if (lastPoint.x < adjposition.x) {
                ppoint = CGPointMake(adjposition.x + xmodifier, adjposition.y - ymodifier);
                npoint = CGPointMake(adjposition.x - xmodifier, adjposition.y + ymodifier);
            } else {
                ppoint = CGPointMake(adjposition.x - xmodifier, adjposition.y + ymodifier);
                npoint = CGPointMake(adjposition.x + xmodifier, adjposition.y - ymodifier);
            }
            
            //calculate extra point on the elbow
            if (!CGPointEqualToPoint(lastPoint, CGPointZero) && !CGPointEqualToPoint(lastPPoint, CGPointZero)) {
                CGPoint basepoint;
                BOOL hasExtraPoint = YES;
                BOOL extraIsPPoint = NO;
                
                CGFloat ppdiff = sqrtf(powf(ppoint.x-lastPPoint.x,2)+powf(ppoint.y-lastPPoint.y, 2));
                CGFloat npdiff = sqrtf(powf(npoint.x-lastNPoint.x,2)+powf(npoint.y-lastNPoint.y, 2));
                self.label.text = [NSString stringWithFormat:@"p=%.2f, n=%.2f",ppdiff,npdiff];
                if (ppdiff > npdiff) {
                    basepoint = lastNPoint;
                    extraIsPPoint = YES;
                } else if (npdiff > ppdiff) {
                    basepoint = lastPPoint;
                } else {
                    hasExtraPoint = NO;
                }
                if (hasExtraPoint) {
                    CGPoint extraPoint;
                    CGFloat ymodifiere = 2*self.thickness/sqrtf(1+gradientsq);
                    CGFloat xmodifiere = 2*gradient*self.thickness/sqrtf(1+gradientsq);

                    if (CGPointEqualToPoint( basepoint, lastNPoint)) {
                        if (lastPoint.x < adjposition.x) {
                            extraPoint = CGPointMake(basepoint.x + xmodifiere, basepoint.y - ymodifiere);
                        } else {
                            extraPoint = CGPointMake(basepoint.x - xmodifiere, basepoint.y + ymodifiere);
                        }
                    } else {
                        if (lastPoint.x < adjposition.x) {
                            extraPoint = CGPointMake(basepoint.x - xmodifiere, basepoint.y + ymodifiere);
                        } else {
                            extraPoint = CGPointMake(basepoint.x + xmodifiere, basepoint.y - ymodifiere);
                        }
                        
                    }
                    //disabled - wip
                    
//                    if (extraIsPPoint) {
//                        [forwardPoints addObject:[NSValue valueWithCGPoint:extraPoint]];
//                    } else {
//                        [backwardPoints addObject:[NSValue valueWithCGPoint:extraPoint]];
//                    }
                }
            }

            self.label.text = [NSString stringWithFormat:@"m=%.3f\np0=(%.1f,%.1f),p1=(%.1f,%.1f)\n%@",gradient, lastPoint.x,lastPoint.y,adjposition.x,adjposition.y, self.label.text];

            
            //add arrow

            if (hex == [path lastObject]) {
                CGFloat ymodifier2 = self.arrowheadScale*self.thickness/sqrtf(1+gradientsq);
                CGFloat xmodifier2 = gradient*self.arrowheadScale*self.thickness/sqrtf(1+gradientsq);

                if (lastPoint.x < adjposition.x) {
                    arrowfpoint = CGPointMake(adjposition.x + ymodifier2, adjposition.y + xmodifier2);
                    arrowppoint = CGPointMake(adjposition.x + xmodifier2, adjposition.y - ymodifier2);
                    arrownpoint = CGPointMake(adjposition.x - xmodifier2, adjposition.y + ymodifier2);
                } else {
                    arrowfpoint = CGPointMake(adjposition.x - ymodifier2, adjposition.y - xmodifier2);
                    arrowppoint = CGPointMake(adjposition.x - xmodifier2, adjposition.y + ymodifier2);
                    arrownpoint = CGPointMake(adjposition.x + xmodifier2, adjposition.y - ymodifier2);
                }
                

            }
            
            lastPPoint = ppoint;
            lastNPoint = npoint;
            [forwardPoints addObject:[NSValue valueWithCGPoint:ppoint]];
            [backwardPoints addObject:[NSValue valueWithCGPoint:npoint]];
        } else {
            firstPoint = adjposition;
        }
        
        lastPoint = adjposition;
        i++;
    }


    NSEnumerator* renum = backwardPoints.reverseObjectEnumerator;
    NSValue* next = [renum nextObject];
    while (next) {
        [points addObject:next];
        next = [renum nextObject];
    }
    [points addObject:[NSValue valueWithCGPoint:firstPoint]];
    for (NSValue* point in forwardPoints) {
        [points addObject:point];
    }
    UIBezierPath* stem = [UIBezierPath interpolateCGPointsWithHermite:points closed:NO];

//    UIBezierPath* stem = [UIBezierPath bezierPath];
//    for (NSValue* point in points) {
//        if ([point isEqual:points.firstObject]) {
//            [stem moveToPoint:[point CGPointValue]];
//        } else {
//            [stem addLineToPoint:[point CGPointValue]];
//        }
//    }
//    stem = [stem smoothedPathWithGranularity:2];
    
    [stem addLineToPoint:arrowppoint];
    [stem addLineToPoint:arrowfpoint];
    [stem addLineToPoint:arrownpoint];

    [stem closePath];

    self.path = [stem CGPath];
    
}
@end
