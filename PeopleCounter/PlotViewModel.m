//
//  PlotViewModel.m
//  PeopleCounter
//
//  Created by Air_chen on 16/6/27.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "PlotViewModel.h"
#import "PlotDatas.h"

@interface PlotViewModel()
@property(nonatomic,strong) CPTXYGraph *graph;
@property(nonatomic,strong) NSMutableArray *dataForPlot;
@property(nonatomic,strong) NSMutableArray<PlotDatas *> *datasArray;
@property(nonatomic,assign) ACSeekType style;

@property(nonatomic,strong) CPTXYAxis *yAxis;
@property(nonatomic,strong) CPTXYAxis *xAxis;
@end

@implementation PlotViewModel

-(CPTXYGraph *)createGraphWith:(NSMutableArray<PlotDatas *> *)array inStyle:(ACSeekType)style
{
    _style = style;
    
    /*
     extern NSString *__nonnull const kCPTDarkGradientTheme; ///< A graph theme with dark gray gradient backgrounds and light gray lines.
     extern NSString *__nonnull const kCPTPlainBlackTheme;   ///< A graph theme with black backgrounds and white lines.
     extern NSString *__nonnull const kCPTPlainWhiteTheme;   ///< A graph theme with white backgrounds and black lines.
     extern NSString *__nonnull const kCPTSlateTheme;        ///< A graph theme with colors that match the default iPhone navigation bar, toolbar buttons, and table views.
     extern NSString *__nonnull const kCPTStocksTheme;       ///< A graph theme with a gradient background and white lines.
     /// @}
     */
//    处理数组获得数据最大最小值
    NSInteger count = [array count];
    NSInteger max = [array[0].nums integerValue];
    NSInteger min = max;
    
    for (PlotDatas *plotdata in array) {
        NSInteger num = [plotdata.nums integerValue];
        if (num > max) {
            max = num;
        }
        if (num < min) {
            min = num;
        }
    }
    
    _graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTSlateTheme];
    [_graph applyTheme:theme];
    
    _graph.paddingBottom = _graph.paddingTop = PADDINGLENTH;
    _graph.paddingLeft = _graph.paddingRight = PADDINGLENTH;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)_graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@-3 length:@(count)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(min - 2) length:@(max - min + 4)];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)_graph.axisSet;
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.miterLimit = 1.0f;
    lineStyle.lineWidth = 0.5;
    lineStyle.lineColor = [CPTColor whiteColor];
    
    CPTXYAxis * x = axisSet.xAxis;
    x.orthogonalPosition = @(min - 1.5); // 原点的 x 位置
    x.majorIntervalLength = @5;   // x轴主刻度：显示数字标签的量度间隔
    x.minorTicksPerInterval = 5;    // x轴细分刻度：每一个主刻度范围内显示细分刻度的个数
    x.minorTickLineStyle = lineStyle;
    x.delegate = self;
    _xAxis = x;
    
    CPTXYAxis * y = axisSet.yAxis;
    y.orthogonalPosition = @(0); // 原点的 y 位置
    y.majorIntervalLength = @(1);   // y轴主刻度：显示数字标签的量度间隔
    y.minorTicksPerInterval = 1;    // y轴细分刻度：每一个主刻度范围内显示细分刻度的个数
    y.minorTickLineStyle = lineStyle;
    y.delegate = self;
    _yAxis = y;
    
    // Create a red-blue plot area
    //
    lineStyle.miterLimit        = 1.0f;
    lineStyle.lineWidth         = 3.0f;
    lineStyle.lineColor         = [CPTColor orangeColor];
    
    CPTScatterPlot * boundLinePlot  = [[CPTScatterPlot alloc] init];
    boundLinePlot.dataLineStyle = lineStyle;
    boundLinePlot.dataSource    = self;
    
    // Add plot symbols: 表示数值的符号的形状
    //
    CPTMutableLineStyle * symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor blackColor];
    symbolLineStyle.lineWidth = 1.0;
    
//    CPTPlotSymbol * plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
//    plotSymbol.fill          = [CPTFill fillWithColor:[CPTColor orangeColor]];
//    plotSymbol.lineStyle     = symbolLineStyle;
//    plotSymbol.size          = CGSizeMake(5.0, 10.0);
//    boundLinePlot.plotSymbol = plotSymbol;
    
    [_graph addPlot:boundLinePlot];
    
    _datasArray = array;

    _dataForPlot = [NSMutableArray arrayWithCapacity:count];
    NSUInteger i;
    for ( i = 0; i < count; i++ ) {
        id x = [NSNumber numberWithFloat:i];
        id y = @([_datasArray[i].nums integerValue]);
        [_dataForPlot addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", nil]];
    }
    
    return _graph;
}

#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [_dataForPlot count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSString * key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
    NSNumber * num = [[_dataForPlot objectAtIndex:index] valueForKey:key];
    
    return num;
}

#pragma mark Axis Delegate Methods
-(BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
{
    CGFloat labelOffset             = axis.labelOffset;
    NSMutableSet * newLabels        = [NSMutableSet set];
    if ([_xAxis isEqual: axis]) {
        for (NSDecimalNumber * tickLocation in locations) {
            NSString * labelString      = [axis.labelFormatter stringForObjectValue:tickLocation];
            NSInteger index = [labelString integerValue];
            
            if (index < [_datasArray count]) {
                NSRange range;
                range.location = 11;
                range.length = 5;
                CPTTextLayer * newLabelLayer= [[CPTTextLayer alloc] initWithText:[_datasArray[index].dateTimeStr substringWithRange:range] style:[axis.labelTextStyle mutableCopy]];
                
                CPTAxisLabel * newLabel     = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
                newLabel.tickLocation       = tickLocation;
                newLabel.offset             = labelOffset;
                
                [newLabels addObject:newLabel];
            }
        }
        
        axis.axisLabels = newLabels;
    }else{
        for (NSDecimalNumber * tickLocation in locations) {
            NSString * labelString      = [axis.labelFormatter stringForObjectValue:tickLocation];
            NSRange range;
            range.location = 0;
            if ([labelString length] <= 3) {
                range.length = 1;
            }else
                range.length = 2;
            
            NSString *labelStr;
            switch (_style) {
                case SeekAir:
                    if ([labelString isEqualToString:@"1.0"]) {
                        labelStr = @"AAAA";
                    }
                    if ([labelString isEqualToString:@"2.0"]) {
                        labelStr = @"AAA";
                    }
                    if ([labelString isEqualToString:@"3.0"]) {
                        labelStr = @"AA";
                    }
                    if ([labelString isEqualToString:@"4.0"]) {
                        labelStr = @"A";
                    }
                    break;
                case SeekHuman:
                    labelStr = [NSString stringWithFormat:@"％%@",[labelString substringWithRange:range]];
                    break;
                case SeekTemp:
                    labelStr = [NSString stringWithFormat:@"%@℃",[labelString substringWithRange:range]];
                    break;
            }
            
            CPTTextLayer * newLabelLayer= [[CPTTextLayer alloc] initWithText:labelStr style:[axis.labelTextStyle mutableCopy]];
            CPTAxisLabel * newLabel     = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
            newLabel.tickLocation       = tickLocation;
            newLabel.offset             = labelOffset;
            [newLabels addObject:newLabel];
        }
        
        axis.axisLabels = newLabels;
    }
    
    
    
    return NO;
}

@end
