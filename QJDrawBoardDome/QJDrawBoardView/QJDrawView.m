//
//  QJDrawView.m
//  QJDrawBoardDome
//
//  Created by 瞿杰 on 2019/9/9.
//  Copyright © 2019 yiniu. All rights reserved.
//

#import "QJDrawView.h"
#import "QJBezierPath.h"
#import "QJImage.h"

@interface QJDrawView ()

// 存入 UIBezierPath 或 UIImage 对象
@property (nonatomic , strong) NSMutableArray *_Nonnull paths ;
// 橡皮檫状态
@property (nonatomic , assign) BOOL isEraseState ;

// 是否是截图
@property (nonatomic , assign) BOOL isScreenshot ;
// 截取的图样式
@property (nonatomic , assign) QJScreenshotImageStyle imageStyle ;
// 截图的矩形 view
@property (nonatomic , strong) UIView * screenshotRactView;

@end

@implementation QJDrawView

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self setUp];
}
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}
-(void)setUp
{
    [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)]];
    self.curLineColor = [UIColor blackColor];
    self.curLineWidth = 1.0 ;
    
    /*
    // 颜色渐变层
    CAGradientLayer * layer = [CAGradientLayer layer];
    layer.colors = @[(id)[UIColor redColor].CGColor ,(id)[UIColor blueColor].CGColor, (id)[UIColor blackColor].CGColor , (id)[UIColor yellowColor].CGColor];
    layer.locations = @[@0.2 , @0.4 ,@0.8];
    layer.type = kCAGradientLayerConic ;
    layer.frame = self.layer.bounds;
    [self.layer addSublayer:layer];
    
    // 复制图层
    CAReplicatorLayer * repLayer = [CAReplicatorLayer layer];
    repLayer.frame = self.layer.bounds;
    repLayer.backgroundColor = [UIColor blueColor].CGColor;
    repLayer.opacity = 0.6;
    repLayer.instanceCount = 2 ;
    repLayer.instanceColor = [UIColor redColor].CGColor;
    repLayer.anchorPoint = CGPointMake(0.5, 1);
    repLayer.position = CGPointMake(repLayer.bounds.size.width / 2.0, repLayer.bounds.size.height);
    repLayer.instanceTransform = CATransform3DMakeRotation(M_PI, 1, 0, 0);
    repLayer.instanceRedOffset -= 0.2;
    repLayer.instanceGreenOffset -= 0.2;
    repLayer.instanceBlueOffset -= 0.2;
    repLayer.instanceAlphaOffset -= 0.1;
    [self.layer addSublayer:repLayer];
    
    // 需要复制的子图层
    CALayer * subLayer = [CALayer layer];
    subLayer.frame = CGRectMake(50, 100, 40, 100);
    subLayer.backgroundColor = [UIColor grayColor].CGColor;
    subLayer.anchorPoint = CGPointMake(0.5, 1);
    subLayer.position = CGPointMake(50, 100);
    subLayer.repeatCount = 3;
    [repLayer addSublayer:subLayer];
    */
}
-(void)pan:(UIPanGestureRecognizer *)pan
{
//    NSLog(@"{%lf,%lf}",point.x , point.y);
    if (self.isScreenshot) {
        CGPoint point = [pan locationInView:self.window];

        static CGPoint startPoint_screen , startPoint_self;
        if (pan.state == UIGestureRecognizerStateBegan) {
            self.screenshotRactView.frame = CGRectMake(point.x, point.y, 0, 0);
            startPoint_screen = point ;
            startPoint_self = [pan locationInView:self];
        }
        else {
            
            self.screenshotRactView.frame = [self rectWithPoint1:startPoint_screen point2:point];
            
            if (pan.state == UIGestureRecognizerStateEnded) {
                [self.paths removeAllObjects];
                
                // self 上的点
                CGRect screenshotRact = [self rectWithPoint1:startPoint_self point2:[pan locationInView:self]] ;
                QJImage * newImage = nil;
                // 根据所需样式 截图
                if (self.imageStyle == QJScreenshotImageStyleRect) {
                    newImage = [QJImage imageScreenshotWithView:self atRect:screenshotRact];
                }
                else{
                    newImage = [QJImage imageOvalScreenshotWithView:self atRect:screenshotRact];
                }
                // 添加并渲染
                if (newImage) {
                    [self.paths addObject:newImage];
                    [self drawImage:newImage];
                }
                
                //恢复数据
                self.isScreenshot = NO ;
                [self.screenshotRactView removeFromSuperview];
                self.screenshotRactView.frame = CGRectZero;
            }
        }
    }
    else{
        CGPoint point = [pan locationInView:self];

        if (pan.state == UIGestureRecognizerStateBegan) {
            QJBezierPath * path = [QJBezierPath bezierPath];
            [path setLineJoinStyle:kCGLineJoinRound];
            [path setLineCapStyle:kCGLineCapRound];
            if (self.isEraseState) {
                [path setLineWidth:10];
                path.color = self.backgroundColor ;
            }
            else{
                [path setLineWidth:self.curLineWidth];
                path.color = self.curLineColor ;
            }
            [path moveToPoint:point];
            [self.paths addObject:path];
        }
        else if (pan.state == UIGestureRecognizerStateChanged){
            QJBezierPath * path = [self.paths lastObject];
            [path addLineToPoint:point];
        }
        [self setNeedsDisplay];
    }
}
-(CGRect)rectWithPoint1:(CGPoint)point1 point2:(CGPoint)point2
{
    CGFloat x = point1.x ;
    CGFloat y = point1.y ;
    CGFloat width = point2.x - x ;
    CGFloat heigth = point2.y - y ;
    if (width < 0) {
        width = -width;
        CGFloat t = x ; x = point2.x ; point2.x = t ;
    }
    if (heigth < 0) {
        heigth = -heigth ;
        CGFloat t = y ; y = point2.y ; point2.y = t ;
    }
    
    return CGRectMake(x, y, width, heigth);
}

