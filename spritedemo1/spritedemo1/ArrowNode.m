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
        self.thickness = 20.0f;
        self.arrowheadScale = 1.75f;
        self.minThicknessScale = 0.5;
    }
    return self;
}


- (void)setArrowPath:(NSArray *)path {
    
    UIBezierPath* forwardPath = [UIBezierPath new];
    UIBezierPath* backwardPath = [UIBezierPath new];
    
    NSMutableArray* points = [NSMutableArray new];
    
    NSMutableArray* forwardPoints = [NSMutableArray new];
    NSMutableArray* backwardPoints = [NSMutableArray new];
    
    CGPoint lastPoint = CGPointZero;
    CGPoint lastPPoint = CGPointZero;
    CGPoint lastNPoint = CGPointZero;
    CGPoint firstPoint = CGPointZero;
    CGFloat lastGradient = 0;
    
    CGPoint arrownpoint = CGPointZero;
    CGPoint arrowppoint = CGPointZero;
    CGPoint arrowfpoint = CGPointZero;
    int i=0;
    
    CGFloat currentThickness = self.minThicknessScale*self.thickness;
    CGFloat thicknessGrowth = (self.thickness-currentThickness)/path.count;

    for (NSValue* hex in path) {
        CGPoint adjposition = [hex CGPointValue];
        if (hex == [path lastObject]) {
            adjposition = [hex CGPointValue];
        }
        [points addObject:[NSValue valueWithCGPoint:adjposition]];
        
        if (!CGPointEqualToPoint(lastPoint, CGPointZero)) {
            CGFloat deltaX = (adjposition.x-lastPoint.x);
            if (deltaX == 0) { //watch out for that Inf
                deltaX = 0.000000000001;
            }
            CGFloat gradient =(adjposition.y-lastPoint.y)/deltaX;

            CGFloat gradientsq = powf(gradient, 2);
            CGFloat ymodifier = currentThickness/sqrtf(1+gradientsq);
            CGFloat xmodifier = gradient*currentThickness/sqrtf(1+gradientsq);
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
            BOOL isCurve = NO;
            BOOL controlPointIsForward = NO;
            CGPoint controlPoint = CGPointZero;
            CGPoint elbowPoint = CGPointZero;
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
                    controlPointIsForward = YES;
                } else if (npdiff > ppdiff) {
                    basepoint = lastPPoint;
                } else {
                    hasExtraPoint = NO;
                }
                if (hasExtraPoint) {
                    isCurve = YES;
                    CGPoint extraPoint;
                    CGFloat ymodifiere = 2*(currentThickness-thicknessGrowth)/sqrtf(1+gradientsq);
                    CGFloat xmodifiere = 2*gradient*(currentThickness-thicknessGrowth)/sqrtf(1+gradientsq);

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

                    CGPoint prevPoint;
                    CGPoint nextPoint;
                    if (controlPointIsForward) {
                        prevPoint = lastPPoint;
                    } else {
                        prevPoint = lastNPoint;
                    }
                    nextPoint = extraPoint;
                    
                    if (lastGradient == gradient) {
                        gradient+=0.000000000001;
                    }
                    controlPoint = CGPointMake((lastGradient*prevPoint.x-gradient*nextPoint.x+nextPoint.y-prevPoint.y)/(lastGradient-gradient), (lastGradient*(gradient*nextPoint.x-nextPoint.y)-gradient*(lastGradient*prevPoint.x-prevPoint.y))/(gradient-lastGradient));
                    elbowPoint = extraPoint;
                    if (extraIsPPoint) {
                        [forwardPoints addObject:[NSValue valueWithCGPoint:extraPoint]];
                    } else {
                        [backwardPoints addObject:[NSValue valueWithCGPoint:extraPoint]];
                    }
                }
            }

            self.label.text = [NSString stringWithFormat:@"m=%.3f\np0=(%.1f,%.1f),p1=(%.1f,%.1f)\n%@",gradient, lastPoint.x,lastPoint.y,adjposition.x,adjposition.y, self.label.text];

            
            //add arrow

            if (hex == [path lastObject]) {
                CGFloat ymodifier2 = self.arrowheadScale*self.thickness/sqrtf(1+gradientsq);
                CGFloat xmodifier2 = gradient*self.arrowheadScale*self.thickness/sqrtf(1+gradientsq);
                self.label.text = [NSString stringWithFormat:@"%@\n(%.2f,%.2f)", self.label.text, controlPoint.x, controlPoint.y];
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
            lastGradient = gradient;
            lastPPoint = ppoint;
            lastNPoint = npoint;
            currentThickness += thicknessGrowth;
            
            [forwardPoints addObject:[NSValue valueWithCGPoint:ppoint]];
            [backwardPoints addObject:[NSValue valueWithCGPoint:npoint]];
            
            if (isCurve) {
                if (controlPointIsForward) {
                    [forwardPath addQuadCurveToPoint:elbowPoint controlPoint:controlPoint];
//                    [forwardPath addLineToPoint:controlPoint];
//                    [forwardPath addLineToPoint:elbowPoint];
                    [forwardPath addLineToPoint:ppoint];
                    [backwardPath addLineToPoint:npoint];
                } else {
                    [forwardPath addLineToPoint:ppoint];
//                    [backwardPath addLineToPoint:controlPoint];
//                    [backwardPath addLineToPoint:elbowPoint];
                    [backwardPath addQuadCurveToPoint:elbowPoint controlPoint:controlPoint];
                    [backwardPath addLineToPoint:npoint];
                }
            } else {
                [forwardPath addLineToPoint:ppoint];
                [backwardPath addLineToPoint:npoint];
            }
            
        } else {
            firstPoint = adjposition;
            [forwardPath moveToPoint:firstPoint];
            [backwardPath moveToPoint:firstPoint];
        }
        
        lastPoint = adjposition;
        i++;
    }
    [forwardPath addLineToPoint:arrowppoint];
    [forwardPath addLineToPoint:arrowfpoint];
    [forwardPath addLineToPoint:arrownpoint];
    [backwardPath addLineToPoint:arrownpoint];
    
