//
//  GLViewController.h
//  Rend Example Collection
//
//  Created by Anton Holmquist on 6/26/12.
//  Copyright (c) 2012 Monterosa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLViewController : UIViewController {
    REGLView *glView_;
    REScene *scene_;
    REWorld *world_;
    REDirector *director_;
    RECamera *camera_;
}

@property (nonatomic, readonly) REGLView *glView;
@property (nonatomic, readonly) REScene *scene;
@property (nonatomic, readonly) REWorld *world;
@property (nonatomic, readonly) RECamera *camera;

- (void)update:(float)dt;

- (void)zoomIn;
- (void)zoomOut;
@property (readonly, getter=getZoomLevel) NSString *zoomLevel;

- (void)center;

@end
