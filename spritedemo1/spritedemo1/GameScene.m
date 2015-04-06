//
//  GameScene.m
//  spritedemo1
//
//  Created by Milos Jovanovic on 2015-04-02.
//  Copyright (c) 2015 ca.cbc. All rights reserved.
//

#import "GameScene.h"
#import "HexNode.h"
#import "Map.h"
#import "UIBezierPath+Interpolation.h"
#import "ArrowNode.h"


@import CoreGraphics;

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    
    self.rootNode = [SKNode node];
    self.rootNode.position = CGPointMake(0, 0);
    [self addChild:self.rootNode];

//    SKLabelNode* label = [SKLabelNode labelNodeWithText:@"test"];
//    label.fontColor = [SKColor whiteColor];
//    label.fontSize = 25;
//    label.fontName = @"HelveticaNeue";
//    label.position = CGPointMake(CGRectGetMidX(self.frame),
//                                 1.85*CGRectGetMidY(self.frame));
//    [self.rootNode addChild:label];
    UILabel* newLabel = [UILabel new];
    newLabel.frame = CGRectMake(10, 0, self.frame.size.width, 100);
    newLabel.numberOfLines = 0;
    newLabel.text = @"test";
    newLabel.textColor = [UIColor whiteColor];
    newLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:newLabel];
    
    
    self.arrow = [ArrowNode node];
    self.arrow.position = self.rootNode.position;
    self.arrow.label = newLabel;
    
    [self addChild:self.arrow];
    
//    for (int x = 0; x < 20; x++) {
//        for (int y = 0; y < 20; y++) {
    int x = 6;
    int y = 6;
            HexNode* hex = [HexNode new];
            hex.name = @"HEX";
            hex.position = [GameScene coordinatesForGamePositionX:x andY:y];
    hex.gamePosition = CGPointMake(x, y);
            if (y % 2 == 0) {
                hex.hexShapeNode.fillColor = [SKColor redColor];
            }
            [self.rootNode addChild:hex];
            
//        }
//    }
    self.selectedNode = hex;
    self.map = [Map new];
    
    self.selectionHex = [HexNode new];
    self.selectionHex.hexShapeNode.fillColor = [SKColor clearColor];
    self.selectionHex.hexShapeNode.strokeColor = [SKColor redColor];
    self.selectionHex.hidden = YES;
    [self.rootNode addChild:self.selectionHex];
}

+ (CGPoint)hexCenterCoordinateForGamePosition:(CGPoint)position {
    CGPoint wpos = [self coordinatesForGamePosition:position];
    return CGPointMake(wpos.x+HEX_W/2, wpos.y+0.75*HEX_H/2);
}

+ (CGPoint)coordinatesForGamePosition:(CGPoint)position {
    return [self coordinatesForGamePositionX:(int)position.x andY:(int)position.y];
}

+ (CGPoint)coordinatesForGamePositionX:(int)x andY:(int)y {
    if ((y % 2) == 0) {
        return CGPointMake(x*HEX_W, 0.75*y*HEX_H);
    } else {
        return CGPointMake((x-0.5f)*HEX_W, 0.75*y*HEX_H);
    }
}

+ (CGPoint)gamePositionForCoordinates:(CGPoint)coordinates {
    CGPoint pos1 = CGPointMake((int)(coordinates.x/HEX_W), (int)(coordinates.y/(0.75*HEX_H)));
    if (((int)pos1.y) % 2 == 0) {
        return pos1;
    } else {
        return CGPointMake((int)((coordinates.x+HEX_W/2)/HEX_W), pos1.y);
    }

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    SKNode* node = [self.rootNode nodeAtPoint:location];
    if (node && node != self.rootNode) {
        if (![node isKindOfClass:[HexNode class]]) {
            node = [node parent];
        }
//        self.selectedNode = node;
    }
    self.target = location;
//        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
//        
//        [sprite runAction:[SKAction repeatActionForever:action]];
//        
//        [self addChild:sprite];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.selectedNode) {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInNode:self];
        
        self.target = location;
//        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        self.arrow.position = CGPointMake(0, 0);

//        CGRect frame = [self.selectedNode calculateAccumulatedFrame];

        CGPoint gpos = [GameScene gamePositionForCoordinates:location];
        NSArray* path = [self.map pathFromHex:self.selectedNode.gamePosition toHex:gpos];
        if (path.count > 1) {
            NSMutableArray* wpath = [NSMutableArray new];
            for (NSValue* gamepoint in path) {
                CGPoint worldpoint = [GameScene hexCenterCoordinateForGamePosition:[gamepoint CGPointValue]];
                [wpath addObject:[NSValue valueWithCGPoint:worldpoint]];
            }
            [self.arrow setArrowPath:wpath];
            
        }
        
//        if (path.count > 1) {
//            NSMutableArray* npath = [path mutableCopy];
//            [npath removeLastObject];
//            [npath addObject:[NSValue valueWithCGPoint:location]];
//            [self.arrow setArrowPath:npath];
//        }

        
        //        self.arrow.path = [[UIBezierPath interpolateCGPointsWithCatmullRom:points closed:NO alpha:0.73f] CGPath];
        
        CGPoint wpos = [GameScene coordinatesForGamePositionX:gpos.x andY:gpos.y];

        //self.arrow.path = [bezierPath CGPath];
        
//        if ([self.map hex:gpos isAdjacentToHex:self.selectedNode.gamePosition]) {
            self.selectionHex.position = wpos;
//        }

        self.selectionHex.hidden = NO;

    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    if ([self.rootNode nodeAtPoint:location] == self.selectedNode) {
        
    }

    

//    self.arrow.path = NULL;
//    self.selectedNode = nil;
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
