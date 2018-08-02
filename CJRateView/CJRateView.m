//
//  CJRateView.m
//  CJModule
//
//  Created by 仁和Mac on 2017/8/1.
//  Copyright © 2017年 zhucj. All rights reserved.
//

#import "CJRateView.h"

@interface _CJContentMarkImageLayer: CALayer

@property(nonatomic, strong) UIImage *markImage;

@property(nonatomic, assign) NSUInteger count;

@property(nonatomic, assign) CGFloat space;

@property(nonatomic, assign) CGSize markSize;

@end

@implementation _CJContentMarkImageLayer


-(void)drawInContext:(CGContextRef)ctx {
    [super drawInContext:ctx];
    
    CGContextMoveToPoint(ctx, 0, 0);
    CGContextAddRect(ctx, self.bounds);
    CGContextSetFillColorWithColor(ctx, self.backgroundColor);
    CGContextFillPath(ctx);
    CGContextTranslateCTM(ctx, 0, CGRectGetHeight(self.frame));
    CGContextScaleCTM(ctx, 1.f, -1.f);
    for (NSUInteger i = 0; i < _count; i++) {
        CGRect currentRect = (CGRect){CGPointMake(i*(_markSize.width + _space),0),_markSize};
        CGContextDrawImage(ctx, currentRect, _markImage.CGImage);
    }

}


@end

@interface _CJContentMarkImageView: UIView

@property(nonatomic, strong) UIImage *markImage;

@property(nonatomic, assign) NSUInteger count;

@property(nonatomic, assign) CGFloat space;

@property(nonatomic, assign) CGSize markSize;


-(instancetype)initWithMarkImage:(UIImage *)image count:(NSUInteger)count space:(CGFloat)space markSize:(CGSize)markSize;

@end

@implementation _CJContentMarkImageView

+(Class)layerClass {
    return [_CJContentMarkImageLayer class];
}

-(instancetype)initWithMarkImage:(UIImage *)image count:(NSUInteger)count space:(CGFloat)space markSize:(CGSize)markSize {
    self = [super init];
    if (self) {
        self.markImage = image;
        self.count = count;
        self.space = space;
        self.markSize = markSize;
    }
    return self;
}



-(void)layoutSubviews {
    [super layoutSubviews];
    [self.layer setNeedsDisplay];
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsLayout];
}

-(void)setMarkImage:(UIImage *)markImage {
    _markImage = markImage;
    _CJContentMarkImageLayer *layer = (_CJContentMarkImageLayer *)self.layer;
    layer.markImage = markImage;
}

-(void)setCount:(NSUInteger)count {
    _count = count;
    _CJContentMarkImageLayer *layer = (_CJContentMarkImageLayer *)self.layer;
    layer.count = count;
}

-(void)setSpace:(CGFloat)space  {
    _space = space;
    _CJContentMarkImageLayer *layer = (_CJContentMarkImageLayer *)self.layer;
    layer.space = space;
}

-(void)setMarkSize:(CGSize)markSize {
    _markSize = markSize;
    _CJContentMarkImageLayer *layer = (_CJContentMarkImageLayer *)self.layer;
    layer.markSize = markSize;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
    _CJContentMarkImageLayer *layer = (_CJContentMarkImageLayer *)self.layer;
    layer.backgroundColor = backgroundColor.CGColor;
}

@end

@interface CJRateView ()


@property(nonatomic, weak) _CJContentMarkImageView *contentMarkImageV;
@property(nonatomic, weak) _CJContentMarkImageView *contentBackMarkImageV;

@property(nonatomic, strong) CAShapeLayer *maskLayer;

@end

@implementation CJRateView

-(instancetype)initWithFrame:(CGRect)frame {
    self  = [super initWithFrame:frame];
    if (self) {
        [self didInitialize];
        [self didInititializeSubViews];
    }
    return self;
}


-(void)didInitialize {
    self.markCount   = 5;
    self.currentRate = 0;
    self.spaces    = 10.f;
    
    NSString *bundlePath = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"CJRateView.bundle/mark_star"];
    self.markImage = [UIImage imageWithContentsOfFile:bundlePath];
    self.rateChangeType = CJRateChangeTypeHalfMarkImage;
}

