//
//  MainImageCell.h
//  CZYImageBrowserDemo
//
//  Created by 李正兵 on 2018/9/14.
//  Copyright © 2018年 李正兵. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainImageCell : UICollectionViewCell

@property (weak, nonatomic, readonly) IBOutlet UIImageView *mainImageView;

@property (nonatomic, strong) id data;

@end
