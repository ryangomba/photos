//
//  TabBar.m
//  Photos
//
//  Created by Ryan Gomba on 10/5/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "TabBar.h"

#import "TabBarItemView.h"

@interface TabBar ()<TabBarItemViewDelegate>

@property (nonatomic, strong) NSArray *tabBarItems;
@property (nonatomic, strong) NSArray *tabBarItemViews;

@end

@implementation TabBar

- (instancetype)initWithTabBarItems:(NSArray *)tabBarItems {
    if (self = [super initWithFrame:CGRectZero]) {
        self.tabBarItems = tabBarItems;
        
        NSMutableArray *tabBarItemViews = [NSMutableArray array];
        for (TabBarItem *tabBarItem in self.tabBarItems) {
            TabBarItemView *tabBarItemView = [[TabBarItemView alloc] initWithTabBarItem:tabBarItem];
            tabBarItemView.delegate = self;
            [tabBarItemViews addObject:tabBarItemView];
            [self addSubview:tabBarItemView];
        }
        self.tabBarItemViews = tabBarItemViews;
    }
    return self;
}

- (void)tabBarItemViewDidRecieveTap:(TabBarItemView *)tabBarItemView {
    NSInteger itemIndex = [self.tabBarItemViews indexOfObject:tabBarItemView];
    [self setSelectedItemIndex:itemIndex informDelegate:YES];
}

- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex {
    [self setSelectedItemIndex:selectedItemIndex informDelegate:NO];
}

- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex informDelegate:(BOOL)informDelegate {
    TabBarItem *item = [self.tabBarItems objectAtIndex:selectedItemIndex];
    [self.tabBarItemViews enumerateObjectsUsingBlock:^(TabBarItemView *tabBarItemView, NSUInteger i, BOOL *stop) {
        tabBarItemView.selected = i == selectedItemIndex;
    }];
    if (informDelegate) {
        [self.delegate tabBar:self didSelectItem:item atIndex:selectedItemIndex];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSInteger itemWidth = self.bounds.size.width / self.tabBarItemViews.count;
    [self.tabBarItemViews enumerateObjectsUsingBlock:^(TabBarItemView *tabBarItemView, NSUInteger i, BOOL *stop) {
        NSInteger x = itemWidth * i;
        CGRect itemRect = CGRectMake(x, 0.0, itemWidth, self.bounds.size.height);
        tabBarItemView.frame = itemRect;
    }];
}

@end
