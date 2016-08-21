//
//  GlobalHeader.h
//  PeopleCounter
//
//  Created by Air_chen on 16/6/20.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "ReactiveCocoa.h"
#import "NSURLConnection+RACSupport.h"
#import "MBProgressHUD.h"
#import "CorePlot.h"
#import "UMSocial.h"

//#define TRUEDATE
#define PADDINGLENTH 2
#define APIKEY @"BMoXY9INkS=l0Iiow=Zo4bqjqLE= "

#define UMAPP_KEY @"57b8fb3c67e58eed8b0025c4"

#define PHOTO_ALBLUM @"远程监测客户端-Photos"

#define ACAPP_NAME @"远程监测客户端"

#ifndef GlobalHeader_h
#define GlobalHeader_h


#endif /* GlobalHeader_h */

typedef NS_ENUM(NSInteger, ACSeekType) {
    SeekHuman,
    SeekAir,
    SeekTemp
};