//
//  TopicViewController.m
//  Photos
//
//  Created by Ryan Gomba on 10/5/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "TopicViewController.h"

#import "PhotosListViewController.h"

@interface TopicViewController ()

@property (nonatomic, strong) Topic *topic;

@end

@implementation TopicViewController

- (instancetype)initWithTopic:(Topic *)topic {
    if (self = [super init]) {
        self.topic = topic;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeButton sizeToFit];
    [closeButton addTarget:self action:@selector(onCloseButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    closeButton.frame = CGRectMake(0.0, 20.0, closeButton.bounds.size.width, 64.0);
    [self.view addSubview:closeButton];
    
    PhotosDataSource *dataSource = [[PhotosDataSource alloc] initWithCollectionKey:self.topic.pk];
    PhotosListViewController *photosVC = [[PhotosListViewController alloc] initWithDataSource:dataSource];
    [self addChildViewController:photosVC];
    photosVC.view.frame = UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(84.0, 0.0, 0.0, 0.0));
    [self.view addSubview:photosVC.view];
    [photosVC didMoveToParentViewController:self];
}

- (void)onCloseButtonTapped {
    // TODO delegate call
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
