//
//  LaunchAndSignupViewController.m
//  foundertimeIOS
//
//  Created by DavidLee on 15/9/18.
//  Copyright (c) 2015年 Benjamin Gordon. All rights reserved.
//

#import "LaunchAndSignupViewController.h"
#import <AVFoundation/AVFoundation.h>


/**
 *  键盘出现frameY的改变值
 */
#define CHANGE_FRAME_VALUE 60

/**
 *  初始的frameY值
 */
#define ORIGIN_FRAMW_Y 170

/**
 *  播放器的音量值
 */
#define VOLUME_OF_PLAYER 0

/**
 *  输入框和登陆，注册按钮的高度
 */
#define HEIGHT_OF_FIELD 40

@interface LaunchAndSignupViewController ()
/*** 视频播放器*/
@property(nonatomic,strong)AVPlayer *player;
/*** 播放视频的view*/
@property(nonatomic,strong)UIView *playerView;

/*** loginView覆盖在播放器上*/
@property(nonatomic,strong)UIView *loginView;
/*** 名字输入框*/
@property(nonatomic,strong)UITextField *nameField;
/*** 密码输入框*/
@property(nonatomic,strong) UITextField *passWordField;

/*** login按钮*/
@property(nonatomic,strong) UIButton *loginButton;
/*** signup按钮*/
@property(nonatomic,strong) UIButton *signupButton;


@end

@implementation LaunchAndSignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createVideoPlayer];
    
    [self createLoginView];
    
    [self createButtons];
    
    
    //两个监听键盘状态的通知中心
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    
}


/**
 *  创建VideoPlayer
 */
-(void)createVideoPlayer
{
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"welcome_video" ofType:@"mp4"];
    NSURL *pathUrl = [NSURL fileURLWithPath:videoPath];
    
    AVPlayerItem *videoItem = [[AVPlayerItem alloc] initWithURL:pathUrl];
    //[videoItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    self.player = [AVPlayer playerWithPlayerItem:videoItem];
    
    self.player.volume = VOLUME_OF_PLAYER;
    self.playerView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.playerView];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    playerLayer.videoGravity = UIViewContentModeScaleToFill;
    playerLayer.frame = self.playerView.bounds;
    [self.playerView.layer addSublayer:playerLayer];

    [self.player play];
    
    [self.player.currentItem addObserver:self forKeyPath:AVPlayerItemFailedToPlayToEndTimeNotification options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
    
}


/**
 *  创建loginView
 */
-(void)createLoginView
{
    self.loginView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.loginView.backgroundColor = [UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:0.3f];
    [self.view addSubview:self.loginView];
    
    UITextField *nameField = [[UITextField alloc] initWithFrame:CGRectMake(50, ORIGIN_FRAMW_Y, self.view.frame.size.width - 100, HEIGHT_OF_FIELD)];
    nameField.backgroundColor = [UIColor colorWithRed:0.81f green:0.91f blue:0.94f alpha:0.5f];
    [self.loginView addSubview:nameField];
    self.nameField = nameField;
    
    self.nameField.layer.cornerRadius = 8;
    self.nameField.borderStyle = 0;
    self.nameField.layer.borderColor = (__bridge CGColorRef)([UIColor cyanColor]);
    
    self.passWordField = [[UITextField alloc] initWithFrame:CGRectMake(50, ORIGIN_FRAMW_Y + 60, self.view.frame.size.width - 100, HEIGHT_OF_FIELD)];
    self.passWordField.backgroundColor = [UIColor colorWithRed:0.81f green:0.91f blue:0.94f alpha:0.5f];
    [self.loginView addSubview:self.passWordField];
    
    self.passWordField.layer.cornerRadius = 8;
    self.passWordField.borderStyle = 0;
    self.passWordField.layer.borderColor = (__bridge CGColorRef)([UIColor cyanColor]);
    
    
    self.passWordField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pw_icon"]];
    self.nameField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_icon"]];
    self.nameField.leftViewMode = UITextFieldViewModeAlways;
    self.passWordField.leftViewMode = UITextFieldViewModeAlways;
    self.passWordField.secureTextEntry = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstRe)];

    [self.loginView addGestureRecognizer:tap];
}

