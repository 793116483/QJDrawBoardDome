//
//  QJImage.h
//  QJDrawBoardDome
//
//  Created by 瞿杰 on 2019/10/13.
//  Copyright © 2019 yiniu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QJImage : UIImage

@property (nonatomic , assign) CGRect drawInRect ;
-(instancetype)initWithCGImage:(CGImageRef)imageRef drawInRect:(CGRect)drawInRect ;
+(instancetype)imageWithCGImage:(CGImageRef)imageRef drawInRect:(CGRect)drawInRect ;

// 在view上剪取 rect区域大小的 图
+(instancetype)imageScreenshotWithView:(UIView *)view atRect:(CGRect)rect ;
// 剪取一个椭圆形图在view的rect区域内
+(instancetype)imageOvalScreenshotWithView:(UIView *)view atRect:(CGRect)rect ;

@end

NS_ASSUME_NONNULL_END
