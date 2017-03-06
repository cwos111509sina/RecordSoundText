//
//  ViewController.m
//  recordSound
//
//  Created by zzjd on 2017/3/6.
//  Copyright © 2017年 zzjd. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>


#define WIDTH [UIScreen mainScreen].bounds.size.width


#define HEIGHT [UIScreen mainScreen].bounds.size.height


@interface ViewController ()


@property (nonatomic,strong)AVAudioSession * session;

@property (nonatomic,strong)AVAudioRecorder * record;

@property (nonatomic,assign)NSTimer * timer;

@property (nonatomic,copy)NSString *filePath;


@property (nonatomic,strong)AVAudioPlayer * player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self createUI];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)createUI{

    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.frame = CGRectMake(30, HEIGHT-100, (WIDTH-90)/2, 40);
    
    [button setTitle:@"按住录音" forState:UIControlStateNormal];
    
    button.backgroundColor = [UIColor blackColor];
    
    button.layer.cornerRadius = 20;
    
    button.clipsToBounds = YES;
    
    /*
     
     UIControlEventTouchDown 按下
     
     UIControlEventTouchCancel 意外取消
     
     UIControlEventTouchUpInside 点击
     
     UIControlEventTouchDragExit 拖出
     
     UIControlEventTouchUpOutside 手势外部抬起
     
     UIControlEventTouchDragEnter 拖回
     
     */
    [button addTarget:self action:@selector(voiceBtnClickDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(voiceBtnClickCancel:) forControlEvents:UIControlEventTouchCancel];
    [button addTarget:self action:@selector(voiceBtnClickUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(voiceBtnClickDragExit:) forControlEvents:UIControlEventTouchDragExit];
    [button addTarget:self action:@selector(voiceBtnClickUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [button addTarget:self action:@selector(voiceBtnClickDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
    
    
    [self.view addSubview:button];
    
    
    UIButton * playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    playButton.frame = CGRectMake((WIDTH-90)/2+60, HEIGHT-100, (WIDTH-90)/2, 40);
    
    [playButton setTitle:@"播放" forState:UIControlStateNormal];
    
    playButton.backgroundColor = [UIColor blackColor];
    playButton.layer.cornerRadius = 20;
    playButton.clipsToBounds = YES;
    
    [playButton addTarget:self action:@selector(playVoice) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:playButton];
    
    

    _filePath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *name = [NSString stringWithFormat:@"%d.wav",(int)[NSDate date].timeIntervalSince1970];
    _filePath=[_filePath stringByAppendingPathComponent:name];

    
    
    
}

//播放声音
-(void)playVoice{
    
    if ([_player isPlaying]) {
        [_player stop];
        _player = nil;
    }

    
    _player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:_filePath] error:nil];
    
    if ([_player isPlaying]) {
        return;
    }
    
    
    [_player play];
    
}

-(void)voiceBtnClickDown:(UIButton *)btn{//按下
    
    
    if ([_player isPlaying]) {
        [_player stop];
        _player = nil;
    }
    
    NSLog(@"按下");
    
    [btn setTitle:@"松开完成" forState:UIControlStateNormal];
    
    NSURL *url=[NSURL fileURLWithPath:_filePath];
    
    
    NSDictionary * dict = @{AVFormatIDKey:@(kAudioFormatLinearPCM),
                            AVSampleRateKey:@(8000),
                            AVNumberOfChannelsKey:@(1),
                            AVLinearPCMBitDepthKey:@(8),
                            AVLinearPCMIsFloatKey:@(YES)
                            };
    
    if (!_session) {
        _session = [AVAudioSession sharedInstance];
        
        if ([_session respondsToSelector:@selector(requestRecordPermission:)]) {
            [_session performSelector:@selector(requestRecordPermission:) withObject:^(BOOL isTrue){
                if (isTrue) {
                }else{
                    NSLog(@"app需要访问您的麦克风。");
                }
                
            }];
        }
        [_session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    
    
    _record = [[AVAudioRecorder alloc]initWithURL:url settings:dict error:nil];
    _record.meteringEnabled = YES;//监听音量大小
    [_record prepareToRecord];
    [_record record];
    
    
    UIView * recordView = [[UIView alloc]initWithFrame:CGRectMake(WIDTH/2-100, HEIGHT/2-100, 200, 200)];
    
    recordView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    recordView.tag = 101;
    
    
    UIImageView * micImg = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH*50/720, HEIGHT*66/1280,WIDTH*280/720, HEIGHT*200/1280)];
    micImg.contentMode = UIViewContentModeLeft;
    [micImg setImage:[UIImage imageNamed:@"chat_microphone_1"]];
    micImg.backgroundColor = [UIColor clearColor];
    micImg.tag = 135;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(voiceChange:) userInfo:nil repeats:YES];
    
    UIImageView * micImgCan = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH*120/720, HEIGHT*66/1280,WIDTH*140/720, HEIGHT*200/1280)];
    micImgCan.backgroundColor = [UIColor clearColor];
    micImgCan.image = [UIImage imageNamed:@"chat_microphone_cancel"];
    micImgCan.tag = 134;
    
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(micImg.frame)+HEIGHT*60/1280, 160, HEIGHT*60/1280)];
    label.tag = 136;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = @"手指上滑,取消发送";
    
    
    micImgCan.hidden = YES;
    micImg.hidden = NO;
    
    [recordView addSubview:label];
    [recordView addSubview:micImg];
    [recordView addSubview:micImgCan];
    
    [self.view addSubview:recordView];
}

