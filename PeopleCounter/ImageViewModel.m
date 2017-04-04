//
//  ImageViewModel.m
//  PeopleCounter
//
//  Created by Air_chen on 16/6/21.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "ImageViewModel.h"
#import "UIImage+Bitmap.h"
#import "ACNetWorkManager.h"

@interface ImageViewModel()
@property(nonatomic,strong) UIImage *image;
@property(nonatomic,strong) UIImageView *imgView;
@end

@implementation ImageViewModel
CGFloat currentScale;

-(instancetype)init
{
    if (self = [super init]) {
        [self bindEvents];
    }
    
    return self;
}

-(void)bindEvents
{
    self.imageLoadCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        RACSignal *requestSig = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            //内存缓存 - 本地缓存 - 网络获取
            //set up cache
            static NSCache *cache = nil;
            if (!cache) {
                cache = [[NSCache alloc] init];
            }
            //if already cached, return immediately
            UIImage *image = [cache objectForKey:self.uuid];
            
            if (image) {
                self.image = image;
                [subscriber sendNext:self.image];
                [subscriber sendCompleted];
                
                return nil;
            }
            
            //set placeholder to avoid reloading image multiple times
            [cache setObject:[NSNull null] forKey:self.uuid];
            //switch to background thread
            //load image
            NSString *filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
            filePath = [filePath stringByAppendingPathComponent:self.uuid];
            __block NSData *imgData = [NSData dataWithContentsOfFile:filePath];
            
            void(^loadImageData)(NSData *) = ^(NSData *imgData) {
                UIImage *image = [UIImage imageWithData:imgData];
                [cache setObject:image forKey:self.uuid];

                //redraw image using device context
                UIGraphicsBeginImageContextWithOptions(image.size, YES, 0);
                [image drawAtPoint:CGPointZero];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                //set image for correct image view
                dispatch_async(dispatch_get_main_queue(), ^{ //cache the image
                    //display the image
                    self.image = image;
                    
                    UIImage *transImg = [cache objectForKey:self.uuid];
                    [subscriber sendNext:transImg];
                    [subscriber sendCompleted];
                });
            };
            
            if (!imgData) {
                [[ACNetWorkManager shareManager] getPicWithUuidStr:self.uuid thatResult:^(RACTuple *resData) {
                    RACTupleUnpack(NSHTTPURLResponse *response,NSData *data) = resData;
                    [data writeToFile:filePath atomically:YES];
                    loadImageData(data);
                }];
            }else{
                dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    loadImageData(imgData);
                });
            }

            return nil;
        }];
        
        return requestSig;
    }];
    
    [self loadProcess];
}

- (void)loadProcess{
    [[self.imageLoadCommand.executing skip:1] subscribeNext:^(id x) {
        
        if ([x boolValue] == YES) {
            NSLog(@"loading!");
            MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hub.mode = MBProgressHUDModeIndeterminate;
            hub.labelText = @"loading...";
        }else
        {
            NSLog(@"done!");
            
            //设置图片显示，Scrollview的代理
            self.imgView = [[UIImageView alloc] initWithImage:self.image];
            
            [self.scrollView addSubview:self.imgView];
            self.scrollView.delegate = self;
            
            CGFloat imgWid = self.imgView.image.size.width;
            CGFloat imgHei = self.imgView.image.size.height;
            CGFloat actrueWid = [UIScreen mainScreen].bounds.size.width;
            
            self.scrollView.contentSize = CGSizeMake(actrueWid,imgHei * actrueWid/imgWid);
            self.imgView.frame = CGRectMake(0,(self.imgView.bounds.size.height - self.scrollView.bounds.size.height+64)/2.0, actrueWid,imgHei * actrueWid/imgWid);
            
            self.scrollView.maximumZoomScale = 2.0;
            self.scrollView.minimumZoomScale = 1;
            
            [self rectangleImgView];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)rectangleImgView
{
    CGSize scrollSize = self.scrollView.bounds.size;
    CGSize imgSize = self.imgView.bounds.size;

    CGFloat horizenSpace = scrollSize.width > imgSize.width ? (scrollSize.width - imgSize.width)/2.0 : 0.0;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, horizenSpace, 0, horizenSpace);
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self rectangleImgView];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imgView;
}

@end
