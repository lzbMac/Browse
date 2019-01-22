//
//  CollectionViewController.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/22.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PhotoType) {
    PhotoTypeLocal,
    PhotoTypeNet,
    PhotoTypeAsset,
};


@interface CollectionViewController : UIViewController

@property (nonatomic, assign)PhotoType type;

@end

NS_ASSUME_NONNULL_END
