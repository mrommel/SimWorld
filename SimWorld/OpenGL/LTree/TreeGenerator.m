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
#import "TreeConstrainUndergroundBranches.h"
#import "CC3GLMatrix+Extension.h"
#import "GDataXMLNode.h"
#import "GDataXMLNode+Extension.h"
#import "MultiMap.h"

@interface ProductionNodePair : NSObject

@property (nonatomic, retain) Production *production;
@property (nonatomic, retain) GDataXMLElement *node;

- (id)initWithProduction:(Production *)production andNode:(GDataXMLElement *)node;

@end

@implementation ProductionNodePair

- (id)initWithProduction:(Production *)production andNode:(GDataXMLElement *)node
{
    self = [super init];
    
    if (self) {
        self.production = production;
        self.node = node;
    }
    
    return self;
}

@end

@interface TreeGenerator() {

    TreeCompositeConstraints *_constraints;
    float _textureHeight;
    float _textureHeightVariation;
}

@property (nonatomic, retain) NSString *profileName;

@end

@implementation TreeGenerator

- (id)init
{
    self = [super init];
    
    if (self) {
        _constraints = [[TreeCompositeConstraints alloc] init];
        _textureHeight = 512.0f;
        _textureHeightVariation = 0.0f;
    }
    
    return self;
}

- (id)initFromTreeFile:(NSString *)ltreeFilename
{
    self = [self init];
    
    if (self) {
        self.profileName = ltreeFilename;
        
        NSString *rootName = nil;
        int levels = -1;
        int boneLevels = 3;

        MultiMap *productions = [MultiMap map];
        
        NSData *myData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:ltreeFilename
                                                                                        ofType:@"ltree"]];
        
        NSError* error = nil;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:myData options:0 error:&error];

        if (!error) {
            GDataXMLElement *rootElement = [doc rootElement];
            //NSLog(@"Nodes: %lu", (unsigned long)rootElement.childCount);
        
            for (GDataXMLElement *node in rootElement.children) {
                //NSLog(@"Parse: %@", node.name);
                
                if ([@"Root" isEqualToString:node.name]) {
                    rootName = [[node attributeForName:@"ref"] stringValue];
                } else if ([@"Levels" isEqualToString:node.name]) {
                    levels = [[node attributeForName:@"value"] intValue];
                } else if ([@"BoneLevels" isEqualToString:node.name]) {
                    boneLevels = [[node attributeForName:@"value"] intValue];
                } else if ([@"LeafAxis" isEqualToString:node.name]) {
                    self.leafAxis = [[node attributeForName:@"value"] vector3Value];
                    self.leafAxis = CC3VectorNormalize(self.leafAxis);
                } else if ([@"Production" isEqualToString:node.name]) {
                    NSString *name = [[node attributeForName:@"id"] stringValue];
                    Production *production = [[Production alloc] initWithName:name];
                    [productions addObject:[[ProductionNodePair alloc] initWithProduction:production andNode:node] forKey:name];
                } else if ([@"ConstrainUnderground" isEqualToString:node.name]) {
                    float lowerBound = [[node attributeForName:@"lowerBound"] floatValueWithDefault:256.0f];
                    TreeConstrainUndergroundBranches *constrainUndergroundBranches = [[TreeConstrainUndergroundBranches alloc] initWithLimit:lowerBound];
                    [_constraints.constaints addObject:constrainUndergroundBranches];
                } else if ([@"TextureHeight" isEqualToString:node.name]) {
                    _textureHeight = [[node attributeForName:@"height"] floatValueWithDefault:0.0f];
                    _textureHeightVariation = [[node attributeForName:@"variation"] floatValueWithDefault:0.0f];
                } else if ([@"TrunkTexture" isEqualToString:node.name]) {
                    self.trunkTextureName = [node stringValue];
                } else if ([@"LeafTexture" isEqualToString:node.name]) {
                    self.leafTextureName = [node stringValue];
                }
            }
        }
        
        NSAssert(rootName != nil, @"Root name must be specified.");
        
        // Now we have a map of names -> productions, so we can start parsing the productions
        for (ProductionNodePair *pn in productions.allValues) {
            for (GDataXMLElement *node in pn.node.children) {
                TreeCrayonInstruction *instruction = [TreeGenerator parseInstructionFromKey:node.name andNode:node andProductions:productions];
                [pn.production.instructions addObject:instruction];
            }
        }
        
        // productions[rootName][0].Production
        self.root = ((ProductionNodePair*)[[productions objectsForKey:rootName] firstObject]).production;
        
        self.maxLevel = levels;
        self.boneLevels = boneLevels;
    }
        
    return self;
}

