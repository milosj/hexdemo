//
//  ArrowNode.m
//  spritedemo1
//
//  Created by Milos Jovanovic on 2015-04-03.
//  Copyright (c) 2015 ca.cbc. All rights reserved.
//

#import "ArrowNode.h"



@implementation ArrowNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.strokeColor = [UIColor whiteColor];
        self.fillColor = [UIColor redColor];
        self.lineWidth = 3;
        self.thickness = 20.0f;
        self.arrowheadScale = 1.25f;
        self.minThicknessScale = 0.25;
    }
    return self;
}


- (void)setArrowPath:(NSArray *)path {
    
    UIBezierPath* forwardPath = [UIBezierPath new];
    UIBezierPath* backwardPath = [UIBezierPath new];
    
    CGPoint lastPoint = CGPointZero;
    CGPoint lastPPoint = CGPointZero;
    CGPoint lastNPoint = CGPointZero;
    CGPoint firstPoint = CGPointZero;
    CGFloat lastGradient = 0;
    
    CGPoint arrownpoint = CGPointZero;
    CGPoint arrowppoint = CGPointZero;
    CGPoint arrowfpoint = CGPointZero;
    int i=0;
    
    CGFloat thicknessGrowth = (self.thickness-self.minThicknessScale*self.thickness)/path.count;
    CGFloat currentThickness = self.thickness-(path.count-1)*thicknessGrowth;

    for (NSValue* hex in path) {
        CGPoint adjposition = [hex CGPointValue];
        if (hex == [path lastObject]) {
            adjposition = [hex CGPointValue];
        }
        
        if (!CGPointEqualToPoint(lastPoint, CGPointZero)) {
            CGFloat deltaX = (adjposition.x-lastPoint.x);
            if (deltaX == 0) { //watch out for that Inf
                deltaX = 0.0001;
            }
            CGFloat gradient =(adjposition.y-lastPoint.y)/deltaX;
            CGFloat gradientsq = powf(gradient, 2);
            CGFloat ymodifier = currentThickness/sqrtf(1+gradientsq);
            CGFloat xmodifier = gradient*currentThickness/sqrtf(1+gradientsq);
            CGPoint ppoint = CGPointZero;
            CGPoint npoint = CGPointZero;
            if (lastPoint.x <= adjposition.x) {
                ppoint = CGPointMake(adjposition.x + xmodifier, adjposition.y - ymodifier);
                npoint = CGPointMake(adjposition.x - xmodifier, adjposition.y + ymodifier);
            } else {
                ppoint = CGPointMake(adjposition.x - xmodifier, adjposition.y + ymodifier);
                npoint = CGPointMake(adjposition.x + xmodifier, adjposition.y - ymodifier);
            }
            
            //calculate extra point on the elbow and quad curve control point
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
                        if (lastPoint.x <= adjposition.x) {
                            extraPoint = CGPointMake(basepoint.x + xmodifiere, basepoint.y - ymodifiere);
                        } else {
                            extraPoint = CGPointMake(basepoint.x - xmodifiere, basepoint.y + ymodifiere);
                        }
                    } else {
                        if (lastPoint.x <= adjposition.x) {
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
                        gradient+=0.0000001;
                    }
                    controlPoint = CGPointMake((lastGradient*prevPoint.x-gradient*nextPoint.x+nextPoint.y-prevPoint.y)/(lastGradient-gradient), (lastGradient*(gradient*nextPoint.x-nextPoint.y)-gradient*(lastGradient*prevPoint.x-prevPoint.y))/(gradient-lastGradient));

                    elbowPoint = extraPoint;
                }
            }

            //add arrow

            if (hex == [path lastObject]) {
                CGFloat ymodifier2 = self.arrowheadScale*self.thickness/sqrtf(1+gradientsq);
                CGFloat xmodifier2 = gradient*self.arrowheadScale*self.thickness/sqrtf(1+gradientsq);
                if (lastPoint.x <= adjposition.x) {
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
            
            //draw curve
            if (isCurve) {
                if (controlPointIsForward) {
                    [forwardPath addQuadCurveToPoint:elbowPoint controlPoint:controlPoint];
//                    [forwardPath addLineToPoint:controlPoint]; //add straight line instead for testing
//                    [forwardPath addLineToPoint:elbowPoint];
                    [forwardPath addLineToPoint:ppoint];
                    [backwardPath addLineToPoint:npoint];
                } else {
                    [forwardPath addLineToPoint:ppoint];
//                    [backwardPath addLineToPoint:controlPoint];//add straight line instead for testing
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
    
    [forwardPath appendPath:backwardPath];

    self.path = [forwardPath CGPath];
}
@end
