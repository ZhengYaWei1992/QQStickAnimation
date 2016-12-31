//
//  ZWBadgeValue.m
//  QQStickinessAnim
//
//  Created by 郑亚伟 on 2016/12/27.
//  Copyright © 2016年 郑亚伟. All rights reserved.
//

#import "ZWBadgeValue.h"

@interface ZWBadgeValue ()
@property(nonatomic,strong)UIView *smallCircle;
//父视图
@property(nonatomic,strong) UIView *bageValueSuperView;
@property(nonatomic,strong) CAShapeLayer *shapeLayer;
@end

@implementation ZWBadgeValue

- (instancetype)initWithFrame:(CGRect)frame withSuperView:(UIView *)badgeSuperView{
    if (self == [super initWithFrame:frame]) {
        self.bageValueSuperView = badgeSuperView;
        [self setup];
    }
    return self;
}

- (void)setup{
    self.layer.cornerRadius = 10;
    self.clipsToBounds = YES;
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    [self setBackgroundColor:[UIColor redColor]];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //添加手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    //添加小圆
    UIView *smallCircle = [[UIView alloc]init];
    smallCircle.frame = self.frame;
    smallCircle.layer.cornerRadius = self.layer.cornerRadius;
    smallCircle.backgroundColor = [UIColor redColor];
    self.smallCircle = smallCircle;
    [self.bageValueSuperView insertSubview:self.smallCircle belowSubview:self];
}


- (void)pan:(UIPanGestureRecognizer *)pan{
    //当前移动的偏移量
    CGPoint tranP = [pan translationInView:self];
    //移动可以修改：frame或 center或 transform
    //移动是相对于上一次，所以要使用这个方法
    //这里的transform并没有修改center，修改的是frame,所以这里要用center设置.
    //self.transform = CGAffineTransformTranslate(self.transform, tranP.x, tranP.y);
    CGPoint center = self.center;
    center.x += tranP.x;
    center.y += tranP.y;
    self.center = center;
    /**************************************************/
    //复位操作
    [pan setTranslation:CGPointZero inView:self];
    
    
    CGFloat distance = [self distanceWithSmallCicle:self.smallCircle bigCircle:self];
    /******************设置小圆相关****************************/
    //设置小圆半径随着距离拉大而缩小
    CGFloat radius = self.bounds.size.width * 0.5;
    radius -= distance/10.0;
    //根据小圆半径，重新设置小圆的宽高 以及圆角
    self.smallCircle.bounds = CGRectMake(0, 0, radius * 2, radius * 2);
    self.smallCircle.layer.cornerRadius = radius;
    
    /*******************路径转为形状******************************/
    if (self.smallCircle.hidden == NO) {
        //返回一个不规则路径
        UIBezierPath *path = [self pathWithSmallCircle:self.smallCircle bigCircle:self];
        self.shapeLayer.path = path.CGPath;
        [self.bageValueSuperView.layer insertSublayer:_shapeLayer atIndex:0];
    }
    
    /**********************关键业务逻辑处理*****************************/
    //距离大于60处理
    if (distance > 60) {
        self.smallCircle.hidden = YES;
        [self.shapeLayer removeFromSuperlayer];
    }
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (distance < 60) {
            //拖动结束且距离小于60，显示小圆，移除shapeLayer
            self.center = self.smallCircle.center;
            self.smallCircle.hidden = NO;
            [self.shapeLayer removeFromSuperlayer];
        }else{
            //播放一个动画
            //动画没有什么资源，所以随便找了几张图片，原本是小圆💥动画
            UIImageView *imageV = [[UIImageView alloc]initWithFrame:self.bounds];
            NSMutableArray *imageArray = [NSMutableArray array];
            for (int i = 0 ; i < 3; i++) {
                UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",i + 1]];
                [imageArray addObject:image];
            }
            imageV.animationImages = imageArray;
            [imageV setAnimationDuration:1];
            [imageV startAnimating];
            [self addSubview:imageV];
            //消失
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removeFromSuperview];
            });
        }
    }
}

//计算两个圆的距离
- (CGFloat)distanceWithSmallCicle:(UIView *)smallCircle bigCircle:(UIView *)bigCircle{
    //勾股定理，计算圆心半径
    CGFloat offSetX = bigCircle.center.x - smallCircle.center.x;
    CGFloat offSetY = bigCircle.center.y - smallCircle.center.y;
    return sqrt(offSetX * offSetX  + offSetY * offSetY);
}

//根据两个圆描述一个不规则路径
- (UIBezierPath *)pathWithSmallCircle:(UIView *)smallCircle bigCircle:(UIView *)bigCircle{
    CGFloat x1 = smallCircle.center.x;
    CGFloat x2 = bigCircle.center.x;
    CGFloat y1 = smallCircle.center.y;
    CGFloat y2 = bigCircle.center.y;
    
    CGFloat d = [self distanceWithSmallCicle:smallCircle bigCircle:bigCircle];
    CGFloat cosΘ = (y2 - y1)/d;
    CGFloat sinΘ = (x2 - x1)/d;
    CGFloat r1 = smallCircle.bounds.size.width *0.5;
    CGFloat r2 = bigCircle.bounds.size.width *0.5;
    
    CGPoint pointA = CGPointMake(x1 - r1 * cosΘ, y1 + r1 * sinΘ);
    CGPoint pointB = CGPointMake(x1 + r1 * cosΘ, y1 - r1 * sinΘ);
    CGPoint pointC = CGPointMake(x2 + r2 * cosΘ, y2 - r2 * sinΘ);
    CGPoint pointD = CGPointMake(x2 - r2 * cosΘ, y2 + r2 * sinΘ);
    CGPoint pointO = CGPointMake(pointA.x + d * 0.5 *sinΘ, pointA.y + d *0.5 + cosΘ);
    CGPoint pointP = CGPointMake(pointB.x + d * 0.5 *sinΘ, pointB.y + d *0.5 + cosΘ);
    //描述路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    //AB
    [path moveToPoint:pointA];
    [path addLineToPoint:pointB];
    //BC  P为控制点
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    //CD
    [path addLineToPoint:pointD];
    //DA  O为控制点
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    return path;
}

- (CAShapeLayer *)shapeLayer{
    if (_shapeLayer == nil) {
        //把路径转换成图形  CAShapeLayer可以根据路径生成形状
        _shapeLayer = [CAShapeLayer layer];
        //设置形状的填充颜色
        _shapeLayer.fillColor = [UIColor redColor].CGColor;
        //*******************
        [self.bageValueSuperView.layer insertSublayer:_shapeLayer atIndex:0];
    }
    return _shapeLayer;
}

//设置高亮状态什么都不做
- (void)setHighlighted:(BOOL)highlighted{
    
}


@end
