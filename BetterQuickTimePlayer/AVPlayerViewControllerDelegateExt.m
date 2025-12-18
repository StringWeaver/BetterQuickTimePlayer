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
}

- (void)dealloc{
    if(_url){
        [_url stopAccessingSecurityScopedResource];
        _url = nil;
    }
    _playerViewController = nil;
}

- (void) openUrl:(NSURL*)url{
    _url = url;
    BOOL success = [_url startAccessingSecurityScopedResource];
    if (!success) return;
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:_url];
    [_player replaceCurrentItemWithPlayerItem:item];
    [self.player play];
}

- (void)presentationControllerDidDismiss:(UIPresentationController *)presentationController {
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
    [playerViewController.view addGestureRecognizer:panBlocker];
}

//- (void)saveProgressWithTime:(CMTime)time  {
//    double sec = CMTimeGetSeconds(time);
//    if (sec > 0 && _filename.length > 0) {
//        [[NSUserDefaults standardUserDefaults] setDouble:sec forKey:_filename];
//    }
//}

@end