-(void)didInititializeSubViews {
    _CJContentMarkImageView *contentMarkImageV = [[_CJContentMarkImageView alloc] initWithMarkImage:_markImage count:_markCount space:_spaces markSize:_markSize];
    [self addSubview:contentMarkImageV];
    self.contentMarkImageV = contentMarkImageV;
    
    UIImage *markBackIamge = [self generateMarkBackImageWithImage:_markImage];
    _CJContentMarkImageView *contentMarkBackImageV = [[_CJContentMarkImageView alloc] initWithMarkImage:markBackIamge count:_markCount space:_spaces markSize:_markSize];
    [self insertSubview:contentMarkBackImageV belowSubview:contentMarkImageV];
    self.contentBackMarkImageV = contentMarkBackImageV;
    
    _maskLayer = [CAShapeLayer layer];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, (_markSize.width + _spaces) * _markCount - _spaces, _markSize.height);
    self.contentBackMarkImageV.frame = self.bounds;
    self.contentMarkImageV.frame = self.bounds;
}

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    return [self continueTrackingWithTouch:touch withEvent:event];
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
   
    CGPoint touchPoint = [touch locationInView:touch.view];
    CGFloat rateTemp = [self calculateCurrentRateFromeTouchPoint:touchPoint.x];
    switch (_rateChangeType) {
        case CJRateChangeTypeWholeMarkImage:
        {
            rateTemp = ceilf(rateTemp);
        }
            break;
        case CJRateChangeTypeHalfMarkImage:
        {
            CGFloat pointOfRateTemp = rateTemp - floor(rateTemp);
            if (pointOfRateTemp >= 0.5) {
                rateTemp = floorf(rateTemp) + 1.f;
            }else {
                rateTemp = floorf(rateTemp) + 0.5;
            }
        }
            break;
        default:
            break;
    }
    
    self.currentRate = rateTemp;
    if (touchPoint.x > floorf(rateTemp)*(_markSize.width + _spaces) - _spaces && touchPoint.x < floorf(rateTemp)*(_markSize.width + _spaces)) {
        return YES;
    }
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, floor(_currentRate) * _spaces + _currentRate * _markSize.width, CGRectGetHeight(self.bounds))];
    _maskLayer.path = path.CGPath;
    self.contentMarkImageV.layer.mask = _maskLayer;
    return YES;
}


-(CGFloat)calculateCurrentRateFromeTouchPoint:(CGFloat)touchX {
    NSInteger markIndex = floorf((touchX + _spaces) / (_markSize.width + _spaces));
    if (markIndex * (_markSize.width + _spaces) >= touchX) {
        return markIndex;
    }else {
        CGFloat markRemainder = touchX - (markIndex * (_markSize.width + _spaces));
        return markIndex + markRemainder / _markSize.width;
    }
}


-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(self.bounds, point)) {
        return self;
    }
    return [super hitTest:point withEvent:event];
}

-(CGSize)intrinsicContentSize {
    return self.bounds.size;
}

-(UIImage *)generateMarkBackImageWithImage:(UIImage *)markImage {
    CGRect imageRect = (CGRect){CGPointZero,markImage.size};
    UIGraphicsBeginImageContextWithOptions(markImage.size, NO, markImage.scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, 0, markImage.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    CGContextClipToMask(ctx, imageRect, markImage.CGImage);
    CGContextSetFillColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
    CGContextFillRect(ctx, imageRect);
    UIImage *generateImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return generateImage;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.contentMarkImageV.backgroundColor = backgroundColor;
    self.contentBackMarkImageV.backgroundColor = backgroundColor;
}

-(void)setMarkImage:(UIImage *)markImage {
    _markImage = markImage;
    self.contentMarkImageV.markImage = markImage;
    self.contentBackMarkImageV.markImage = [self generateMarkBackImageWithImage:_markImage];
    self.markSize  = markImage.size;
}

-(void)setMarkCount:(NSUInteger)markCount {
    _markCount = markCount;
    self.contentBackMarkImageV.count = markCount;
    self.contentMarkImageV.count = markCount;
    [self setNeedsLayout];
}

-(void)setSpaces:(CGFloat)spaces {
    _spaces = spaces;
    self.contentMarkImageV.space = spaces;
    self.contentBackMarkImageV.space = spaces;
    [self setNeedsLayout];
}

-(void)setMarkSize:(CGSize)markSize {
    _markSize = markSize;
    self.contentMarkImageV.markSize = markSize;
    self.contentBackMarkImageV.markSize = markSize;
    [self setNeedsLayout];
}

-(void)setCurrentRate:(CGFloat)currentRate {
    if (currentRate < 0) {
        currentRate = 0;
    }
    if (currentRate > _markCount) {
        currentRate = _markCount;
    }
    _currentRate = currentRate;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
