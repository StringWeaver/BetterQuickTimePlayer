//
//  FileBrowserViewController.m
//  BetterQuickTimePlayer
//
//  Created by StringWeaver on 2025/12/17.
//

#import "FileBrowserViewController.h"
#import "AVPlayerViewControllerDelegateExt.h"
#import <AVKit/AVKit.h>

@interface FileBrowserViewController ()
@property AVPlayer *player;
@property (nonatomic, strong, nullable) id timeObserver;
@property AVPlayerViewController* playerViewController;
@property AVPlayerViewControllerDelegateExt* playerViewControllerDelegate;
@property NSURL *url;
@end

@implementation FileBrowserViewController

//- (void)saveProgressWithTime:(CMTime)time  {
//    double sec = CMTimeGetSeconds(time);
//    if (sec > 0 && _filename.length > 0) {
//        [[NSUserDefaults standardUserDefaults] setDouble:sec forKey:_filename];
//    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    _player = [[AVPlayer alloc] init];
    _playerViewController  = [[AVPlayerViewController alloc] init];
    _playerViewController.presentationController.delegate = self;
    _playerViewController.player = _player;
    _playerViewControllerDelegate = [[AVPlayerViewControllerDelegateExt alloc] init];
    _playerViewController.delegate = _playerViewControllerDelegate;
    self.allowsPickingMultipleItems = YES;
    self.allowsDocumentCreation = NO;

}
- (void)dealloc{
    if(_url){
        [_url stopAccessingSecurityScopedResource];
        _url = nil;
    }
    _playerViewController = nil;
}

- (void)documentBrowser:(UIDocumentBrowserViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    _url = urls.firstObject;
    BOOL success = [_url startAccessingSecurityScopedResource];
    if (!success) return;
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:_url];
    [_player replaceCurrentItemWithPlayerItem:item];
    
    [controller presentViewController:_playerViewController animated:YES completion:^{
        [self.player play];
    }];
    
}
- (void)presentationControllerDidDismiss:(UIPresentationController *)presentationController {
    [_player pause];
    [_player replaceCurrentItemWithPlayerItem:nil];
    if(_url){
        [_url stopAccessingSecurityScopedResource];
        _url = nil;
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
