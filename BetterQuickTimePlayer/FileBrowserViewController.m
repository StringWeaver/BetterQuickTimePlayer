//
//  FileBrowserViewController.m
//  BetterQuickTimePlayer
//
//  Created by StringWeaver on 2025/12/17.
//

#import "FileBrowserViewController.h"
#import "AVPlayerViewControllerDelegateExt.h"


@interface FileBrowserViewController ()
@property AVPlayerViewControllerDelegateExt* playerViewControllerDelegate;
@end

@implementation FileBrowserViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    _playerViewControllerDelegate = [[AVPlayerViewControllerDelegateExt alloc] init];
    self.allowsPickingMultipleItems = YES;
    self.allowsDocumentCreation = NO;
}

- (void) openUrl:(NSURL*)url {
    [self.playerViewControllerDelegate openUrl:url from:self];
}

- (void)documentBrowser:(UIDocumentBrowserViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    [self openUrl:urls.firstObject];
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
