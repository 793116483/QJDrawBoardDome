# QJDrawBoardDome
利用Quartz2D制作画板

![](/画板样图.png)

### Quartz2D 知识
- **实际上是在 图层 CALayer 上实现画图**
- 可以实现：画线、矩形、圆、椭圆、字符串、图片 等等
- 一个学习博客：https://blog.csdn.net/iteye_18480/article/details/82524981

- 实现四步,**在 - (void)drawRect 方法 or 开启后的图形上下文 中**：
    - 方式一：
        - **1. 获取图层上下文都是以 UIGraphics... 开头**
        ``` objc
        // 1. 获取图形上下文，自动与 view 邦定在一起，单独创建是没用的！
        CGContextRef context = UIGraphicsGetCurrentContext();
        ```
        - **2. 描述画图路径**
        ```objc
            // 2. 在创建的时候就可以定路径 +bezierPathWith....
            UIBezierPath* path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointZero];
            // 2.1 添加圆、线、弧、路径调用对象方法 -add...
            [path addLineToPoint:CGPointMake(100, 200)];
            // 2.2 设置一些装态 -set...
            [path setLineWidth:3];
            // 设置线条两端成 圆形
            [path setLineCapStyle:kCGLineCapRound];
            // 设置线与线连接处是圆形
            [path setLineJoinStyle:kCGLineJoinRound];
            //     设置颜色
            [[UIColor redColor] set];
            [path addClip];
        ```

        - **将. 图形描述路径添加到图形上下文**
        ```objc
        // 3. 把图形描述路径 添加到 图形上下文
        CGContextAddPath(context, path.CGPath);
        ```

        - **4.渲染图层**
        ```objc
        // 4. 渲染图层: stroke 描边方式 和 fill 填充方式
        //    CGContextFillPath(context) // 使用这个填充时，会自动把起点与终点联接形成一个封闭的图形
            CGContextStrokePath(context);
        ```

    - 方式二，**直接用 UIBezierPath 调用已经封装好的方式渲染**：
    ```objc
    // 2. 在创建的时候就可以定路径 +bezierPathWith....
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    // 2.1 添加圆、线、弧、路径调用对象方法 -add...
    [path addLineToPoint:CGPointMake(100, 200)];
    // 2.2 设置一些装态 -set...
    [path setLineWidth:3];
    // 设置线条两端成 圆形
    [path setLineCapStyle:kCGLineCapRound];
    // 设置线与线连接处是圆形
    [path setLineJoinStyle:kCGLineJoinRound];
    //     设置颜色
    [[UIColor redColor] set];
    // 超出的部分就裁剪掉
    [path addClip];

    // 直接渲染 , 在内部已经实现了 获取图形上下文，并渲染
    [path stroke]; // or  [path fill]
  ```

    - 方式三, 字符串 渲染到图形上下文
    ```objc
        // 把文字绘制到上下文，并渲染
    NSMutableDictionary * attributedDic = [NSMutableDictionary dictionary];
    attributedDic[NSFontAttributeName] = [UIFont systemFontOfSize:20];
    attributedDic[NSForegroundColorAttributeName] = [UIColor redColor];
    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor greenColor];
    shadow.shadowOffset = CGSizeMake(-10, 10);
    attributedDic[NSShadowAttributeName] = shadow;
    [@"我直接显示到 view 上，不使用Lable" drawInRect:CGRectMake(0, 0, 100, 100) withAttributes:attributedDic];
    ```

    - 方式四，图片image 渲染到图形上下文
    ```objc
        // 把图片添加到上下文，并渲染
    UIImage * image = [UIImage imageNamed:@"xxx"];
    // 图片有多大就按图片原来的比例显示，可能显示不全
    [image drawAtPoint:CGPointZero];
    // 图片填充整个矩形框内，可能比例会变形
    [image drawInRect:CGRectMake(0, 0, 200, 200)];
    //[image drawAsPatternInRect:<#(CGRect)#>]
    //[image drawInRect:<#(CGRect)#> blendMode:(CGBlendMode) alpha:<#(CGFloat)#>]
    //...

    ```

- 在图形上下文范围内 **清除指定矩形范围内的内容**
```objc
// 清除图形上下文设定位置矩形内的内容
CGContextClearRect(UIGraphicsGetCurrentContext(), CGRectMake(10, 10, 20, 20));
```

- **layer 图层内容 渲染到图形上下文中**
```objc
// 把 view 的内容渲染到 图形上下文
CGContextRef context_cur = UIGraphicsGetCurrentContext();
[view.layer renderInContext:context_cur];
```

- 开启图片的图形上下文
```objc
    // 1. 开启创建一个与 image 大小相同的 图形上下文
    // size : 开启g图形上下文的大小
    // opaque: 不透明
    // scale : 比例
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);

    ......
    // 2. 获取图形上下文 得到 新的 图片
    UIGraphicsGetImageFromCurrentImageContext()

    // 3. 关闭图形上下文, 如果没有关闭会占用资源
    UIGraphicsEndImageContext();
```



- 一个图片处理成圆形的显示例子（也可做成水印）
```objc
// 裁剪一个圆形图片
    UIImage * oldImage = [UIImage imageNamed:@"xxxx"];
    // 开启创建一个与 oldImage 大小相同的 图形上下文
    UIGraphicsBeginImageContextWithOptions(oldImage.size, NO, 0);
    // 描述圆形的路径，如果一个椭圆x和y半径一样就是一个圆
    UIBezierPath * circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, oldImage.size.width, oldImage.size.height)];
    [circlePath setLineWidth:10];
    [[UIColor redColor] set];
    // 会把图形上下文按照描述的路径裁剪掉
    [circlePath addClip];

    // 把图片绘制到图形上下文
    [oldImage drawAtPoint:CGPointZero];
    [@"xxxx" drawAtPoint:CGPointZero withAttributes:nil];

    // 获取新的 image
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();

    // 关闭图形上下文
    UIGraphicsEndImageContext() ;
```



- **图形上下文 平移、旋转 和 缩放**
```objc
    // 在添加到图形上下文之前，做 平移、缩放 和 旋转
    // 平移
    CGContextTranslateCTM(context, 100, 100);
    // 缩放,放大1.5倍
    CGContextScaleCTM(context, 1.5, 1.5);
    // 旋转
    CGContextRotateCTM(context, M_PI_4);

    // 3. 把图形描述路径 添加到 图形上下文
    CGContextAddPath(context, path.CGPath);
```

- **图形上下文状态栈**
    - 也就是说可以把设置的每一个状态可以深拷贝一份到 图形上下文栈顶。
    ```objc
    // 先把当前的图形上下文 "A"状态保存一份到 图形上下文状态栈 里面
        // A状态： lineWidth = 1 , color = 黑色
    CGContextSaveGState(context);
    ```

    - 从栈顶取出 A状态 ，恢复到 A状态 下的 context 图形上下文再进行 图形描述路径
    ```objc
    // 从栈顶取出A状y态，恢复原来的 A状态：lineWidth = 1 , color = 黑色
    CGContextRestoreGState(context);
    ```
