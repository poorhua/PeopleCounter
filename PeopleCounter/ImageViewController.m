//
//  ImageViewController.m
//  PeopleCounter
//
//  Created by Air_chen on 16/6/20.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "ImageViewController.h"
#import "ImageViewModel.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "UIAlertController+Blocks.h"

@interface ImageViewController()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, readwrite, strong) ImageViewModel *imageVM;
@property (nonatomic, readwrite, strong) UIImage *currentImg;

@end

@implementation ImageViewController

- (ImageViewModel *)imageVM
{
    if (_imageVM == nil) {
        _imageVM = [[ImageViewModel alloc] init];
    }
    
    return _imageVM;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageVM.scrollView = self.scrollView;
    self.imageVM.view = self.view;
    
     RACSignal *sig = [self.imageVM.imageLoadCommand execute:nil];
    
    [sig subscribeNext:^(UIImage* x) {
        self.currentImg = x;
    }];
}

- (void)setUuid:(NSString *)str
{
    self.imageVM.uuid = str;
}

- (IBAction)shareAction:(id)sender {
//    [UMSocialData defaultData].extConfig.title = @"分享的title";
////    [UMSocialData defaultData].extConfig.qqData.url = @"http://baidu.com";
//    [UMSocialData defaultData].extConfig.renrenData.url = @"http://baidu.com";
//    [UMSocialData defaultData].extConfig.facebookData.url = @"http://baidu.com";
//    [UMSocialData defaultData].extConfig.wechatFavoriteData.url = @"http://baidu.com";
//    [UMSocialData defaultData].extConfig.wechatTimelineData.url = @"http://baidu.com";

//    [UMSocialSnsService presentSnsIconSheetView:self
//                                         appKey:UMAPP_KEY
//                                      shareText:@"友盟社会化分享让您快速实现分享等社会化功能，http://umeng.com/social"
//                                     shareImage: [UIImage imageNamed:@"icon"]
//                                shareToSnsNames:@[UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToQQ,UMShareToQzone]
//                                       delegate:self];
    
    [UIAlertController showActionSheetInViewController:self withTitle:@"提示" message:@"确定将图片保存到本地相册？" cancelButtonTitle:@"确定" destructiveButtonTitle:nil otherButtonTitles:nil popoverPresentationControllerBlock:^(UIPopoverPresentationController * _Nonnull popover) {
        
    } tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
        if (buttonIndex == controller.cancelButtonIndex) {
            [self savePhotoToPhone];
        }
    }];
}

- (void)savePhotoToPhone
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
            NSError *error = nil;
            
            // 保存相片到相机胶卷
            __block PHObjectPlaceholder *createdAsset = nil;
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                createdAsset = [PHAssetCreationRequest creationRequestForAssetFromImage:self.currentImg].placeholderForCreatedAsset;
            } error:&error];
            
            if (error) {
                NSString *picSaveStr = [NSString stringWithFormat:@"保存失败：%@", error];
                [UIAlertController showAlertInViewController:self withTitle:@"提示" message:picSaveStr cancelButtonTitle:@"确定" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                    if (buttonIndex == controller.cancelButtonIndex) {
                        return;
                    }
                }];
            }
            
            // 拿到自定义的相册对象
            PHAssetCollection *collection = [self collection];
            if (collection == nil) return;
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection] insertAssets:@[createdAsset] atIndexes:[NSIndexSet indexSetWithIndex:0]];
            } error:&error];
            
            NSString *personalSaveStr = nil;
            if (error) {
                personalSaveStr = [NSString stringWithFormat:@"保存失败：%@", error];
            } else {
                personalSaveStr = @"保存成功";
            }
            
            [UIAlertController showAlertInViewController:self withTitle:@"提示" message:personalSaveStr cancelButtonTitle:@"确定" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                
            }];
        });
    }];
}

/**
 * 获得自定义的相册对象
 */
- (PHAssetCollection *)collection
{
    // 先从已存在相册中找到自定义相册对象
    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:photoAlblum]) {
            return collection;
        }
    }
    
    // 新建自定义相册
    __block NSString *collectionId = nil;
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:photoAlblum].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    
    if (error) {
        NSLog(@"获取相册【%@】失败", photoAlblum);
        return nil;
    }
    
    
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].lastObject;
}

@end
