//
//  TerrainShapeNode.m
//  spritedemo1
//
//  Created by Milos Jovanovic on 2015-04-06.
//  Copyright (c) 2015 ca.cbc. All rights reserved.
//

#import "TerrainShapeNode.h"

@interface TerrainShapeNode()

@property (strong, nonatomic) SKCropNode* cropNode;

@end

@implementation TerrainShapeNode

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.cropNode = [SKCropNode new];
        self.cropNode.name = @"cropNode";
        [self addChild:self.cropNode];
    }
    
    return self;
}

- (void)setupInView:(SKView*)view {
    self.cropNode.zPosition = self.zPosition;
    
    SKShapeNode* terrainShape = [SKShapeNode new];
    terrainShape.fillColor = [UIColor blackColor];
    terrainShape.strokeColor = [UIColor clearColor];
    
//    UIBezierPath* testpath = [UIBezierPath new];
//    [testpath moveToPoint:CGPointMake(400, 700)];
//    [testpath addLineToPoint:CGPointMake(500, 600)];
//    [testpath addLineToPoint:CGPointMake(600, 500)];
//    [testpath addLineToPoint:CGPointMake(550, 300)];
//    [testpath addLineToPoint:CGPointMake(500, 400)];
//    [testpath addLineToPoint:CGPointMake(250, 350)];
//    [testpath addLineToPoint:CGPointMake(150, 200)];
//    [testpath addLineToPoint:CGPointMake(200, 400)];
//    [testpath addLineToPoint:CGPointMake(300, 600)];
//    [testpath closePath];
//    terrainShape.path = [testpath CGPath];
    
    SKTexture* mask = [view textureFromNode:terrainShape];
    
    SKSpriteNode* maskNode = [[SKSpriteNode alloc] initWithTexture:mask];
    maskNode.name = @"maskNode";
    self.cropNode.maskNode = maskNode;
    
    SKSpriteNode* texture = [[SKSpriteNode alloc] initWithImageNamed:@"paper1"];
    texture.name = @"texture";
    texture.zPosition = self.zPosition;
    [self.cropNode addChild:texture];
    
    SKShapeNode* shadow = terrainShape;
    shadow.name = @"shadow";
    shadow.zPosition = self.zPosition-1.0f;
    shadow.alpha = 0.2f;
    shadow.position = CGPointMake(maskNode.frame.origin.x+10,maskNode.frame.origin.y-10);
    [self addChild:shadow];

    SKShapeNode* outline = [SKShapeNode new];
    outline.name = @"outline";
    outline.fillColor = [SKColor clearColor];
    outline.strokeColor = [SKColor whiteColor];
    outline.path = [self.path CGPath];
    outline.position = CGPointMake(maskNode.frame.origin.x,maskNode.frame.origin.y);
    outline.zPosition = self.zPosition;
    [self addChild:outline];
}

@end
