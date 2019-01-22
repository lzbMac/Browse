//
//  CZYIBUtilities.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/18.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if DEBUG
#define CZYIBLOG(format, ...) fprintf(stderr,"%s\n",[[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String])
#else
#define CZYIBLOG(format, ...) nil
#endif

#define CZYIBLOG_WARNING(discribe) CZYIBLOG(@"%@ ⚠️ SEL-%@ %@", self.class, NSStringFromSelector(_cmd), discribe)
#define CZYIBLOG_ERROR(discribe)   CZYIBLOG(@"%@ ❌ SEL-%@ %@", self.class, NSStringFromSelector(_cmd), discribe)


#define CZYIB_GET_QUEUE_ASYNC(queue, block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {\
block();\
} else {\
dispatch_async(queue, block);\
}

#define CZYIB_GET_QUEUE_MAIN_ASYNC(block) CZYIB_GET_QUEUE_ASYNC(dispatch_get_main_queue(), block)


#define CZYIB_STATUSBAR_ORIENTATION    [UIApplication sharedApplication].statusBarOrientation
#define CZYIMAGEBROWSER_HEIGHT       ((CZYIB_STATUSBAR_ORIENTATION == UIInterfaceOrientationPortrait || CZYIB_STATUSBAR_ORIENTATION == UIInterfaceOrientationPortraitUpsideDown) ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width)
#define CZYIMAGEBROWSER_WIDTH        ((CZYIB_STATUSBAR_ORIENTATION == UIInterfaceOrientationPortrait || CZYIB_STATUSBAR_ORIENTATION == UIInterfaceOrientationPortraitUpsideDown) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)


#define CZYIB_IS_IPHONEX           [CZYIBUtilities isIphoneX]
#define CZYIB_HEIGHT_EXTRABOTTOM   (CZYIB_IS_IPHONEX ? 34.0 : 0)
#define CZYIB_HEIGHT_STATUSBAR     (CZYIB_IS_IPHONEX ? 44.0 : 20.0)


UIWindow *CZYIBGetNormalWindow(void);

UIViewController *CZYIBGetTopController(void);


NS_ASSUME_NONNULL_BEGIN

@interface CZYIBUtilities : NSObject

+ (BOOL)isIphoneX;

+ (void)countTimeConsumingOfCode:(void(^)(void))code;

@end

NS_ASSUME_NONNULL_END
