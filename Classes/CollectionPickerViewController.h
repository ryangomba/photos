//
//  CollectionPickerViewController.h
//  Photos
//
//  Created by Ryan Gomba on 10/6/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Collection.h"
#import "DataSource.h"

@class CollectionPickerViewController;
@protocol CollectionPickerViewControllerDelegate <NSObject>

- (void)collectionPickerViewController:(CollectionPickerViewController *)controller
           didCreateNewCollectionNamed:(NSString *)collectionName;
- (void)collectionPickerViewController:(CollectionPickerViewController *)controller
           didSelectExistingCollection:(NSObject<Collection> *)collection;

@end

@interface CollectionPickerViewController : UIViewController

- (instancetype)initWithCollectionType:(CollectionType)collectionType dataSource:(DataSource *)dataSource;

@property (nonatomic, assign, readonly) CollectionType collectionType;

@property (nonatomic, weak) id<CollectionPickerViewControllerDelegate> delegate;

@end
