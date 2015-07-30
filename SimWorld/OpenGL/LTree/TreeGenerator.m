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

@interface ProductionNodePair : NSObject

@property (nonatomic, retain) Production *production;
@property (nonatomic, retain) NSDictionary *node;

-(id) initWithProduction:(Production *)production andNode:(NSDictionary *)node;

@end

@implementation ProductionNodePair

-(id) initWithProduction:(Production *)production andNode:(NSDictionary *)node
{
    self = [super init];
    
    if (self) {
        self.production = production;
        self.node = node;
    }
    
    return self;
}

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
                    [productions setObject:[[ProductionNodePair alloc] initWithDict:[tree dictForKey:key] ] forKey:name]
                }
            }
        }
        
        
        // TODO
        /*foreach (XmlNode child in root.ChildNodes)
        {
            switch (child.Name)
            {
                case "ConstrainUnderground":
                    generator.Constraints.Constaints.Add(new ConstrainUndergroundBranches(XmlUtil.GetFloat(child, "lowerBound", 256.0f)));
                    break;
                    
                case "TextureHeight":
                    generator.TextureHeight = XmlUtil.GetFloat(child, "height");
                    generator.TextureHeightVariation = XmlUtil.GetFloat(child, "variation", 0.0f);
                    break;
            }
        }
        
        if (rootName == null)
            throw new ArgumentException("Root name must be specified.");
        
        // Now we have a map of names -> productions, so we can start parsing the the productions
        foreach (ProductionNodePair pn in productions.Values)
        {
            ParseInstructionsFromXml(pn.Node, pn.Production.Instructions, productions);
        }
        
        generator.Root = productions[rootName][0].Production;*/
        self.maxLevel = levels;
        self.boneLevels = boneLevels;
    }
        
    return self;
}

- (TreeSkeleton *)generateTree
{
    // TODO
    return nil;
}

@end
