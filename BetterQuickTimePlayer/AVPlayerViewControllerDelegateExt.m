//
//  AVPlayerViewControllerDelegateExt.m
//  BetterQuickTimePlayer
//
//  Created by StringWeaver on 2025/12/18.
//

#import "AVPlayerViewControllerDelegateExt.h"
@interface AVPlayerViewControllerDelegateExt()
@property AVPlayer* player;
@property (nonatomic, strong, nullable) id timeObserver;
@property NSURL* url;
@end

@implementation AVPlayerViewControllerDelegateExt

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void) commonInit{
    _player = [[AVPlayer alloc] init];
    _playerViewController  = [[AVPlayerViewController alloc] init];
    _playerViewController.delegate = self;
    _playerViewController.presentationController.delegate = self;
    _playerViewController.player = _player;
    _player.preventsDisplaySleepDuringVideoPlayback = YES;
}

- (void)dealloc{
    if(_url){
        [_url stopAccessingSecurityScopedResource];
        _url = nil;
    }
}

- (void) openUrl:(NSURL*)url{
    _url = url;
    BOOL success = [_url startAccessingSecurityScopedResource];
    if (!success) return;
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:_url];
    [_player replaceCurrentItemWithPlayerItem:item];
    [self.player play];
    NSString* filename = url.lastPathComponent;
    
    double seconds = [[NSUserDefaults standardUserDefaults] doubleForKey:filename];
    if (seconds > 0) {
        CMTime prevProgress = CMTimeMakeWithSeconds(seconds, 1);
        [self.player seekToTime:prevProgress];
    }

    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(2, 1)
                                                                 queue:dispatch_get_main_queue()
                                                            usingBlock:^(CMTime time) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        [strongSelf saveProgressForFilename:filename WithTime:time];
    }];
}

- (void)presentationControllerDidDismiss:(UIPresentationController *)presentationController {
    if (_timeObserver) {
        @try {
            [_player removeTimeObserver:_timeObserver];
        } @catch (NSException *exception) {
            // ignore potential exception if already removed
        }
        _timeObserver = nil;
    }
    [_player pause];
    [_player replaceCurrentItemWithPlayerItem:nil];
    if(_url){
        [_url stopAccessingSecurityScopedResource];
        _url = nil;
    }
}


- (void)EmptyPanAction:(UIPanGestureRecognizer *)pan {
    
}

- (void)playerViewController:(AVPlayerViewController *)playerViewController willBeginFullScreenPresentationWithAnimationCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    UIPanGestureRecognizer *panBlocker = [[UIPanGestureRecognizer alloc] initWithTarget:self  action:@selector(EmptyPanAction:)];
    // avoids redundate panBlocker
    if (![playerViewController.view.gestureRecognizers containsObject:panBlocker]) {
        [playerViewController.view addGestureRecognizer:panBlocker];
    }
}

- (void)saveProgressForFilename:(NSString*)filename WithTime:(CMTime)time  {
    double sec = CMTimeGetSeconds(time);
    if (sec > 0 && filename.length > 0) {
        [[NSUserDefaults standardUserDefaults] setDouble:sec forKey:filename];
    }
}

@end
