//
//  QJImage.m
//  QJDrawBoardDome
//
//  Created by 瞿杰 on 2019/10/13.
//  Copyright © 2019 yiniu. All rights reserved.
//

#import "QJImage.h"


@implementation QJImage

-(CGRect)drawInRect
{
    if (!_drawInRect.size.width) {
        _drawInRect = CGRectMake(0, 0, self.size.width, self.size.height);
    }
    return _drawInRect ;
}
-(instancetype)initWithCGImage:(CGImageRef)imageRef drawInRect:(CGRect)drawInRect
{
    if (self = [super initWithCGImage:imageRef]) {
        self.drawInRect = drawInRect ;
    }
    return self;
}
+(instancetype)imageWithCGImage:(CGImageRef)imageRef drawInRect:(CGRect)drawInRect
{
    return [[self alloc] initWithCGImage:imageRef drawInRect:drawInRect];
}

// 在view上剪取 rect区域大小的 图
+(instancetype)imageScreenshotWithView:(UIView *)view atRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(view.bounds.size);

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, rect);

    image = [UIImage imageWithCGImage:subImageRef];
    
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    
    return [self imageWithCGImage:image.CGImage drawInRect:rect];
}
// 剪取一个圆形图在view的rect区域内
+(instancetype)imageOvalScreenshotWithView:(UIView *)view atRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(view.bounds.size);

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 先上下文裁剪
    UIBezierPath * bezerPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    [bezerPath addClip];
    // 后渲染
    [view.layer renderInContext:ctx];
    // 拿到图后，需要转一下，不然会有问题
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    image = [UIImage imageWithCGImage:subImageRef];

    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    
    return [self imageWithCGImage:image.CGImage drawInRect:rect];
}

@end
