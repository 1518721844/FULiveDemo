//
//  FUExpressionCell.h
//  FULiveDemo
//
//  Created by 孙慕 on 2018/12/24.
//  Copyright © 2018年 FaceUnity. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FUExpressionCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *topImage;

@property (strong, nonatomic) UILabel *botlabel;

@property (assign, nonatomic) BOOL isSel;
@end

NS_ASSUME_NONNULL_END