-(void)voiceChange:(NSTimer *)timer{
    
    UIView * view = [self.view viewWithTag:101];
    
    UIImageView * micImg = [view viewWithTag:135];
    
    [_record updateMeters];//刷新音量数据
    
    CGFloat lowPassResults = pow(10, (0.05 * [_record peakPowerForChannel:0]));

//    NSLog(@"lowPassResults = %f",lowPassResults);
    
    //  根据音量大小选择显示图片  图片 小-》大
    if (0<lowPassResults<=0.14) {
        [micImg setImage:[UIImage imageNamed:@"chat_microphone_1"]];
    }else if (0.14<lowPassResults<=0.28) {
        [micImg setImage:[UIImage imageNamed:@"chat_microphone_2"]];
    }else if (0.28<lowPassResults<=0.42) {
        [micImg setImage:[UIImage imageNamed:@"chat_microphone_3"]];
    }else if (0.42<lowPassResults<=0.56) {
        [micImg setImage:[UIImage imageNamed:@"chat_microphone_4"]];
    }else if (0.56<lowPassResults<=0.70) {
        [micImg setImage:[UIImage imageNamed:@"chat_microphone_5"]];
    }else if (0.70<lowPassResults<=0.84) {
        [micImg setImage:[UIImage imageNamed:@"chat_microphone_6"]];
    }else if (0.84<lowPassResults) {
        [micImg setImage:[UIImage imageNamed:@"chat_microphone_7"]];
    }
    
}


-(void)voiceBtnClickCancel:(UIButton *)btn{//意外取消
    NSLog(@"意外取消");
    [btn setTitle:@"松开完成" forState:UIControlStateNormal];
    
    UIView * view = [self.view viewWithTag:101];
    [view removeFromSuperview];
    
    if ([_record isRecording]) {
        [_record stop];
        [_record deleteRecording];
    }
    
    _record = nil;
    
    if (_timer.isValid) {//判断timer是否在线程中
        [_timer invalidate];
    }
    _timer=nil;

    
}
-(void)voiceBtnClickUpInside:(UIButton *)btn{//点击(录音完成)
    NSLog(@"点击");
    [btn setTitle:@"按住录音" forState:UIControlStateNormal];

    
    UIView * view = [self.view viewWithTag:101];
    [view removeFromSuperview];
    
    [_record stop];
    
    if (_timer.isValid) {
        [_timer invalidate];
    }
    _timer=nil;
    

    
}
-(void)voiceBtnClickDragExit:(UIButton *)btn{//拖出
    NSLog(@"拖出");
    
    [btn setTitle:@"按住录音" forState:UIControlStateNormal];

    
    UIView * view = [self.view viewWithTag:101];
    
    UIImageView * micImg = [view viewWithTag:135];
    micImg.hidden = YES;
    
    UIImageView * micImgCan = [view viewWithTag:134];
    micImgCan.hidden = NO;
    
    UILabel * alertLab = [view viewWithTag:136];
    alertLab.backgroundColor = [UIColor colorWithRed:255/255.0 green:128/255.0 blue:158/255.0 alpha:1];
    
}
-(void)voiceBtnClickUpOutside:(UIButton *)btn{//外部手势抬起
    NSLog(@"外部手势抬起");

    [btn setTitle:@"按住录音" forState:UIControlStateNormal];
    
    UIView * view = [self.view viewWithTag:101];
    [view removeFromSuperview];
    
    
    if ([_record isRecording]) {
        
        [_record stop];
        [_record deleteRecording];
        
    }
    _record = nil;
    
    
    if (_timer.isValid) {
        [_timer invalidate];
    }
    _timer=nil;

}

-(void)voiceBtnClickDragEnter:(UIButton *)btn{//拖回
    NSLog(@"拖回");

    [btn setTitle:@"松开完成" forState:UIControlStateNormal];
    
    UIView * view = [self.view viewWithTag:101];
    
    
    UIImageView * micImg = [view viewWithTag:135];
    micImg.hidden = NO;
    
    UIImageView * micImgCan = [view viewWithTag:134];
    micImgCan.hidden = YES;
    
    
    UILabel * alertLab = [view viewWithTag:136];
    alertLab.backgroundColor = [UIColor clearColor];
    
    
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