//    NSEnumerator* renum = points.reverseObjectEnumerator;
//    NSValue* next = [renum nextObject];
//    while (next) {
//        [forwardPath addLineToPoint:[next CGPointValue]];
//        [backwardPath addLineToPoint:[next CGPointValue]];
//        next = [renum nextObject];
//    }
//    [forwardPath closePath];
//    [backwardPath closePath];
//    UIBezierPath* bp = [backwardPath bezierPathByReversingPath];
    [forwardPath appendPath:backwardPath];
//    [forwardPath closePath];
    
//    NSEnumerator* renum = backwardPoints.reverseObjectEnumerator;
//    NSValue* next = [renum nextObject];
//    while (next) {
//        [points addObject:next];
//        next = [renum nextObject];
//    }
//    [points addObject:[NSValue valueWithCGPoint:firstPoint]];
//    for (NSValue* point in forwardPoints) {
//        [points addObject:point];
//    }
//    UIBezierPath* stem = [UIBezierPath interpolateCGPointsWithHermite:points closed:NO];
//    UIBezierPath* stem = [UIBezierPath interpolateCGPointsWithCatmullRom:points closed:NO alpha:0.5];
//    UIBezierPath* stem = [UIBezierPath bezierPath];
//    for (NSValue* point in points) {
//        if ([point isEqual:points.firstObject]) {
//            [stem moveToPoint:[point CGPointValue]];
//        } else {
//            [stem addLineToPoint:[point CGPointValue]];
//        }
//    }
//    stem = [stem smoothedPathWithGranularity:2];
    
//    [stem addLineToPoint:arrowppoint];
//    [stem addLineToPoint:arrowfpoint];
//    [stem addLineToPoint:arrownpoint];

//    [stem closePath];

//    self.path = [stem CGPath];
//    [forwardPath closePath];
    
    self.path = [forwardPath CGPath];
}
@end
