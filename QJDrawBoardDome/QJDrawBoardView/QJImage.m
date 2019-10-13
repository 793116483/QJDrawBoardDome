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

@end