+ (TreeCrayonInstruction *)parseInstructionFromKey:(NSString *)key andNode:(GDataXMLElement *)node andProductions:(MultiMap *)productions
{
    //NSLog(@"Parsing: %@", key);
    if ([@"Call" isEqualToString:key]) {
        NSString *name = [[node attributeForName:@"ref"] stringValue];
        NSArray* refs = [TreeGenerator productionsByName:name fromProductionList:productions];
        int delta = [node intAttributeForName:@"delta" withDefault:-1];
        return [[Call alloc] initWithName:name andProductions:refs andDelta:delta];
    } else if ([@"Child" isEqualToString:key]) {
        Child *child = [[Child alloc] init];
        for (GDataXMLElement* childNode in node.children) {
            TreeCrayonInstruction *instruction = [TreeGenerator parseInstructionFromKey:childNode.name andNode:childNode andProductions:productions];
            [child addInstruction:instruction];
        }
        return child;
    } else if ([@"Maybe" isEqualToString:key]) {
        float chance = [[node attributeForName:@"chance"] floatValueWithDefault:0.50f];
        Maybe *maybe = [[Maybe alloc] initWithChance:chance];
        for (GDataXMLElement* childNode in node.children) {
            TreeCrayonInstruction *instruction = [TreeGenerator parseInstructionFromKey:childNode.name andNode:childNode andProductions:productions];
            [maybe addInstruction:instruction];
        }
        return maybe;
    } else if ([@"Forward" isEqualToString:key]) {
        float distance = [[node attributeForName:@"distance"] floatValue];
        float variation = [node floatAttributeForName:@"variation" withDefault:0.0f];
        float radius = [node floatAttributeForName:@"radius" withDefault:0.86f];
        return [[Forward alloc] initWithDistance:distance andVariation:variation andRadius:radius];
    } else if ([@"Backward" isEqualToString:key]) {
        float distance = [[node attributeForName:@"distance"] floatValue];
        float variation = [node floatAttributeForName:@"variation" withDefault:0.0f];
        return [[Backward alloc] initWithDistance:distance andVariation:variation];
    } else if ([@"Pitch" isEqualToString:key]) {
        float angle = [[node attributeForName:@"angle"] floatValue];
        float variation = [node floatAttributeForName:@"variation" withDefault:0.0f];
        return [[Pitch alloc] initWithAngle:angle andVariation:variation];
    } else if ([@"Scale" isEqualToString:key]) {
        float scale = [[node attributeForName:@"scale"] floatValue];
        float variation = [node floatAttributeForName:@"variation" withDefault:0.0f];
        return [[Scale alloc] initWithScale:scale andVariation:variation];
    } else if ([@"ScaleRadius" isEqualToString:key]) {
        float scale = [[node attributeForName:@"scale"] floatValue];
        float variation = [node floatAttributeForName:@"variation" withDefault:0.0f];
        return [[ScaleRadius alloc] initWithScale:scale andVariation:variation];
    } else if ([@"Twist" isEqualToString:key]) {
        float angle = [node floatAttributeForName:@"angle" withDefault:0];
        float variation = [node floatAttributeForName:@"variation" withDefault:360.0f];
        return [[Twist alloc] initWithAngle:angle andVariation:variation];
    } else if ([@"Level" isEqualToString:key]) {
        int delta = [node intAttributeForName:@"delta" withDefault:-1];
        return [[Level alloc] initWithDelta:delta];
    } else if ([@"Leaf" isEqualToString:key]) {
        Leaf *leaf = [[Leaf alloc] init];
        GDataXMLElement *colorNode = [[node elementsForName:@"Color"] firstObject];
        leaf.color = [[colorNode attributeForName:@"value"] vector4Value];
        leaf.colorVariation = [[colorNode attributeForName:@"variation"] vector4ValueWithDefault:kCC3Vector4Zero];
        GDataXMLElement *sizeNode = [[node elementsForName:@"Size"] firstObject];
        leaf.size = [[sizeNode attributeForName:@"value"] vector2Value];
        leaf.sizeVariation = [[sizeNode attributeForName:@"variation"] vector2ValueWithDefault:kCC3Vector2Zero];
        GDataXMLElement *axisOffsetNode = [[node elementsForName:@"AxisOffset"] firstObject];
        leaf.axisOffset = [[axisOffsetNode attributeForName:@"value"] floatValue];
        return leaf;
    } else if ([@"Bone" isEqualToString:key]) {
        float delta = [node intAttributeForName:@"delta" withDefault:-1];
        return [[Bone alloc] initWithDelta:delta];
    } else if ([@"RequireLevel" isEqualToString:key]) {
        NSString *compareType = [[node attributeForName:@"type"] stringValue];
        int level = [node intAttributeForName:@"level" withDefault:-1];
        RequireLevel *requireLevel = [[RequireLevel alloc] initWithLevel:level andCompareType:compareType];
        for (GDataXMLElement* childNode in node.children) {
            TreeCrayonInstruction *instruction = [TreeGenerator parseInstructionFromKey:childNode.name andNode:childNode andProductions:productions];
            [requireLevel addInstruction:instruction];
        }
        return requireLevel;
    } else if ([@"Align" isEqualToString:key]) {
        return [[Align alloc] init];
    } else {
        return nil;
    }
}

