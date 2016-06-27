//
//  PlotViewModel.m
//  PeopleCounter
//
//  Created by Air_chen on 16/6/27.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "PlotViewModel.h"
#import "CellDatas.h"

@interface PlotViewModel()
@property(nonatomic,strong) CPTXYGraph *graph;
@property(nonatomic,strong) NSMutableArray *dataForPlot;
@property(nonatomic,strong) NSMutableArray<CellDatas *> *datasArray;
@end

@implementation PlotViewModel

-(CPTXYGraph *)createGraphWith:(NSMutableArray<CellDatas *> *)array
{
    _graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTSlateTheme];
    [_graph applyTheme:theme];
    
    _graph.paddingBottom = _graph.paddingTop = PADDINGLENTH;
    _graph.paddingLeft = _graph.paddingRight = PADDINGLENTH;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)_graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@-0.5 length:@5];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@-1 length:@10.5];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)_graph.axisSet;
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.miterLimit = 1.0f;
    lineStyle.lineWidth = 2.0;
    lineStyle.lineColor = [CPTColor whiteColor];
    
    CPTXYAxis * x = axisSet.xAxis;
    x.orthogonalPosition = @0.0; // 原点的 x 位置
    x.majorIntervalLength = @0.5;   // x轴主刻度：显示数字标签的量度间隔
    x.minorTicksPerInterval = 2;    // x轴细分刻度：每一个主刻度范围内显示细分刻度的个数
    x.minorTickLineStyle = lineStyle;
    x.delegate = self;
    
    CPTXYAxis * y = axisSet.yAxis;
    y.orthogonalPosition = @0; // 原点的 y 位置
    y.majorIntervalLength = @0.5;   // y轴主刻度：显示数字标签的量度间隔
    y.minorTicksPerInterval = 4;    // y轴细分刻度：每一个主刻度范围内显示细分刻度的个数
    y.minorTickLineStyle = lineStyle;
    
    // Create a red-blue plot area
    //
    lineStyle.miterLimit        = 1.0f;
    lineStyle.lineWidth         = 3.0f;
    lineStyle.lineColor         = [CPTColor blueColor];
    
    CPTScatterPlot * boundLinePlot  = [[CPTScatterPlot alloc] init];
    boundLinePlot.dataLineStyle = lineStyle;
    boundLinePlot.dataSource    = self;
    
    // Add plot symbols: 表示数值的符号的形状
    //
    CPTMutableLineStyle * symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor blackColor];
    symbolLineStyle.lineWidth = 1.0;
    
    CPTPlotSymbol * plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill          = [CPTFill fillWithColor:[CPTColor orangeColor]];
    plotSymbol.lineStyle     = symbolLineStyle;
    plotSymbol.size          = CGSizeMake(5.0, 10.0);
    boundLinePlot.plotSymbol = plotSymbol;
    
    [_graph addPlot:boundLinePlot];
    
    _datasArray = array;
    
    NSInteger count = [_datasArray count];
    _dataForPlot = [NSMutableArray arrayWithCapacity:count];
    NSUInteger i;
    for ( i = 0; i < count; i++ ) {
        id x = [NSNumber numberWithFloat:i];
        id y = @([_datasArray[i].recogNumsStr integerValue]);
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
    
    return NO;
}

@end