-(void)drawImage:(UIImage *)image
{
    self.isEraseState = NO ;
    if (image.size.width) {
        [self.paths addObject:image];
        [self setNeedsDisplay];
    }
}

// 系统调用，内部自动关联一个上下文
- (void)drawRect:(CGRect)rect {
    // Drawing code
    for (id path in self.paths) {
        if ([path isKindOfClass:[QJBezierPath class]]) {
            QJBezierPath * curPath = (QJBezierPath *)path;
            [curPath.color set];
            [curPath stroke];
        }
        else if ([path isKindOfClass:[QJImage class]]){
            QJImage * image = (QJImage *)path ;
            [image drawInRect:image.drawInRect];
        }
        else if ([path isKindOfClass:[UIImage class]]){
            UIImage * image = (UIImage *)path ;
            [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        }
    }
}

#pragma make - 操作
// 清屏
- (void)clearAll{
    self.isEraseState = NO ;
    self.isScreenshot = NO ;
    self.paths = nil ;
    [self setNeedsDisplay];
}
// 撤销
- (void)repeal {
    self.isEraseState = NO ;
    self.isScreenshot = NO ;
    [self.paths removeLastObject];
    [self setNeedsDisplay];
}
// 橡皮擦
- (void)erase {
    self.isEraseState = YES ;
    self.isScreenshot = NO ;
}

// 截图
-(void)screenshotWithImageStyle:(QJScreenshotImageStyle)imageStyle
{
    self.imageStyle = imageStyle ;
    self.isEraseState = NO ;
    self.isScreenshot = YES ;
    [self.window addSubview:self.screenshotRactView];
}

// 把画板截个图保存到相册
- (void)save {
    self.isEraseState = NO ;
    self.isScreenshot = NO ;

    // opaque : 不透明
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext() ;
    [self.layer renderInContext:contextRef];
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 转成PNG格式
    newImage = [UIImage imageWithData:UIImagePNGRepresentation(newImage)];
    
    UIGraphicsEndImageContext();
    
    // 把画板截个图保存到相册
    UIImageWriteToSavedPhotosAlbum(newImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);

}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
        NSLog(@"已经保存到相册中了");
    }
    else{
        NSLog(@"保存到相册失败");
    }
}

#pragma make - getter
-(NSMutableArray *)paths
{
    if (!_paths) {
        _paths = [NSMutableArray array];
    }
    return _paths ;
}
- (UIView *)screenshotRactView
{
    if (!_screenshotRactView) {
        _screenshotRactView = [[UIView alloc] init];
        _screenshotRactView.backgroundColor = [UIColor blackColor];
        _screenshotRactView.alpha = 0.2 ;
    }
    return _screenshotRactView ;
}
-(void)setCurLineWidth:(CGFloat)curLineWidth
{
    _curLineWidth = curLineWidth ;
    self.isEraseState = NO ;
    self.isScreenshot = NO ;

}
-(void)setCurLineColor:(UIColor *)curLineColor
{
    _curLineColor = curLineColor ;
    self.isEraseState = NO ;
    self.isScreenshot = NO ;

}

@end
