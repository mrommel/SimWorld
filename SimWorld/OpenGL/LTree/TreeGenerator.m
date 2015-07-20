//
//  TreeGenerator.m
//  SimWorld
//
//  Created by Michael Rommel on 16.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeGenerator.h"
#import "XMLReader.h"

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
        //XmlNode root = document.SelectSingleNode("Tree");
        
        // TODO
        /*foreach (XmlNode child in root.ChildNodes)
        {
            switch (child.Name)
            {
                case "Root":
                    rootName = XmlUtil.GetString(child, "ref");
                    break;
                    
                case "Levels":
                    levels = XmlUtil.GetInt(child, "value");
                    break;
                    
                case "BoneLevels":
                    boneLevels = XmlUtil.GetInt(child, "value");
                    break;
                    
                case "LeafAxis":
                    generator.LeafAxis = XmlUtil.GetVector3(child, "value");
                    generator.LeafAxis.Value.Normalize();
                    break;
                    
                case "Production":
                    string name = XmlUtil.GetString(child, "id");
                    productions.Add(name, new ProductionNodePair(new Production(), child));
                    break;
                    
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
        
        generator.Root = productions[rootName][0].Production;
        generator.MaxLevel = levels;
        generator.BoneLevels = boneLevels;*/
    }
        
    return self;
}

- (TreeSkeleton *)generateTree
{
    // TODO
    return nil;
}

@end
