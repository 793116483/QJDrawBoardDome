//
//  QJDrawView.h
//  QJDrawBoardDome
//
//  Created by 瞿杰 on 2019/9/9.
//  Copyright © 2019 yiniu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 截图的样式 枚举
typedef NS_ENUM(NSInteger , QJScreenshotImageStyle){
    QJScreenshotImageStyleRect , // 矩形样式图
    QJScreenshotImageStyleOval , // 椭圆形样式图
};

@interface QJDrawView : UIView

@property (nonatomic , assign) CGFloat curLineWidth ;
@property (nonatomic , strong) UIColor * curLineColor ;

// 渲染图片
- (void)drawImage:(UIImage *)image;

// 清屏
- (void)clearAll ;
// 撤销
- (void)repeal ;
// 橡皮擦
- (void)erase ;

// 把画板截个图，重新显示在画板上
-(void)screenshotWithImageStyle:(QJScreenshotImageStyle)imageStyle;

// 把画板保存到相册
- (void)save ;

@end

NS_ASSUME_NONNULL_END
