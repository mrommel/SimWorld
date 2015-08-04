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

@interface TreeGenerator() {

    TreeCompositeConstraints *_constraints;
    float _textureHeight;
    float _textureHeightVariation;
}

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
            //NSLog(@"Nodes: %lu", (unsigned long)tree.count);
        
            for (NSString *key in [tree allKeys]) {
                //NSLog(@"Parse: %@", key);
                NSDictionary *node = [tree dictForKey:key];
                if ([@"Root" isEqualToString:key]) {
                    rootName = [node stringForKey:@"ref"];
                } else if ([@"Levels" isEqualToString:key]) {
                    levels = [node intForKey:@"value"];
                } else if ([@"BoneLevels" isEqualToString:key]) {
                    boneLevels = [node intForKey:@"value"];
                } else if ([@"LeafAxis" isEqualToString:key]) {
                    self.leafAxis = [node vector3ForKey:@"value"];
                    self.leafAxis = CC3VectorNormalize(self.leafAxis);
                } else if ([@"Production" isEqualToString:key]) {
                    for (NSDictionary *productionNode in node) {
                        NSString *name = [productionNode stringForKey:@"id"];
                        Production *production = [[Production alloc] init];
                        [productions setObject:[[ProductionNodePair alloc] initWithProduction:production andNode:productionNode] forKey:name];
                    }
                } else if ([@"ConstrainUnderground" isEqualToString:key]) {
                    id lowerBoundObj = [node objectForKey:@"lowerBound"];
                    float lowerBound = lowerBoundObj != nil ? [lowerBoundObj floatValue] : 256.0f;
                    TreeConstrainUndergroundBranches *constrainUndergroundBranches = [[TreeConstrainUndergroundBranches alloc] initWithLimit:lowerBound];
                    [_constraints.constaints addObject:constrainUndergroundBranches];
                } else if ([@"TextureHeight" isEqualToString:key]) {
                    id heightObj = [node objectForKey:@"height"];
                    id variationObj = [node objectForKey:@"variation"];
                    _textureHeight = heightObj != nil ? [heightObj floatValue] : 0.0f;
                    _textureHeightVariation = variationObj != nil ? [variationObj floatValue] : 0.0f;
                }
            }
        }
        
        NSAssert(rootName != nil, @"Root name must be specified.");
        
        // Now we have a map of names -> productions, so we can start parsing the the productions
        for (ProductionNodePair *pn in productions.allValues) {
            for (NSString *key in pn.node.allKeys) {
                TreeCrayonInstruction *instruction = nil;
                NSDictionary *child = [pn.node dictForKey:key];
                
                if ([@"Call" isEqualToString:key]) {
                    NSString *name = [child stringForKey:@"ref"];
                    NSArray* refs = [TreeGenerator productionsByName:name fromProductionList:productions];
                    int delta = [child intForKey:@"delta" withDefault:-1];
                    instruction = [[Call alloc] initWithProductions:refs andDelta:delta];
                } else if ([@"Child" isEqualToString:key]) {
                    Child ch = new Child();
                    ParseInstructionsFromXml(child, ch.Instructions, map);
                    instructions.Add(ch);
                } else if ([@"Maybe" isEqualToString:key]) {
                    Maybe maybe = new Maybe(XmlUtil.GetFloat(child, "chance", 0.50f));
                    ParseInstructionsFromXml(child, maybe.Instructions, map);
                    instructions.Add(maybe);
                } else if ([@"Forward" isEqualToString:key]) {
                    instructions.Add(new Forward(XmlUtil.GetFloat(child, "distance"), XmlUtil.GetFloat(child, "variation", 0.0f), XmlUtil.GetFloat(child, "radius", 0.86f)));
                } else if ([@"Backward" isEqualToString:key]) {
                    instructions.Add(new Backward(XmlUtil.GetFloat(child, "distance"), XmlUtil.GetFloat(child, "variation", 0.0f)));
                } else if ([@"Pitch" isEqualToString:key]) {
                    instructions.Add(new Pitch(XmlUtil.GetFloat(child, "angle"), XmlUtil.GetFloat(child, "variation", 0.0f)));
                } else if ([@"Scale" isEqualToString:key]) {
                    instructions.Add(new Scale(XmlUtil.GetFloat(child, "scale"), XmlUtil.GetFloat(child, "variation", 0.0f)));
                } else if ([@"ScaleRadius" isEqualToString:key]) {
                    instructions.Add(new ScaleRadius(XmlUtil.GetFloat(child, "scale"), XmlUtil.GetFloat(child, "variation", 0.0f)));
                } else if ([@"Twist" isEqualToString:key]) {
                    instructions.Add(new Twist(XmlUtil.GetFloat(child, "angle", 0), XmlUtil.GetFloat(child, "variation", 360.0f)));
                } else if ([@"Level" isEqualToString:key]) {
                    instructions.Add(new Level(XmlUtil.GetInt(child, "delta", -1)));
                } else if ([@"Leaf" isEqualToString:key]) {
                    instructions.Add(ParseLeafFromXml(child));
                } else if ([@"Bone" isEqualToString:key]) {
                    instructions.Add(new Bone(XmlUtil.GetInt(child, "delta", -1)));
                } else if ([@"RequireLevel" isEqualToString:key]) {
                    NSString *type = XmlUtil.GetStringOrNull(child, "type");
                    CompareType ctype = type == "less" ? CompareType.Less : CompareType.Greater;
                    RequireLevel req = new RequireLevel(XmlUtil.GetInt(child, "level"), ctype);
                    ParseInstructionsFromXml(child, req.Instructions, map);
                    instructions.Add(req);
                } else if ([@"Align" isEqualToString:key]) {
                    instruction = [[Align alloc] init];
                }

                [pn.production.instructions addObject:instruction];
            }
        }
        
        self.root = ((ProductionNodePair*)[productions objectForKey:rootName]).production;
        
        self.maxLevel = levels;
        self.boneLevels = boneLevels;
    }
        
    return self;
}

+ (NSMutableArray *)productionsByName:(NSString *)name fromProductionList:(NSMutableDictionary *)map
{
    NSArray *names = [name componentsSeparatedByString:@"|"];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    for (NSString *n in names) {
        NSAssert([map objectForKey:n] != nil, @"No production exists with the name '%@'", n);
        NSArray *np = [map objectForKey:n];
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
    // TODO
    NSAssert(self.root != nil && self.maxLevel != 0, @"TreeGenerator has not been initialized. Must set Root and MaxLevel before generating a tree.");
    
    TreeCrayon *crayon = [[TreeCrayon alloc] init];
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
