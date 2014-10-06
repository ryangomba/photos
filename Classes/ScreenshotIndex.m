//  Copyright (c) 2013 Ryan Gomba. All rights reserved.

#import "ScreenshotIndex.h"

@implementation ScreenshotIndex

static NSSet *sScreenshotSizes;

+ (void)initialize {
    sScreenshotSizes =
    [NSSet setWithObjects:
     // short iPhone
     [NSValue valueWithCGSize:CGSizeMake(320, 480)],
     [NSValue valueWithCGSize:CGSizeMake(480, 320)],
     [NSValue valueWithCGSize:CGSizeMake(640, 960)],
     [NSValue valueWithCGSize:CGSizeMake(960, 640)],
     // tall iPhone
     [NSValue valueWithCGSize:CGSizeMake(640, 1136)],
     [NSValue valueWithCGSize:CGSizeMake(1136, 640)],
     // iPhone 6
     [NSValue valueWithCGSize:CGSizeMake(750, 1334)],
     [NSValue valueWithCGSize:CGSizeMake(1334, 750)],
     // iPhone 6+
     [NSValue valueWithCGSize:CGSizeMake(1242, 2208)],
     [NSValue valueWithCGSize:CGSizeMake(2208, 1242)],
     // iPad
     [NSValue valueWithCGSize:CGSizeMake(768, 1024)],
     [NSValue valueWithCGSize:CGSizeMake(1024, 768)],
     [NSValue valueWithCGSize:CGSizeMake(1536, 2048)],
     [NSValue valueWithCGSize:CGSizeMake(2048, 1536)],
     nil];
}

+ (BOOL)imageSizeQualifiesAsScreenshot:(CGSize)imageSize {
    return [sScreenshotSizes containsObject:[NSValue valueWithCGSize:imageSize]];
}

@end
