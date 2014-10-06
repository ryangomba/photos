//
//  CollectionPickerViewController.m
//  Photos
//
//  Created by Ryan Gomba on 10/6/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "CollectionPickerViewController.h"

#import <RGInterfaceKit/RGColors.h>

#import "Collection.h"
#import "CollectionCell.h"

static CGFloat const kCellHeight = 80.0;
static CGFloat const kCellSpacing = 1.0;

static NSString * const kCellReuseID = @"cell";

@interface CollectionPickerViewController ()<UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign, readwrite) CollectionType collectionType;
@property (nonatomic, assign) DataSource *dataSource;

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@end

@implementation CollectionPickerViewController

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithCollectionType:(CollectionType)collectionType dataSource:(DataSource *)dataSource {
    if (self = [super init]) {
        self.collectionType = collectionType;
        self.dataSource = dataSource;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onKeyboardFrameWillChange:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];
    }
    return self;
}


#pragma mark -
#pragma mark Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = HEX_COLOR(0x222222);
    
    CGRect textFieldContainerRect = CGRectMake(0.0, 20.0, self.view.bounds.size.width, kCellHeight);
    self.textField.frame = CGRectInset(textFieldContainerRect, 24.0, 12.0);
    [self.view addSubview:self.textField];
    
    CGFloat collectionViewY = CGRectGetMaxY(textFieldContainerRect);
    CGFloat collectionViewHeight = self.view.bounds.size.height - collectionViewY;
    CGRect collectionViewRect = CGRectMake(0.0, collectionViewY, self.view.bounds.size.width, collectionViewHeight);
    self.collectionView.frame = collectionViewRect;
    [self.view addSubview:self.collectionView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.textField becomeFirstResponder];
}


#pragma mark -
#pragma mark Properties

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectZero];
        _textField.placeholder = @"Start typing...";
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.textColor = [UIColor whiteColor];
        _textField.delegate = self;
        
        UITextAutocapitalizationType capitalizationType;
        switch (self.collectionType) {
            case CollectionTypeEvent:
                capitalizationType = UITextAutocapitalizationTypeSentences;
                break;
            case CollectionTypeTopic:
                capitalizationType = UITextAutocapitalizationTypeNone;
                break;
        }
        _textField.autocapitalizationType = capitalizationType;
    }
    return _textField;
}

- (UICollectionViewFlowLayout *)layout {
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
    }
    return _layout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        [_collectionView registerClass:[CollectionCell class] forCellWithReuseIdentifier:kCellReuseID];
    }
    return _collectionView;
}


#pragma mark -
#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataSource.numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseID forIndexPath:indexPath];
    cell.collection = [self.dataSource objectAtIndexPath:indexPath];
    return cell;
}


#pragma mark -
#pragma mark UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kCellSpacing;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.bounds.size.width, kCellHeight);
}


#pragma mark -
#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSObject<Collection> *collection = [self.dataSource objectAtIndexPath:indexPath];
    [self.delegate collectionPickerViewController:self didSelectExistingCollection:collection];
    [self.textField resignFirstResponder];
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0) {
        [self.delegate collectionPickerViewController:self didCreateNewCollectionNamed:textField.text];
        [self.textField resignFirstResponder];
        return YES;
    }
    return NO;
}


#pragma mark -
#pragma mark Notifications

- (void)onKeyboardFrameWillChange:(NSNotification *)notification {
    CGRect newFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat bottomInset = MAX(self.view.bounds.size.height - CGRectGetMinY(newFrame), 0.0);
    
    CGFloat animationDuration = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] floatValue];
    UIViewAnimationCurve animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:animationDuration animations:^{
        [UIView setAnimationCurve:animationCurve];
        
        self.collectionView.contentInset = UIEdgeInsetsMake(0.0, 0.0, bottomInset, 0.0);
    }];
    
}

@end
