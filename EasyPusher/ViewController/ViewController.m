//
//  ViewController.m
//  EasyCapture
//
//  Created by phylony on 9/11/16.
//  Copyright © 2016 phylony. All rights reserved.
//

#import "ViewController.h"
#import "PureLayout.h"
#import "EasySetingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "EasyResolutionViewController.h"
#import "EasyDarwinInfoViewController.h"
#import <CoreTelephony/CTCellularData.h>
#import "NoNetNotifieViewController.h"

@interface ViewController ()<EasyResolutionDelegate, ConnectDelegate> {
    UIButton *startButton;
    UIButton *settingButton;
    
    NSString *urlName;
    NSString *statusString;
}

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *prev;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    encoder = [[CameraEncoder alloc] init];
    encoder.delegate = self;
    [encoder initCameraWithOutputSize:CGSizeMake(480, 640)];
    
    encoder.previewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:encoder.previewLayer];
    
    self.prev = encoder.previewLayer;
    [[self.prev connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
    self.prev.frame = self.view.bounds;
    
    encoder.previewLayer.hidden = NO;
    [encoder startCapture];
    
    startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    startButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:startButton];
    [startButton setTitle:@"开始推流" forState:UIControlStateNormal];
    [startButton autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:20.0];
    [startButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0];
    [startButton autoSetDimension:ALDimensionWidth toSize:80];
    [startButton autoSetDimension:ALDimensionHeight toSize:40];
    startButton.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    [startButton addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
    
    settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:settingButton];
    [settingButton setTitle:@"设置" forState:UIControlStateNormal];
    [settingButton autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:startButton withOffset:5.0];
    [settingButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0];
    [settingButton autoSetDimension:ALDimensionWidth toSize:80];
    [settingButton autoSetDimension:ALDimensionHeight toSize:40];
    settingButton.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    [settingButton addTarget:self action:@selector(settingAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    changeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:changeButton];
    [changeButton setTitle:@"切换" forState:UIControlStateNormal];
//    [changeButton setImage:[UIImage imageNamed:@"switch_camera"] forState:UIControlStateNormal];
    [changeButton autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:settingButton withOffset:5.0];
    [changeButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0];
    [changeButton autoSetDimension:ALDimensionWidth toSize:80];
    [changeButton autoSetDimension:ALDimensionHeight toSize:40];
    changeButton.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    [changeButton addTarget:self action:@selector(toggleCamera) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *resolutionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    resolutionBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:resolutionBtn];
    resolutionBtn.tag = 100001;
    [resolutionBtn setTitle:@"分辨率:640*480" forState:UIControlStateNormal];
    [resolutionBtn autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];
    [resolutionBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20.0];
    [resolutionBtn autoSetDimension:ALDimensionWidth toSize:180];
    [resolutionBtn autoSetDimension:ALDimensionHeight toSize:30];
//    resolutionBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    [resolutionBtn addTarget:self action:@selector(showPop) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    infoBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:infoBtn];
    [infoBtn setImage:[UIImage imageNamed:@"ic_action_about"] forState:UIControlStateNormal];
    [infoBtn autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:20];
    [infoBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20.0];
    [infoBtn autoSetDimension:ALDimensionWidth toSize:30];
    [infoBtn autoSetDimension:ALDimensionHeight toSize:30];
    [infoBtn addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *landBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    landBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [landBtn setTitle:@"竖屏" forState:UIControlStateNormal];
    [landBtn addTarget:self action:@selector(landScreen:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:landBtn];
    [landBtn autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:70];
    [landBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20.0];
    [landBtn autoSetDimension:ALDimensionWidth toSize:80];
    [landBtn autoSetDimension:ALDimensionHeight toSize:30];
    
    UILabel *urlLabel = [[UILabel alloc] init];
    urlLabel.translatesAutoresizingMaskIntoConstraints = NO;
    urlLabel.tag = 3000;
    urlLabel.textColor = [UIColor redColor];
    urlLabel.numberOfLines = 0;
    urlLabel.text = statusString;
    [self.view addSubview:urlLabel];
    
    [urlLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:startButton withOffset:-10.0];
    [urlLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:20.0];
    [urlLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:20.0];
    [self getPushName];
}

- (void)getPushName {
    NSString *pushName = [[NSUserDefaults standardUserDefaults] objectForKey:@"PushName"];
    if (!pushName) {
        NSMutableString *randomNum = [[NSMutableString alloc] init];
        for(int i = 0; i < 6;i++){
            int num = arc4random() % 10;
            [randomNum appendString:[NSString stringWithFormat:@"%d",num]];
        }
        [randomNum appendString:@".sdp"];
        [[NSUserDefaults standardUserDefaults] setObject:randomNum forKey:@"PushName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)showAuthorityView {
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NoNetNotifieViewController *vc = [[NoNetNotifieViewController alloc] init];
            [weakSelf presentViewController:vc animated:YES completion:nil];
        });
    });
}

#pragma mark - click event

- (void)showInfo {
    EasyDarwinInfoViewController *infoVc = [[EasyDarwinInfoViewController alloc] init];
    [self presentViewController:infoVc animated:YES completion:nil];
}

// 横竖屏切换
- (void) landScreen:(UIButton *)btn {
    // 竖屏->左横屏->右横屏
    NSString *title = btn.titleLabel.text;
    
    if ([title isEqualToString:@"竖屏"]) {
        [btn setTitle:@"左横屏" forState:UIControlStateNormal];
        
        // 左横屏
        [[self.prev connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
        encoder.videoConnection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    } else if ([title isEqualToString:@"左横屏"]) {
        [btn setTitle:@"右横屏" forState:UIControlStateNormal];
        
        // 右横屏
        [[self.prev connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
        encoder.videoConnection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    } else {
        [btn setTitle:@"竖屏" forState:UIControlStateNormal];
        
        // 竖屏
        [[self.prev connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
        encoder.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
}

- (void)showPop {
    if (encoder.running) {
        return;
    }
    
    EasyResolutionViewController *popVc = [[EasyResolutionViewController alloc] init];
    popVc.delegate = self;
    popVc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:popVc animated:YES completion:nil];
}

- (void)onSelecedesolution:(NSInteger)resolutionNo {
    [encoder swapResolution];
    UIButton *resolutionBtn = (UIButton *)[self.view viewWithTag:100001];
    [resolutionBtn setTitle:[NSString stringWithFormat:@"分辨率:%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"resolition"]] forState:UIControlStateNormal];
}

- (void)toggleCamera {
    [encoder swapFrontAndBackCameras];
}

- (IBAction)startAction:(id)sender {
    if (!encoder.running) {
        [startButton setTitle:@"停止推流" forState:UIControlStateNormal];
//        NSMutableString *randomNum = [[NSMutableString alloc] init];
//        for(int i = 0; i < 6;i++){
//            int num = arc4random() % 10;
//            [randomNum appendString:[NSString stringWithFormat:@"%d",num]];
//        }
//        [randomNum appendString:@".sdp"];
        urlName = [[NSUserDefaults standardUserDefaults] objectForKey:@"PushName"];
        [encoder startCamera:urlName];
    } else {
        [startButton setTitle:@"开始推流" forState:UIControlStateNormal];
        [encoder stopCamera];
    }
    
    __weak typeof(self)weakSelf = self;
    CTCellularData *cellularData = [[CTCellularData alloc]init];
    cellularData.cellularDataRestrictionDidUpdateNotifier =  ^(CTCellularDataRestrictedState state){
        //获取联网状态
        switch (state) {
            case kCTCellularDataRestricted:
//                NSLog(@"Restricrted");
//                [weakSelf showAuthorityView];
                break;
            case kCTCellularDataNotRestricted:
//                NSLog(@"Not Restricted");
                break;
            case kCTCellularDataRestrictedStateUnknown:
                [weakSelf showAuthorityView];
                break;
            default:
                break;
        };
    };

}

- (void)getConnectStatus:(NSString *)status isFist:(int)tag{
    __block UILabel *label = (UILabel *)[self.view viewWithTag:3000];
    if (tag == 1) {
        if (label) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    label.text = [NSString stringWithFormat:@"%@",status];
                });
            });
        }else{
            statusString = status;
        }
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                label.text = [NSString stringWithFormat:@"%@\nrtsp://%@:%@/%@",status,[[NSUserDefaults standardUserDefaults] objectForKey:@"ConfigIP"],[[NSUserDefaults standardUserDefaults] objectForKey:@"ConfigPORT"],urlName];
            });
        });
    }
}

- (IBAction)settingAction:(id)sender {
    [startButton setTitle:@"开始推流" forState:UIControlStateNormal];
    [encoder stopCamera];
    EasySetingViewController *setVc = [[EasySetingViewController alloc] init];
    [self presentViewController:setVc animated:YES completion:nil];
}

@end