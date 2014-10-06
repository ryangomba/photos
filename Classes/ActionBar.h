//
//  ActionBar.h
//  Photos
//
//  Created by Ryan Gomba on 10/4/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActionBar;
@protocol ActionBarDelegate <NSObject>

- (void)actionBarDidSelectEvent:(ActionBar *)actionBar;
- (void)actionBarDidSelectTopic:(ActionBar *)actionBar;
- (void)actionBarDidSelectDelete:(ActionBar *)actionBar;
- (void)actionBarDidSelectCancel:(ActionBar *)actionBar;

@end

@interface ActionBar : UIView

@property (nonatomic, weak) id<ActionBarDelegate> delegate;

@end
