//
//  CZYIBCopywriter.h
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/18.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CZYIBCopywriterType) {
    CZYIBCopywriterTypeSimplifiedChinese,
    CZYIBCopywriterTypeEnglish
};

@interface CZYIBCopywriter : NSObject

+ (instancetype)shareCopywriter;

/** You can set up language classes explicitly. */
@property (nonatomic, assign) CZYIBCopywriterType type;


// The following propertys can be changed.

@property (nonatomic, copy) NSString *videoIsInvalid;

@property (nonatomic, copy) NSString *videoError;

@property (nonatomic, copy) NSString *unableToSave;

@property (nonatomic, copy) NSString *imageIsInvalid;

@property (nonatomic, copy) NSString *downloadImageFailed;

@property (nonatomic, copy) NSString *getPhotoAlbumAuthorizationFailed;

@property (nonatomic, copy) NSString *saveToPhotoAlbumSuccess;

@property (nonatomic, copy) NSString *saveToPhotoAlbumFailed;

@property (nonatomic, copy) NSString *saveToPhotoAlbum;

@property (nonatomic, copy) NSString *cancel;

@end

NS_ASSUME_NONNULL_END
