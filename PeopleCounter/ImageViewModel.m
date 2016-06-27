//
//  ImageViewModel.m
//  PeopleCounter
//
//  Created by Air_chen on 16/6/21.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "ImageViewModel.h"

@interface ImageViewModel()

@property(nonatomic,strong) UIImage *image;

@end

@implementation ImageViewModel

-(instancetype)init
{
    if (self = [super init]) {
        [self bindEvents];
    }
    
    return self;
}

-(void)bindEvents
{
    _imageLoadCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        RACSignal *requestSig = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
           
            NSMutableURLRequest *request = [self makeUpURLConnection];
            
            [[NSURLConnection rac_sendAsynchronousRequest:request] subscribeNext:^(RACTuple* x) {
                RACTupleUnpack(NSHTTPURLResponse *response,NSData *data) = x;
                
                NSInteger statusCode = response.statusCode;
                
                UIImage *image = [UIImage imageWithData:data];
                
                _image = image;
                
                [subscriber sendNext:image];
                [subscriber sendCompleted];
            }];
            
            return nil;
        }];
        
        return requestSig;
    }];
    
    [[_imageLoadCommand.executing skip:1] subscribeNext:^(id x) {
        
        if ([x boolValue] == YES) {
            NSLog(@"loading!");
            MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hub.mode = MBProgressHUDModeIndeterminate;
            hub.labelText = @"loading...";
            /*
              Progress is shown using an UIActivityIndicatorView. This is the default.
            MBProgressHUDModeIndeterminate,
             Progress is shown using a round, pie-chart like, progress view.
            MBProgressHUDModeDeterminate,
             Progress is shown using a horizontal progress bar
            MBProgressHUDModeDeterminateHorizontalBar,
             Progress is shown using a ring-shaped progress view.
            MBProgressHUDModeAnnularDeterminate,
             Shows a custom view
            MBProgressHUDModeCustomView,
             Shows only labels
            MBProgressHUDModeText
             */
        }else
        {
            NSLog(@"done!");
            self.imageView.image = _image;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}

-(NSMutableURLRequest *) makeUpURLConnection
{
    NSString *str = [NSString stringWithFormat:@"http://api.heclouds.com/bindata/%@",self.uuid];
    NSLog(@"%@",str);
    str = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:str];
    NSLog(@"%@",url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:APIKEY forHTTPHeaderField:@"api-key"];
    
    return request;
}

@end
