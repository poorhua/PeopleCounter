//
//  ACAlbumViewController.m
//  PeopleCounter
//
//  Created by Air_chen on 16/8/21.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "ACAlbumViewController.h"
#import "GlobalHeader.h"
#import <Photos/Photos.h>
#import "ACPhotoViewController.h"

#define ITEM_WID ([UIScreen mainScreen].bounds.size.width - 50)/4.0

@interface ACAlbumViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, readwrite, strong) NSMutableArray *imgArray;

@end

@implementation ACAlbumViewController

#pragma mark - lazyload
- (NSMutableArray *)imgArray
{
    if (_imgArray == nil) {
        _imgArray = [NSMutableArray array];
    }
    return _imgArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

//    设置标题
    UILabel *label = [[UILabel alloc] init];
    label.text = @"相册";
    //    自动设置了尺寸
    [label sizeToFit];
    label.textColor = [UIColor orangeColor];
    self.navigationItem.titleView = label;
    
//    遍历相册
    [self seekPhotosInfo];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor orangeColor];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionViewDataDelegate
//@required

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return [self.imgArray count];
//    return 30;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UICollectionViewCell alloc] init];
    }
    cell.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:self.imgArray[indexPath.row]];
    [imgView setContentMode:UIViewContentModeScaleAspectFill];
    imgView.frame = CGRectMake(0, 0, ITEM_WID, 100);
    imgView.clipsToBounds = YES;
    
    [cell addSubview:imgView];
    
    return cell;
}
//@optional

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"touch %ld %ld",(long)indexPath.section,(long)indexPath.row);
    
    ACPhotoViewController *photoVc = [[ACPhotoViewController alloc] initWithNibName:@"ACPhotoViewController" bundle:nil];
    [photoVc setImg:self.imgArray[indexPath.row]];
    
    [self.navigationController pushViewController:photoVc animated:YES];
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"complete!!");
}

// support for custom transition layout
//- (nonnull UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout;

#pragma mark - UICollectionViewFlowrLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(ITEM_WID, 100);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)seekPhotosInfo
{
    // 判断授权状态
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusDenied) {
            //如果授权被关闭，打开设置。
            NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:settingURL])
            {
                [[UIApplication sharedApplication] openURL:settingURL];
            }
        }
        if (status != PHAuthorizationStatusAuthorized) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 遍历所有的自定义相册
            PHFetchResult<PHAssetCollection *> *collectionResult0 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
            for (PHAssetCollection *collection in collectionResult0) {
                [self searchAllImagesInCollection:collection];
            }
            
            // 获得相机胶卷的图片
            PHFetchResult<PHAssetCollection *> *collectionResult1 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
            for (PHAssetCollection *collection in collectionResult1) {
                if (![collection.localizedTitle isEqualToString:@"Camera Roll"]) continue;
                [self searchAllImagesInCollection:collection];
                break;
            }
        });
    }];
}

/**
 * 查询某个相册里面的所有图片
 */
- (void)searchAllImagesInCollection:(PHAssetCollection *)collection
{
    // 采取同步获取图片（只获得一次图片）
    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
    imageOptions.synchronous = YES;
    
    NSLog(@"相册名字：%@", collection.localizedTitle);
    
    if ([collection.localizedTitle isEqualToString:photoAlblum]) {
        // 遍历这个相册中的所有图片
        PHFetchResult<PHAsset *> *assetResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        for (PHAsset *asset in assetResult) {
            // 过滤非图片
            if (asset.mediaType != PHAssetMediaTypeImage) continue;
            
            // 图片原尺寸
            CGSize targetSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
            // 请求图片
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeDefault options:imageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                NSLog(@"图片：%@ %@", result, [NSThread currentThread]);
                [self.imgArray addObject:result];
            }];
            
            [self.collectionView reloadData];
        }
    }
}
@end
