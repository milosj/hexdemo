//
//  UIBezierPath+Interpolation.m
//  Curve Interpolation
//
//  Created by John Fisher on 4/26/14.
//  Copyright (c) 2014 John Fisher. All rights reserved.
//

#import "UIBezierPath+Interpolation.h"
#import "CGPointExtension.h"

@implementation UIBezierPath (Interpolation)

void getPointsFromBezier(void *info, const CGPathElement *element);
NSArray *pointsFromBezierPath(UIBezierPath *bpath);


+(UIBezierPath *)interpolateCGPointsWithCatmullRom:(NSArray *)pointsAsNSValues closed:(BOOL)closed alpha:(float)alpha {
    if ([pointsAsNSValues count] < 4)
        return nil;
    
    int endIndex = (closed ? [pointsAsNSValues count] : [pointsAsNSValues count]-2);
    NSAssert(alpha >= 0.0 && alpha <= 1.0, @"alpha value is between 0.0 and 1.0, inclusive");

    UIBezierPath *path = [UIBezierPath bezierPath];
    int startIndex = (closed ? 0 : 1);
    for (int ii=startIndex; ii < endIndex; ++ii) {
        CGPoint p0, p1, p2, p3;
        int nextii      = (ii+1)%[pointsAsNSValues count];
        int nextnextii  = (nextii+1)%[pointsAsNSValues count];
        int previi      = (ii-1 < 0 ? [pointsAsNSValues count]-1 : ii-1);
        
        [pointsAsNSValues[ii] getValue:&p1];
        [pointsAsNSValues[previi] getValue:&p0];
        [pointsAsNSValues[nextii] getValue:&p2];
        [pointsAsNSValues[nextnextii] getValue:&p3];
        
        float d1 = ccpLength(ccpSub(p1, p0));
        float d2 = ccpLength(ccpSub(p2, p1));
        float d3 = ccpLength(ccpSub(p3, p2));
        
        CGPoint b1, b2;
        b1 = ccpMult(p2, powf(d1, 2*alpha));
        b1 = ccpSub(b1, ccpMult(p0, powf(d2, 2*alpha)));
        b1 = ccpAdd(b1, ccpMult(p1,(2*powf(d1, 2*alpha) + 3*powf(d1, alpha)*powf(d2, alpha) + powf(d2, 2*alpha))));
        b1 = ccpMult(b1, 1.0 / (3*powf(d1, alpha)*(powf(d1, alpha)+powf(d2, alpha))));
        
        b2 = ccpMult(p1, powf(d3, 2*alpha));
        b2 = ccpSub(b2, ccpMult(p3, powf(d2, 2*alpha)));
        b2 = ccpAdd(b2, ccpMult(p2,(2*powf(d3, 2*alpha) + 3*powf(d3, alpha)*powf(d2, alpha) + powf(d2, 2*alpha))));
        b2 = ccpMult(b2, 1.0 / (3*powf(d3, alpha)*(powf(d3, alpha)+powf(d2, alpha))));
        
        if (ii==startIndex)
            [path moveToPoint:p1];
        
        [path addCurveToPoint:p2 controlPoint1:b1 controlPoint2:b2];
    }
    
    if (closed)
        [path closePath];
    
    return path;
}

