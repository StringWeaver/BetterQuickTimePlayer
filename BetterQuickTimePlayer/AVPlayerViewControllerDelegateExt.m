//
//  AVPlayerViewControllerDelegateExt.m
//  BetterQuickTimePlayer
//
//  Created by StringWeaver on 2025/12/18.
//

#import "AVPlayerViewControllerDelegateExt.h"

@implementation AVPlayerViewControllerDelegateExt

- (void)EmptyPanAction:(UIPanGestureRecognizer *)pan {

}

- (void)playerViewController:(AVPlayerViewController *)playerViewController willBeginFullScreenPresentationWithAnimationCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    UIPanGestureRecognizer *panBlocker = [[UIPanGestureRecognizer alloc] initWithTarget:self  action:@selector(EmptyPanAction:)];
    [playerViewController.view addGestureRecognizer:panBlocker];
}

@end
