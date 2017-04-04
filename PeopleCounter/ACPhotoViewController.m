//
//  ACPhotoViewController.m
//  PeopleCounter
//
//  Created by Air_chen on 16/8/21.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "ACPhotoViewController.h"

@interface ACPhotoViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, readwrite, strong) UIImageView *imgView;

@end

@implementation ACPhotoViewController

#pragma mark - lazyload
- (UIImageView *)imgView
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        
    }
    return _imgView;
}

#pragma mark - openslots
- (void)setImg:(UIImage *)img
{
    self.imgView.image = img;
    // 更新 imageView 的大小时，imageView 可能已经被缩放过，所以要应用当前的缩放
    self.imgView.frame = CGRectApplyAffineTransform(CGRectMake(0, 0, img.size.width, img.size.height), self.imgView.transform);
}

#pragma mark - life methods
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    [self.imgView setContentMode:UIViewContentModeScaleAspectFit];
    
    self.scrollView.delegate = self;
    self.scrollView.bounces = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    self.scrollView.minimumZoomScale = 0;
    self.scrollView.maximumZoomScale = 2.0;
    
    [self.scrollView addSubview:self.imgView];
    
    if (CGRectIsEmpty(self.view.bounds)) {
        return;
    }
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGestureWithPoint:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTapGesture];
    
    self.scrollView.frame = self.view.bounds;
}

#pragma mark - gesture Events

- (void)handleDoubleTapGestureWithPoint:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint gesturePoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    
    // 如果图片被压缩了，则第一次放大到原图大小，第二次放大到最大倍数
    if (self.scrollView.zoomScale >= self.scrollView.maximumZoomScale) {
        [self setZoomScale:[self minimumZoomScale] animated:YES];
    } else {
        CGFloat newZoomScale = 0;
        if (self.scrollView.zoomScale < 1) {
            // 如果目前显示的大小比原图小，则放大到原图
            newZoomScale = 1;
        } else {
            // 如果当前显示原图，则放大到最大的大小
            newZoomScale = self.scrollView.maximumZoomScale;
        }
        
        CGRect zoomRect = CGRectZero;
        CGPoint tapPoint = [self.imgView convertPoint:gesturePoint fromView:gestureRecognizer.view];
        zoomRect.size.width = CGRectGetWidth(self.view.bounds) / newZoomScale;
        zoomRect.size.height = CGRectGetHeight(self.view.bounds) / newZoomScale;
        zoomRect.origin.x = tapPoint.x - CGRectGetWidth(zoomRect) / 2;
        zoomRect.origin.y = tapPoint.y - CGRectGetHeight(zoomRect) / 2;
        
        [self zoomToRect:zoomRect animated:YES];
    }
}

- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.scrollView zoomToRect:rect animated:NO];
        }];
    } else {
        [self.scrollView zoomToRect:rect animated:NO];
    }
}
#pragma mark - others
- (void)setContentMode:(UIViewContentMode)contentMode {
    BOOL isContentModeChanged = self.view.contentMode != contentMode;
    [self.view setContentMode:contentMode];
    if (isContentModeChanged) {
        [self revertZooming];
    }
}

- (void)revertZooming {
    if (CGRectIsEmpty(self.view.bounds)) {
        return;
    }
    
    CGFloat minimumZoomScale = [self minimumZoomScale];
    CGFloat maximumZoomScale = self.scrollView.maximumZoomScale;
    maximumZoomScale = fmaxf(minimumZoomScale, maximumZoomScale);// 可能外部通过 contentMode = UIViewContentModeScaleAspectFit 的方式来让小图片撑满当前的 zoomImageView，所以算出来 minimumZoomScale 会很大（至少比 maximumZoomScale 大），所以这里要做一个保护
    CGFloat zoomScale = minimumZoomScale;
    BOOL shouldFireDidZoomingManual = zoomScale == self.scrollView.zoomScale;
    self.scrollView.panGestureRecognizer.enabled = YES;
    self.scrollView.pinchGestureRecognizer.enabled = YES;
    self.scrollView.minimumZoomScale = minimumZoomScale;
    self.scrollView.maximumZoomScale = maximumZoomScale;
    [self setZoomScale:zoomScale animated:NO];
    
    // 只有前后的 zoomScale 不相等，才会触发 UIScrollViewDelegate scrollViewDidZoom:，因此对于相等的情况要自己手动触发
    if (shouldFireDidZoomingManual) {
        [self handleDidEndZooming];
    }
}

static inline BOOL CGSizeIsEmpty(CGSize size) {
    return size.width <= 0 || size.height <= 0;
}

- (void)handleDidEndZooming {
    UIView *imageView = self.imgView;
    CGRect imageViewFrame = [self.view convertRect:imageView.frame fromView:imageView.superview];
    CGSize viewportSize = self.view.bounds.size;
    UIEdgeInsets contentInset = UIEdgeInsetsZero;
    if (!CGRectIsEmpty(imageViewFrame) && !CGSizeIsEmpty(viewportSize)) {
        if (CGRectGetWidth(imageViewFrame) < viewportSize.width) {
            // 用 floorf 而不是 flatf，是因为 flatf 本质上是向上取整，会导致 left + right 比实际的大，然后 scrollView 就认为可滚动了
            contentInset.left = contentInset.right = floorf((viewportSize.width - CGRectGetWidth(imageViewFrame)) / 2.0);
        }
        if (CGRectGetHeight(imageViewFrame) < viewportSize.height) {
            // 用 floorf 而不是 flatf，是因为 flatf 本质上是向上取整，会导致 top + bottom 比实际的大，然后 scrollView 就认为可滚动了
            contentInset.top = contentInset.bottom = floorf((viewportSize.height - CGRectGetHeight(imageViewFrame)) / 2.0);
        }
    }
    self.scrollView.contentInset = contentInset;
    self.scrollView.contentSize = imageView.frame.size;
    
    if (self.scrollView.contentInset.top > 0) {
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, -self.scrollView.contentInset.top);
    }
    
    if (self.scrollView.contentInset.left > 0) {
        self.scrollView.contentOffset = CGPointMake(-self.scrollView.contentInset.left, self.scrollView.contentOffset.y);
    }
}

- (CGFloat)minimumZoomScale {
    CGRect viewport = self.view.bounds;
    if (CGRectIsEmpty(viewport) || !self.img) {
        return 1;
    }
    
    CGSize imageSize = self.img.size;
    
    CGFloat minScale = 1;
    CGFloat scaleX = CGRectGetWidth(viewport) / imageSize.width;
    CGFloat scaleY = CGRectGetHeight(viewport) / imageSize.height;
    if (self.view.contentMode == UIViewContentModeScaleAspectFit) {
        minScale = fminf(scaleX, scaleY);
    } else if (self.view.contentMode == UIViewContentModeScaleAspectFill) {
        minScale = fmaxf(scaleX, scaleY);
    } else if (self.view.contentMode == UIViewContentModeCenter) {
        if (scaleX >= 1 && scaleY >= 1) {
            minScale = 1;
        } else {
            minScale = fminf(scaleX, scaleY);
        }
    }
    return minScale;
}

- (void)setZoomScale:(CGFloat)zoomScale animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.scrollView.zoomScale = zoomScale;
        }];
    } else {
        self.scrollView.zoomScale = zoomScale;
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imgView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self handleDidEndZooming];
}

@end
