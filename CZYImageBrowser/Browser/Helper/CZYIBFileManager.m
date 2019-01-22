//
//  CZYIBFileManager.m
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/17.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import "CZYIBFileManager.h"
#import "CZYImageBrowser.h"

// 最优图片比例搜索顺序
static NSArray *_NSBundlePreferredScales() {
    static NSArray *scales;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat screenScale = [UIScreen mainScreen].scale;
        if (screenScale <= 1) {
            scales = @[@1,@2,@3];
        } else if (screenScale <= 2) {
            scales = @[@2,@3,@1];
        } else {
            scales = @[@3,@2,@1];
        }
    });
    return scales;
}

// 给图片添加2X,3X.
static NSString *_NSStringByAppendingNameScale(NSString *string, CGFloat scale) {
    if (!string) return nil;
    if (fabs(scale - 1) <= __FLT_EPSILON__ || string.length == 0 || [string hasSuffix:@"/"]) return string.copy;
    return [string stringByAppendingFormat:@"@%@x", @(scale)];
}

@implementation CZYIBFileManager

+ (NSBundle *)czyImageBrowserBundle {
    static NSBundle *imageBrowserBundle = nil;
    if (imageBrowserBundle == nil) {
        NSBundle *bundle = [NSBundle bundleForClass:CZYImageBrowser.class];
        NSString *path = [bundle pathForResource:@"CZYImageBrowser" ofType:@"bundle"];
        imageBrowserBundle = [NSBundle bundleWithPath:path];
    }
    return imageBrowserBundle;
}

+ (UIImage *)getImageWithName:(NSString *)name {
    //Imitate 'YYImage', but don't need to determine image type, they are all 'png'.
    NSString *res = name, *path = nil;
    CGFloat scale = 1;
    NSArray *scales = _NSBundlePreferredScales();
    for (int s = 0; s < scales.count; s++) {
        scale = ((NSNumber *)scales[s]).floatValue;
        NSString *scaledName = _NSStringByAppendingNameScale(res, scale);
        path = [[self czyImageBrowserBundle] pathForResource:scaledName ofType:@"png"];
        if (path) break;
    }
    if (!path.length) return nil;
    return [UIImage imageWithContentsOfFile:path];
}


@end
