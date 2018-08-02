//
//  CJRateView.h
//  CJModule
//
//  Created by 仁和Mac on 2018/8/1.
//  Copyright © 2017年 zhucj. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 使用过程中，几个重要属性。
 1、markImage -- 默认小星星
 2、markCount -- 多少颗星星，默认5个。
 使用过程中可以不设置frame，会根据markImage（markSize）、markCount、space 来计算尺寸。
 
 */


typedef NS_ENUM(NSUInteger, CJRateChangeType) {
    CJRateChangeTypeWholeMarkImage,
    CJRateChangeTypeHalfMarkImage,
    CJRateChangeTypeBitMarkImage
};

@interface CJRateView : UIControl

/// markImage 默认是小星星
@property(nonatomic, strong) UIImage *markImage;

/// 每个小星星的尺寸，默认和markImage的size一样
@property(nonatomic, assign) CGSize markSize;

/// 小星星的个数，默认5.f
@property(nonatomic, assign) NSUInteger markCount;

/// 每个小星星的间隔，默认10.f
@property(nonatomic, assign) CGFloat spaces;

/// 当前的星级
@property(nonatomic, assign) CGFloat currentRate;

/// 当我们手指拖动的时候，等级变化的方式（1个markImage作为整体、0.5个markImage作为整体和其它）,默认是0.5个作为整体
@property(nonatomic, assign) CJRateChangeType rateChangeType;
@end
