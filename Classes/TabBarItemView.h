//
//  TabBarItemView.h
//  Photos
//
//  Created by Ryan Gomba on 10/5/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TabBarItem.h"

@class TabBarItemView;
@protocol TabBarItemViewDelegate <NSObject>

- (void)tabBarItemViewDidRecieveTap:(TabBarItemView *)tabBarItemView;

@end

@interface TabBarItemView : UIView

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, weak) id<TabBarItemViewDelegate> delegate;

- (instancetype)initWithTabBarItem:(TabBarItem *)tabBarItem;

@end
