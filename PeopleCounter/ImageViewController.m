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

@interface ImageViewController()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong) ImageViewModel *imageVM;

@property(nonatomic,strong) UIImage *currentImg;
@end

@implementation ImageViewController

-(ImageViewModel *)imageVM
{
    if (_imageVM == nil) {
        _imageVM = [[ImageViewModel alloc] init];
    }
    
    return _imageVM;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageVM.scrollView = self.scrollView;
    self.imageVM.view = self.view;
    
     RACSignal *sig = [self.imageVM.imageLoadCommand execute:nil];
    
    [sig subscribeNext:^(UIImage* x) {
        self.currentImg = x;
    }];
}

-(void)setUuid:(NSString *)str
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
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:@"确定将图片保存到本地相册？"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self savePhotoToPhone];
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)savePhotoToPhone
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
                NSLog(@"保存失败：%@", error);
                return;
            }
            
            // 拿到自定义的相册对象
            PHAssetCollection *collection = [self collection];
            if (collection == nil) return;
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection] insertAssets:@[createdAsset] atIndexes:[NSIndexSet indexSetWithIndex:0]];
            } error:&error];
            
            if (error) {
                NSLog(@"保存失败：%@", error);
            } else {
                NSLog(@"保存成功");
            }
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
        if ([collection.localizedTitle isEqualToString:PHOTO_ALBLUM]) {
            return collection;
        }
    }
    
    // 新建自定义相册
    __block NSString *collectionId = nil;
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:PHOTO_ALBLUM].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    
    if (error) {
        NSLog(@"获取相册【%@】失败", PHOTO_ALBLUM);
        return nil;
    }
    
    
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].lastObject;
}


-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}

@end
