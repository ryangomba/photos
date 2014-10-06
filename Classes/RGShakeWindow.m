// Copyright 2004-present Facebook. All Rights Reserved.

#import "RGShakeWindow.h"

#import "Database.h"
#import "PhotoImporter.h"

static CGFloat kMinDurationForShake = 0.5;

@interface RGShakeWindow ()

@property (nonatomic, assign) NSTimeInterval motionStart;
@property (nonatomic, assign) BOOL isReporting;

@end

@implementation RGShakeWindow

#pragma mark -
#pragma mark Shake Detection

- (NSTimeInterval)elapsedGestureTimeUntilNow {
    NSTimeInterval elapsedGestureTime;
    #if TARGET_IPHONE_SIMULATOR
    elapsedGestureTime = kMinDurationForShake;
    #else
    elapsedGestureTime = CACurrentMediaTime() - self.motionStart;
    #endif
    return elapsedGestureTime;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        if (!self.isReporting && [self elapsedGestureTimeUntilNow] >= kMinDurationForShake) {
            [self showShakeOptions];
        }
        self.motionStart = 0.0;
    }
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        self.motionStart = CACurrentMediaTime();
    }
}


#pragma mark -
#pragma mark Alert

- (void)showShakeOptions {
    _isReporting = YES;

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Debug"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Wipe Database", nil];

    [alertView setDelegate:self];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    _isReporting = NO;
    
    if (buttonIndex != [alertView cancelButtonIndex]) {
        [Database wipeDatabase];
        [[PhotoImporter sharedPhotoImporter] importPhotos];
    }
}

@end
