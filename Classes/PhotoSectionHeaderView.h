//
//  PhotoSectionHeaderView.h
//  Photos
//
//  Created by Ryan Gomba on 10/6/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoSectionHeaderView;
@protocol PhotoSectionHeaderViewDelegate <NSObject>

- (void)photoSectionHeaderViewDidAskForSelection:(PhotoSectionHeaderView *)headerView;

@end

@interface PhotoSectionHeaderView : UICollectionReusableView

@property (nonatomic, assign) NSInteger sectionIndex;
@property (nonatomic, strong) NSString *title;

@property (nonatomic, weak) id<PhotoSectionHeaderViewDelegate> delegate;

@end
