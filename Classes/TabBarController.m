//
//  TabBarController.m
//  Photos
//
//  Created by Ryan Gomba on 10/3/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "TabBarController.h"

#import <RGInterfaceKit/RGColors.h>
#import "TabBar.h"

static CGFloat const kTabBarY = 30.0;
static CGFloat const kTabBarHeight = 54.0;

@interface TabBarController ()<TabBarDelegate>

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) TabBar *tabBar;

@end

@implementation TabBarController

- (instancetype)initWithViewControllers:(NSArray *)viewControllers {
    if (self = [super init]) {
        self.viewControllers = viewControllers;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = self.barColor;
    
    for (UIViewController *viewController in self.viewControllers) {
        [self addChildViewController:viewController];
        viewController.view.frame = self.view.bounds;
        [self.view addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
    }
    
    [self.view addSubview:self.tabBar];
    
    self.tabBar.selectedItemIndex = 0;
    [self moveToViewControllerAtIndex:0];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIColor *)barColor {
    return HEX_COLOR(0x222222);
}

- (TabBar *)tabBar {
    if (!_tabBar) {
        NSArray *tabBarItems = [self.viewControllers valueForKey:@"barItem"];
        _tabBar = [[TabBar alloc] initWithTabBarItems:tabBarItems];
        _tabBar.delegate = self;
    }
    return _tabBar;
}

- (void)tabBar:(TabBar *)tabBar didSelectItem:(TabBarItem *)item atIndex:(NSInteger)itemIndex {
    [self moveToViewControllerAtIndex:itemIndex];
}

- (void)moveToViewControllerAtIndex:(NSInteger)selectedIndex {
    [self.childViewControllers enumerateObjectsUsingBlock:
     ^(UIViewController *viewController, NSUInteger i, BOOL *stop) {
         viewController.view.hidden = i != selectedIndex;
    }];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.tabBar.frame = CGRectMake(0.0, kTabBarY, self.view.bounds.size.width, kTabBarHeight);
    for (UIViewController *viewController in self.childViewControllers) {
        viewController.view.frame = UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(kTabBarY + kTabBarHeight, 0.0, 0.0, 0.0));
    }
}

@end
