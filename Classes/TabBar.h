//
//  TabBar.h
//  Photos
//
//  Created by Ryan Gomba on 10/5/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TabBarItem.h"

@class TabBar;
@protocol TabBarDelegate <NSObject>

- (void)tabBar:(TabBar *)tabBar didSelectItem:(TabBarItem *)item atIndex:(NSInteger)itemIndex;

@end

@interface TabBar : UIView

@property (nonatomic, assign) NSInteger selectedItemIndex;

@property (nonatomic, weak) id<TabBarDelegate> delegate;

- (instancetype)initWithTabBarItems:(NSArray *)tabBarItems;

@end
