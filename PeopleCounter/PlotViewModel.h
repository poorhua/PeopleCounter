//
//  PlotViewModel.h
//  PeopleCounter
//
//  Created by Air_chen on 16/6/27.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalHeader.h"

@class CellDatas;

@interface PlotViewModel : NSObject<CPTAxisDelegate,CPTPlotDataSource>

-(CPTXYGraph *)createGraphWith:(NSMutableArray<CellDatas *> *)array;

@end
