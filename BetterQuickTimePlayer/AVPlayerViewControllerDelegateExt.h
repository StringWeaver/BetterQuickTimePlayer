//
//  AVPlayerViewControllerDelegateExt.h
//  BetterQuickTimePlayer
//
//  Created by StringWeaver on 2025/12/18.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVPlayerViewControllerDelegateExt :NSObject<AVPlayerViewControllerDelegate, UIAdaptivePresentationControllerDelegate>
@property AVPlayerViewController* playerViewController;
- (void) openUrl:(NSURL*)url;
@end

NS_ASSUME_NONNULL_END