/**
 *  创建登录和注册按钮
 */
-(void)createButtons
{
    
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(50, ORIGIN_FRAMW_Y + 120, 100, HEIGHT_OF_FIELD)];
    loginButton.backgroundColor = [UIColor colorWithRed:0.81f green:0.91f blue:0.94f alpha:0.5f];
    [loginButton setTitle:@"注册" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor colorWithRed:0.46f green:0.46f blue:0.46f alpha:1.00f] forState:UIControlStateNormal];
    [self.loginView addSubview:loginButton];
    loginButton.layer.cornerRadius = 8;
    self.loginButton = loginButton;
    [loginButton addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *signupButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 150, ORIGIN_FRAMW_Y + 120, 100, HEIGHT_OF_FIELD)];
    signupButton.backgroundColor = [UIColor colorWithRed:0.81f green:0.91f blue:0.94f alpha:0.5f];
    [signupButton setTitle:@"登录" forState:UIControlStateNormal];
    [signupButton setTitleColor:[UIColor colorWithRed:0.46f green:0.46f blue:0.46f alpha:1.00f] forState:UIControlStateNormal];
    [self.loginView addSubview:signupButton];
    signupButton.layer.cornerRadius = 8;
    self.signupButton = signupButton;
    [signupButton addTarget:self action:@selector(signupAction:) forControlEvents:UIControlEventTouchUpInside];

    
}

/**
 *  登录Aciton
 */
-(void)loginAction:(UIButton*)button
{
    NSLog(@"loginAction");
}


/**
 *  注册Action */
-(void)signupAction:(UIButton*)button
{
    NSLog(@"signupAction");
}

/**
 *  点击背景键盘收起
 */
-(void)resignFirstRe
{
    [self.nameField resignFirstResponder];
    [self.passWordField resignFirstResponder];
}

/**
 *  不知道这个是干什么的
 */
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


/**
 *  键盘出现的Action
 */
-(void)keyboardShow:(NSNotification*)notification
{
        [UIView animateWithDuration:0.2 animations:^{
            if (self.nameField.frame.origin.y == ORIGIN_FRAMW_Y) {
                CGRect nameFrame = self.nameField.frame;
                nameFrame.origin.y -= CHANGE_FRAME_VALUE;
                self.nameField.frame = nameFrame;
                
                CGRect passWordFrame = self.passWordField.frame;
                passWordFrame.origin.y -= CHANGE_FRAME_VALUE;
                self.passWordField.frame = passWordFrame;
                
                CGRect loginFrame = self.loginButton.frame;
                loginFrame.origin.y -= CHANGE_FRAME_VALUE;
                self.loginButton.frame = loginFrame;
                
                CGRect signupFrame = self.signupButton.frame;
                signupFrame.origin.y -= CHANGE_FRAME_VALUE;
                self.signupButton.frame = signupFrame;
                

            }
        }];
}


/**
 *  键盘消失的Action
 */
-(void)keyboardHide:(NSNotification*)notification
{
    [UIView animateWithDuration:0.1 animations:^{
        if (self.nameField.frame.origin.y == ORIGIN_FRAMW_Y - CHANGE_FRAME_VALUE) {
            CGRect frame = self.nameField.frame;
            frame.origin.y += CHANGE_FRAME_VALUE;
            self.nameField.frame = frame;
            
            CGRect passWordFrame = self.passWordField.frame;
            passWordFrame.origin.y += CHANGE_FRAME_VALUE;
            self.passWordField.frame = passWordFrame;
            
            CGRect loginFrame = self.loginButton.frame;
            loginFrame.origin.y += CHANGE_FRAME_VALUE;
            self.loginButton.frame = loginFrame;
            
            CGRect signupFrame = self.signupButton.frame;
            signupFrame.origin.y += CHANGE_FRAME_VALUE;
            self.signupButton.frame = signupFrame;

            
        }
    }];
}


/**
 *  循环播放
 */
-(void)moviePlayDidEnd:(NSNotification*)notification
{
    AVPlayerItem *item = [notification object];
    
    [item seekToTime:kCMTimeZero];
    
    [self.player play];
    
}


@end























