//
//  FUBeautyController.m
//  FULiveDemo
//
//  Created by 孙慕 on 2019/1/28.
//  Copyright © 2019年 FaceUnity. All rights reserved.
//

#import "FUBeautyController.h"
#import "FUAPIDemoBar.h"
#import "FUManager.h"
#import <Masonry.h>
#import "FUSelectedImageController.h"
#import "SVProgressHUD.h"
#import "FUMakeupSupModel.h"

@interface FUBeautyController ()<FUAPIDemoBarDelegate>

@property (strong, nonatomic) FUAPIDemoBar *demoBar;
/* 比对按钮 */
@property (strong, nonatomic) UIButton *compBtn;
@end

@implementation FUBeautyController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* 在基类控制器中，已经加载了美颜 */
   // [[FUManager shareManager] loadFilter];

    [self setupView];

    self.headButtonView.selectedImageBtn.hidden = NO;
    [self.view bringSubviewToFront:self.photoBtn];

}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [_demoBar reloadShapView:[FUManager shareManager].shapeParams];
    [_demoBar reloadSkinView:[FUManager shareManager].skinParams];
    [_demoBar reloadFilterView:[FUManager shareManager].filters];
    
    [_demoBar setDefaultFilter:[FUManager shareManager].seletedFliter];
    
    dispatch_async([FUManager shareManager].asyncLoadQueue, ^{
        int handle = [[FUManager shareManager] getHandleAboutType:FUNamaHandleTypeBeauty];
        /* 单独美颜点位点位*/
        [FURenderer itemSetParam:handle withName:@"landmarks_type" value:@(FUAITYPE_FACELANDMARKS75)];
    });

}

-(void)setupView{
    _demoBar = [[FUAPIDemoBar alloc] init];
    _demoBar.mDelegate = self;
    [self.view insertSubview:_demoBar atIndex:1];
    
    [_demoBar mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.view.mas_bottom);
        }
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(231);
    }];
    
    /* 比对按钮 */
    _compBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_compBtn setImage:[UIImage imageNamed:@"demo_icon_contrast"] forState:UIControlStateNormal];
    [_compBtn addTarget:self action:@selector(TouchDown) forControlEvents:UIControlEventTouchDown];
    [_compBtn addTarget:self action:@selector(TouchUp) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    _compBtn.hidden = YES;
    [self.view addSubview:_compBtn];
    if (iPhoneXStyle) {
        _compBtn.frame = CGRectMake(15 , self.view.frame.size.height - 70 - 182 - 34, 44, 44);
    }else{
        _compBtn.frame = CGRectMake(15 , self.view.frame.size.height - 70 - 182, 44, 44);
    }
}



-(void)setOrientation:(int)orientation{
    [super setOrientation:orientation];
    fuSetDefaultRotationMode(orientation);

}

#pragma  mark -  按钮点击
-(void)didClickSelPhoto{
    FUSelectedImageController *vc = [[FUSelectedImageController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)TouchDown{
    self.openComp = YES;
}

- (void)TouchUp{
    self.openComp = NO;
}

#pragma mark -  FUAPIDemoBarDelegate

-(void)restDefaultValue:(int)type{
    if (type == 1) {//美肤
       [[FUManager shareManager] setBeautyDefaultParameters:FUBeautyModuleTypeSkin];
    }
    
    if (type == 2) {
       [[FUManager shareManager] setBeautyDefaultParameters:FUBeautyModuleTypeShape];
    }
    
}

-(void)showTopView:(BOOL)shown{
    [self setPhotoScaleWithHeight:self.demoBar.frame.size.height show:shown];
}

-(void)filterShowMessage:(NSString *)message{
    self.tipLabel.hidden = NO;
    self.tipLabel.text = message;
    [FUBeautyController cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissTipLabel) object:nil];
    [self performSelector:@selector(dismissTipLabel) withObject:nil afterDelay:1 ];
}

-(void)filterValueChange:(FUBeautyParam *)param{
    int handle = [[FUManager shareManager] getHandleAboutType:FUNamaHandleTypeBeauty];
    [FURenderer itemSetParam:handle withName:@"filter_name" value:[param.mParam lowercaseString]];
    [FURenderer itemSetParam:handle withName:@"filter_level" value:@(param.mValue)]; //滤镜程度
    
    [FUManager shareManager].seletedFliter = param;
}

-(void)beautyParamValueChange:(FUBeautyParam *)param{
    if ([param.mParam isEqualToString:@"cheek_narrow"] || [param.mParam isEqualToString:@"cheek_small"]){//程度值 只去一半
        [[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty name:param.mParam value:param.mValue * 0.5];
    }else if([param.mParam isEqualToString:@"blur_level"]) {//磨皮 0~6
        [[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty name:param.mParam value:param.mValue * 6];
    }else{
        [[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty name:param.mParam value:param.mValue];
    }
}


- (void)setPhotoScaleWithHeight:(CGFloat)height show:(BOOL)shown {
    
    if (shown) {
        _compBtn.hidden = NO;
        CGAffineTransform photoTransform0 = CGAffineTransformMakeTranslation(0, height * -0.7) ;
        CGAffineTransform photoTransform1 = CGAffineTransformMakeScale(0.9, 0.9);
        
        [UIView animateWithDuration:0.35 animations:^{
            
            self.photoBtn.transform = CGAffineTransformConcat(photoTransform0, photoTransform1) ;
        }];
    } else {
        _compBtn.hidden = YES;
        [UIView animateWithDuration:0.35 animations:^{
            
            self.photoBtn.transform = CGAffineTransformIdentity ;
        }];
    }
}

- (void)dismissTipLabel{
    self.tipLabel.hidden = YES;
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
     [self.demoBar hiddenTopViewWithAnimation:YES];
}


@end
