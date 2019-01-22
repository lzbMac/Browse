//
//  CZYIBFileManager.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/17.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CZYIBFileManager : NSObject

+ (UIImage *)getImageWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