+ (NSMutableArray *)productionsByName:(NSString *)name fromProductionList:(MultiMap *)map
{
    NSArray *names = [name componentsSeparatedByString:@"|"];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    for (NSString *n in names) {
        NSAssert([map objectsForKey:n].count > 0, @"No production exists with the name '%@'", n);
        NSArray *np = [map objectsForKey:n];
        
        if (np.count == 0) continue;
        for (ProductionNodePair *pair in np) {
            [list addObject:pair.production];
        }
    }
    return list;
}

- (TreeSkeleton *)generateTree
{
    return [self generateTreeWithContraints:nil];
}

- (TreeSkeleton *)generateTreeWithContraints:(TreeContraints *)userConstraint
{
    NSAssert(self.root != nil && self.maxLevel != 0, @"TreeGenerator has not been initialized. Must set Root and MaxLevel before generating a tree.");
    
    TreeCrayon *crayon = [[TreeCrayon alloc] initWithName:self.profileName];
    crayon.level = self.maxLevel;
    crayon.boneLevels = self.boneLevels;
    crayon.constraints = _constraints;
    _constraints.userConstraint = userConstraint;
    crayon.skeleton.leafAxis = [[CC3GLVector alloc] initWithVector:self.leafAxis];
    
    TreeBone *bone = [[TreeBone alloc] initWithRotation:[CC3GLMatrix identity] andParentIndex:-1 andReferenceTransform:[CC3GLMatrix identity] andInverseReferenceTransform:[CC3GLMatrix identity] andLength:1 andStiffness:1 andEndBranchIndex:-1];
    [crayon.skeleton addBone:bone];
    
    [self.root executeCrayon:crayon];
    
    [crayon.skeleton closeEdgeBranches];
    
    crayon.skeleton.textureHeight = _textureHeight + _textureHeightVariation * (2.0f * RandomFloat() - 1.0f);
    
    return crayon.skeleton;
}

@end
