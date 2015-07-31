//
//  TreeGenerator.m
//  SimWorld
//
//  Created by Michael Rommel on 16.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeGenerator.h"

#import "XMLReader.h"
#import "NSDictionary+Extensions.h"
#import "Production.h"
#import "TreeCrayonInstruction.h"
#import "TreeCrayon.h"
#import "TreeBone.h"
#import "TreeSkeleton.h"
#import "TreeCompositeConstraints.h"

@interface ProductionNodePair : NSObject

@property (nonatomic, retain) Production *production;
@property (nonatomic, retain) NSDictionary *node;

- (id)initWithProduction:(Production *)production andNode:(NSDictionary *)node;

@end

@implementation ProductionNodePair

- (id)initWithProduction:(Production *)production andNode:(NSDictionary *)node
{
    self = [super init];
    
    if (self) {
        self.production = production;
        self.node = node;
    }
    
    return self;
}

@end

@interface TreeGenerator()

TreeCompositeConstraints *_constraints;

@end

@implementation TreeGenerator

- (id)initFromTreeFile:(NSString *)ltreeFilename
{
    self = [super init];
    
    if (self) {
        NSString *rootName = nil;
        int levels = -1;
        int boneLevels = 3;
        //MultiMap<string, ProductionNodePair> productions = new MultiMap<string, ProductionNodePair>();
        NSMutableDictionary *productions = [[NSMutableDictionary alloc] init];
        
        NSData *myData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:ltreeFilename
                                                                                         ofType:@"ltree"]];
        NSError* error = nil;
        NSDictionary *root = [XMLReader dictionaryForXMLData:myData error:&error];
        
        if (!error) {
            NSDictionary *tree = [root valueForKey:@"Tree"];
            NSLog(@"Nodes: %lu", (unsigned long)tree.count);
        
            for (NSString *key in [tree allKeys]) {
                if ([@"Root" isEqualToString:key]) {
                    self.rootName = [[tree dictForKey:key] stringForKey:@"ref"];
                } else if ([@"Levels" isEqualToString:key]) {
                    levels = [[tree dictForKey:key] intForKey:@"value"];
                } else if ([@"BoneLevels" isEqualToString:key]) {
                    boneLevels = [[tree dictForKey:key] intForKey:@"value"];
                } else if ([@"LeafAxis" isEqualToString:key]) {
                    self.leafAxis = [[tree dictForKey:key] vector3ForKey:@"value"];
                    self.leafAxis = CC3VectorNormalize(self.leafAxis);
                } else if ([@"Production" isEqualToString:key]) {
                    NSString *name = [[tree dictForKey:key] stringForKey:@"id"];
                    Production *production = [[Production alloc] init];
                    NSDictionary *node = [tree dictForKey:key];
                    [productions setObject:[[ProductionNodePair alloc] initWithProduction:production andNode:node] forKey:name];
                } else if ([@"ConstrainUnderground" isEqualToString:key]) {
                    // TODO
                    // generator.Constraints.Constaints.Add(new ConstrainUndergroundBranches(XmlUtil.GetFloat(child, "lowerBound", 256.0f)));
                } else if ([@"TextureHeight" isEqualToString:key]) {
                    // TODO
                    // generator.TextureHeight = XmlUtil.GetFloat(child, "height");
                    // generator.TextureHeightVariation = XmlUtil.GetFloat(child, "variation", 0.0f);
                }
            }
        }
        
        NSAssert(self.rootName != nil, @"Root name must be specified.");
        
        // Now we have a map of names -> productions, so we can start parsing the the productions
        for (ProductionNodePair *pn in productions.allValues) {
            for (NSString *key in pn.node.allKeys) {
                TreeCrayonInstruction *instruction = nil;
                
                if ([@"Call" isEqualToString:key]) {
                    NSArray* refs = nil;
                    int delta = -1;
                    instruction = [[Call alloc] initWithProductions:refs andDelta:delta];
                }

                [pn.production.instructions addObject:instruction];
            }
        }
        
        self.root = ((ProductionNodePair*)[productions objectForKey:self.rootName]).production;
        
        self.maxLevel = levels;
        self.boneLevels = boneLevels;
    }
        
    return self;
}

- (TreeSkeleton *)generateTree
{
    [self generateTreeWithContraints:nil];
}

- (TreeSkeleton *)generateTreeWithContraints:(TreeContraints *)userConstraint
{
    // TODO
    NSAssert(self.root != nil && self.maxLevel != 0, @"TreeGenerator has not been initialized. Must set Root and MaxLevel before generating a tree.");
    
    TreeCrayon *crayon = [[TreeCrayon alloc] init];
    crayon.level = self.maxLevel;
    crayon.boneLevels = self.boneLevels;
    crayon.constraints = _constraints;
    _constraints.userConstraint = userConstraint;
    crayon.skeleton.leafAxis = self.leafAxis;
    
    TreeBone *bone = [[TreeBone alloc] initWithRotation:[CC3GLMatrix identity] andParentIndex:-1 andReferenceTransform:[CC3GLMatrix identity] andInverseReferenceTransform:[CC3GLMatrix identity] andLength:1 andStiffness:1 andEndBranchIndex:-1];
    [crayon.skeleton addBone:bone];
    [self.root executeCrayon:crayon];
    
    [crayon.skeleton closeEdgeBranches];
    
    crayon.skeleton.textureHeight = self.textureHeight + self.textureHeightVariation * (2.0f * RandomFloat() - 1.0f);
    
    return crayon.skeleton;
}

@end
