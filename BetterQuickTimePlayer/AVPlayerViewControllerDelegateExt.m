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
@property (nonatomic, weak) UIViewController *parentViewController;
@property BOOL pipActive;
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
    _playerViewController.player = _player;
    _playerViewController.canStartPictureInPictureAutomaticallyFromInline = NO;
    _player.preventsDisplaySleepDuringVideoPlayback = YES;
    _pipActive = NO;
}

- (void)configureAVAudioSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    BOOL ok = [session setCategory:AVAudioSessionCategoryPlayback
                       withOptions:0
                             error:&error];
    if (!ok) {
        NSLog(@"setCategory error: %@", error);
    }
    ok = [session setActive:YES error:&error];
    if (!ok) {
        NSLog(@"setActive error: %@", error);
    }
}
- (void)cleanup{
    if (_timeObserver) {
        @try {
            [_player removeTimeObserver:_timeObserver];
        } @catch (NSException *exception) {
            // ignore potential exception if already removed
        }
        _timeObserver = nil;
    }
    [_player pause];
    //[_player replaceCurrentItemWithPlayerItem:nil];
    if(_url){
        [_url stopAccessingSecurityScopedResource];
        _url = nil;
    }
}
- (void)dealloc{
    [self cleanup];
}

- (void) openUrl:(NSURL*)url from:(UIViewController*)viewController{
    _parentViewController = viewController;
    [self cleanup];
    if(!_pipActive || TARGET_OS_MACCATALYST /* On Mac Catalyst, open a new file when pip view is active would cause DocumentBrowserView Disappear */) {
        [_parentViewController presentViewController:self.playerViewController animated:YES completion:^{
            
        }];
    }
    _url = url;
    BOOL success = [_url startAccessingSecurityScopedResource];
    if (!success) {
        _url = nil;
        return;
    }
    NSString* filename = url.lastPathComponent;
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:_url];
    AVMutableMetadataItem *metadataItem = [AVMutableMetadataItem new];
    metadataItem.keySpace = AVMetadataKeySpaceCommon;
    metadataItem.key = AVMetadataCommonKeyTitle;
    metadataItem.value = trimLeadingNonDigits(filename);
    item.externalMetadata = @[metadataItem];
    [_player replaceCurrentItemWithPlayerItem:item];
    [self configureAVAudioSession];
    
    
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
    [_player play];
}

- (void)saveProgressForFilename:(NSString*)filename WithTime:(CMTime)time  {
    double sec = CMTimeGetSeconds(time);
    if (sec > 0 && filename.length > 0) {
        [[NSUserDefaults standardUserDefaults] setDouble:sec forKey:filename];
    }
}
- (void)playerViewControllerWillStartPictureInPicture:(AVPlayerViewController *)playerViewController {
    _pipActive = YES;
}
- (void) playerViewControllerDidStopPictureInPicture:(AVPlayerViewController *) playerViewController{
    _pipActive = NO;
}
- (void)playerViewController:(AVPlayerViewController *)playerViewController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler {
    UIViewController *strongParentViewController = _parentViewController;

    if(strongParentViewController){
        if(_playerViewController.presentingViewController != strongParentViewController){
            [strongParentViewController presentViewController:playerViewController
                                     animated:YES
                                   completion:^{
                completionHandler(YES);
            }];
        } else { // MacCatalyst edge case
            completionHandler(YES);
        }
    }else{
        completionHandler(NO);
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

static NSString *trimLeadingNonDigits(NSString *input) {
    NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];
    NSRange r = [input rangeOfCharacterFromSet:digits];
    if (r.location == NSNotFound) {
        return @"";
    }
    return [input substringFromIndex:r.location];
}


@end