+(UIBezierPath *)interpolateCGPointsWithHermite:(NSArray *)pointsAsNSValues closed:(BOOL)closed {
    if ([pointsAsNSValues count] < 2)
        return nil;

    int nCurves = (closed ? [pointsAsNSValues count] : [pointsAsNSValues count]-1);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int ii=0; ii < nCurves; ++ii) {
        NSValue *value  = pointsAsNSValues[ii];
        
        CGPoint curPt, prevPt, nextPt, endPt;
        [value getValue:&curPt];
        if (ii==0)
            [path moveToPoint:curPt];
        
        int nextii = (ii+1)%[pointsAsNSValues count];
        int previi = (ii-1 < 0 ? [pointsAsNSValues count]-1 : ii-1);
        
        [pointsAsNSValues[previi] getValue:&prevPt];
        [pointsAsNSValues[nextii] getValue:&nextPt];
        endPt = nextPt;
        
        float mx, my;
        if (closed || ii > 0) {
            mx = (nextPt.x - curPt.x)*0.5 + (curPt.x - prevPt.x)*0.5;
            my = (nextPt.y - curPt.y)*0.5 + (curPt.y - prevPt.y)*0.5;
        }
        else {
            mx = (nextPt.x - curPt.x)*0.5;
            my = (nextPt.y - curPt.y)*0.5;
        }
        
        CGPoint ctrlPt1;
        ctrlPt1.x = curPt.x + mx / 3.0;
        ctrlPt1.y = curPt.y + my / 3.0;
        
        [pointsAsNSValues[nextii] getValue:&curPt];
        
        nextii = (nextii+1)%[pointsAsNSValues count];
        previi = ii;
        
        [pointsAsNSValues[previi] getValue:&prevPt];
        [pointsAsNSValues[nextii] getValue:&nextPt];
        
        if (closed || ii < nCurves-1) {
            mx = (nextPt.x - curPt.x)*0.5 + (curPt.x - prevPt.x)*0.5;
            my = (nextPt.y - curPt.y)*0.5 + (curPt.y - prevPt.y)*0.5;
        }
        else {
            mx = (curPt.x - prevPt.x)*0.5;
            my = (curPt.y - prevPt.y)*0.5;
        }
        
        CGPoint ctrlPt2;
        ctrlPt2.x = curPt.x - mx / 3.0;
        ctrlPt2.y = curPt.y - my / 3.0;
        
        [path addCurveToPoint:endPt controlPoint1:ctrlPt1 controlPoint2:ctrlPt2];
    }
    
    if (closed)
        [path closePath];
    
    return path;
}


void getPointsFromBezier(void *info, const CGPathElement *element);
NSArray *pointsFromBezierPath(UIBezierPath *bpath);


#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]
#define POINT(_INDEX_) [(NSValue *)[points objectAtIndex:_INDEX_] CGPointValue]


// Get points from Bezier Curve
void getPointsFromBezier(void *info, const CGPathElement *element)
{
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;
    
    // Retrieve the path element type and its points
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    
    // Add the points if they're available (per type)
    if (type != kCGPathElementCloseSubpath)
    {
        [bezierPoints addObject:VALUE(0)];
        if ((type != kCGPathElementAddLineToPoint) &&
            (type != kCGPathElementMoveToPoint))
            [bezierPoints addObject:VALUE(1)];
    }
    if (type == kCGPathElementAddCurveToPoint)
        [bezierPoints addObject:VALUE(2)];
}

NSArray *pointsFromBezierPath(UIBezierPath *bpath)
{
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(bpath.CGPath, (__bridge void *)points, getPointsFromBezier);
    return points;
}

- (UIBezierPath*)smoothedPathWithGranularity:(NSInteger)granularity;
{
    NSMutableArray *points = [pointsFromBezierPath(self) mutableCopy];
    
    if (points.count < 4) return [self copy];
    
    // Add control points to make the math make sense
    [points insertObject:[points objectAtIndex:0] atIndex:0];
    [points addObject:[points lastObject]];
    
    UIBezierPath *smoothedPath = [self copy];
    [smoothedPath removeAllPoints];
    
    [smoothedPath moveToPoint:POINT(0)];
    
    for (NSUInteger index = 1; index < points.count - 2; index++)
    {
        CGPoint p0 = POINT(index - 1);
        CGPoint p1 = POINT(index);
        CGPoint p2 = POINT(index + 1);
        CGPoint p3 = POINT(index + 2);
        
        // now add n points starting at p1 + dx/dy up until p2 using Catmull-Rom splines
        for (int i = 1; i < granularity; i++)
        {
            float t = (float) i * (1.0f / (float) granularity);
            float tt = t * t;
            float ttt = tt * t;
            
            CGPoint pi; // intermediate point
            pi.x = 0.5 * (2*p1.x+(p2.x-p0.x)*t + (2*p0.x-5*p1.x+4*p2.x-p3.x)*tt + (3*p1.x-p0.x-3*p2.x+p3.x)*ttt);
            pi.y = 0.5 * (2*p1.y+(p2.y-p0.y)*t + (2*p0.y-5*p1.y+4*p2.y-p3.y)*tt + (3*p1.y-p0.y-3*p2.y+p3.y)*ttt);
            [smoothedPath addLineToPoint:pi];
        }
        
        // Now add p2
        [smoothedPath addLineToPoint:p2];
    }
    
    // finish by adding the last point
    [smoothedPath addLineToPoint:POINT(points.count - 1)];
    
    return smoothedPath;
}

@end
