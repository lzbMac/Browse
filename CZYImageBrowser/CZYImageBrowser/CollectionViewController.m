//
//  CollectionViewController.m
//  CZYImageBrowser
//
//  Created by 李正兵 on 2019/1/22.
//  Copyright © 2019 李正兵. All rights reserved.
//

#import "CollectionViewController.h"
#import "MainImageCell.h"
#import "CZYImageBrowser.h"
#import <Photos/Photos.h>
#import "CustomCellData.h"

@interface CollectionViewController ()<CZYImageBrowserDataSource>

@property (nonatomic, strong)NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation CollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
    [self.collectionView registerNib:[UINib nibWithNibName:@"MainImageCell" bundle:nil] forCellWithReuseIdentifier:@"MainImageCell"];
}

- (void)loadData {
    switch (self.type) {
        case PhotoTypeLocal:
            self.dataArray = @[@"localImage0.jpeg",
                               @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1524118803027&di=beab81af52d767ebf74b03610508eb36&imgtype=0&src=http%3A%2F%2Fe.hiphotos.baidu.com%2Fbaike%2Fpic%2Fitem%2F2e2eb9389b504fc2995aaaa1efdde71190ef6d08.jpg",
                               @"video0.MP4",
                               @"https://aweme.snssdk.com/aweme/v1/playwm/?video_id=v0200ff00000bdkpfpdd2r6fb5kf6m50&line=0.MP4",
                               @"localGifImage0.gif",
                               @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1524118772581&di=29b994a8fcaaf72498454e6d207bc29a&imgtype=0&src=http%3A%2F%2Fimglf2.ph.126.net%2F_s_WfySuHWpGNA10-LrKEQ%3D%3D%2F1616792266326335483.gif",
                               @"localBigImage0.jpeg",
                               @"localLongImage0.jpeg"];
            break;
        case PhotoTypeNet:
            self.dataArray = @[@"http://img4.duitang.com/uploads/item/201601/15/20160115231312_TWuG5.gif",
                               @"http://c.hiphotos.baidu.com/baike/pic/item/d1a20cf431adcbefd4018f2ea1af2edda3cc9fe5.jpg",
                               @"http://img3.duitang.com/uploads/item/201605/28/20160528202026_BvuWP.jpeg",
                               @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1524118823131&di=aa588a997ac0599df4e87ae39ebc7406&imgtype=0&src=http%3A%2F%2Fimg3.duitang.com%2Fuploads%2Fitem%2F201605%2F08%2F20160508154653_AQavc.png",
                               @"https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=722693321,3238602439&fm=27&gp=0.jpg",
                               @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1524118892596&di=5e8f287b5c62ca0c813a548246faf148&imgtype=0&src=http%3A%2F%2Fwx1.sinaimg.cn%2Fcrop.0.0.1080.606.1000%2F8d7ad99bly1fcte4d1a8kj20u00u0gnb.jpg",
                               @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1524118914981&di=7fa3504d8767ab709c4fb519ad67cf09&imgtype=0&src=http%3A%2F%2Fimg5.duitang.com%2Fuploads%2Fitem%2F201410%2F05%2F20141005221124_awAhx.jpeg",
                               @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1524118934390&di=fbb86678336593d38c78878bc33d90c3&imgtype=0&src=http%3A%2F%2Fi2.hdslb.com%2Fbfs%2Farchive%2Fe90aa49ddb2fa345fa588cf098baf7b3d0e27553.jpg",
                               @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1524118984884&di=7c73ddf9d321ef94a19567337628580b&imgtype=0&src=http%3A%2F%2Fimg5q.duitang.com%2Fuploads%2Fitem%2F201506%2F07%2F20150607185100_XQvYT.jpeg"];
            break;
            
        case PhotoTypeAsset:
            self.dataArray = [self.class getPHAssets];
            break;
            
            
        default:
            break;
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MainImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MainImageCell" forIndexPath:indexPath];
    cell.data = self.dataArray[indexPath.row];
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.type) {
        case PhotoTypeNet:{
            NSMutableArray *browserDataArr = [NSMutableArray array];
            [self.dataArray enumerateObjectsUsingBlock:^(NSString *_Nonnull urlStr, NSUInteger idx, BOOL * _Nonnull stop) {
                
                CZYImageBrowseCellData *data = [CZYImageBrowseCellData new];
                data.url = [NSURL URLWithString:urlStr];
                data.sourceObject = [self sourceObjAtIdx:idx];
                [browserDataArr addObject:data];
            }];
            
            CZYImageBrowser *browser = [CZYImageBrowser new];
            browser.dataSourceArray = browserDataArr;
            browser.currentIndex = indexPath.row;
            [browser show];
        }
            break;
        case PhotoTypeAsset:{
            CZYImageBrowser *browser = [CZYImageBrowser new];
            browser.dataSource = self;
            browser.currentIndex = indexPath.row;
            browser.autoHideSourceObject = NO;
            [browser show];
        }
            break;
            
            
        case PhotoTypeLocal:{
            [self showBrowserForMixedCaseWithIndex:indexPath.row];
        }
            break;
            
        default:
            break;
    }
   
}

#pragma mark - Show 'CZYImageBrowser' : Mixed case

- (void)showBrowserForMixedCaseWithIndex:(NSInteger)index {
    
    NSMutableArray *browserDataArr = [NSMutableArray array];
    [self.dataArray enumerateObjectsUsingBlock:^(NSString *_Nonnull imageStr, NSUInteger idx, BOOL * _Nonnull stop) {
        
        // 此处只是为了判断测试用例的数据源是否为视频，并不是仅支持 MP4。/ This is just to determine whether the data source of the test case is video, not just MP4.
        if ([imageStr hasSuffix:@".MP4"]) {
            if ([imageStr hasPrefix:@"http"]) {
                
                // Type 1 : 网络视频 / Network video
                CZYVideoBrowseCellData *data = [CZYVideoBrowseCellData new];
                data.url = [NSURL URLWithString:imageStr];
                data.sourceObject = [self sourceObjAtIdx:idx];
                [browserDataArr addObject:data];
                
            } else {
                
                // Type 2 : 本地视频 / Local video
                NSString *path = [[NSBundle mainBundle] pathForResource:imageStr.stringByDeletingPathExtension ofType:imageStr.pathExtension];
                NSURL *url = [NSURL fileURLWithPath:path];
                CZYVideoBrowseCellData *data = [CZYVideoBrowseCellData new];
                data.url = url;
                data.sourceObject = [self sourceObjAtIdx:idx];
                [browserDataArr addObject:data];
                
            }
        } else if ([imageStr hasPrefix:@"http"]) {
            
            // Type 3 : 网络图片 / Network image
            CZYImageBrowseCellData *data = [CZYImageBrowseCellData new];
            data.url = [NSURL URLWithString:imageStr];
            data.sourceObject = [self sourceObjAtIdx:idx];
            [browserDataArr addObject:data];
            
        } else {
            
            // Type 4 : 本地图片 / Local image (配置本地图片推荐使用 CZYImage)
            CZYImageBrowseCellData *data = [CZYImageBrowseCellData new];
            data.imageBlock = ^__kindof UIImage * _Nullable{
                return [CZYImage imageNamed:imageStr];
            };
            data.sourceObject = [self sourceObjAtIdx:idx];
            [browserDataArr addObject:data];
            
        }
    }];
    
    //Type 5 : 自定义 / Custom
    CustomCellData *data = [CustomCellData new];
    data.text = @"Custom Cell";
    [browserDataArr addObject:data];
    
    
    CZYImageBrowser *browser = [CZYImageBrowser new];
    browser.dataSourceArray = browserDataArr;
    browser.currentIndex = index;
    [browser show];
}

- (NSUInteger)czy_numberOfCellForImageBrowserView:(CZYImageBrowserView *)imageBrowserView {
    return self.dataArray.count;
}

- (id<CZYImageBrowserCellDataProtocol>)czy_imageBrowserView:(CZYImageBrowserView *)imageBrowserView dataForCellAtIndex:(NSUInteger)index {
    PHAsset *asset = (PHAsset *)self.dataArray[index];
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        
        // Type 1 : 系统相册的视频 / Video of system album
        CZYVideoBrowseCellData *data = [CZYVideoBrowseCellData new];
        data.phAsset = asset;
        data.sourceObject = [self sourceObjAtIdx:index];;
        
        return data;
    } else if (asset.mediaType == PHAssetMediaTypeImage) {
        
        // Type 2 : 系统相册的图片 / Image of system album
        CZYImageBrowseCellData *data = [CZYImageBrowseCellData new];
        data.phAsset = asset;
        data.sourceObject = [self sourceObjAtIdx:index];
        
        return data;
    }
    return nil;
}

- (id)sourceObjAtIdx:(NSInteger)idx {
    MainImageCell *cell = (MainImageCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
    return cell ? cell.mainImageView : nil;
}

#pragma mark - Photo

+ (NSArray *)getPHAssets {
    NSMutableArray *resultArray = [NSMutableArray array];
    PHFetchResult *smartAlbumsFetchResult0 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [smartAlbumsFetchResult0 enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PHAssetCollection  *_Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<PHAsset *> *assets = [self getAssetsInAssetCollection:collection];
        [resultArray addObjectsFromArray:assets];
    }];
    
    PHFetchResult *smartAlbumsFetchResult1 = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:nil];
    [smartAlbumsFetchResult1 enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
        NSArray<PHAsset *> *assets = [self getAssetsInAssetCollection:collection];
        [resultArray addObjectsFromArray:assets];
    }];
    
    return resultArray;
}

+ (NSArray *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection {
    NSMutableArray<PHAsset *> *arr = [NSMutableArray array];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    [result enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PHAsset *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.mediaType == PHAssetMediaTypeImage) {
            [arr addObject:obj];
        } else if (obj.mediaType == PHAssetMediaTypeVideo) {
            [arr addObject:obj];
        }
    }];
    return arr;
}

@end
