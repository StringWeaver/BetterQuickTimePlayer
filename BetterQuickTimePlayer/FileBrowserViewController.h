//
//  FileBrowserViewController.h
//  BetterQuickTimePlayer
//
//  Created by StringWeaver on 2025/12/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileBrowserViewController : UIDocumentBrowserViewController<UIDocumentBrowserViewControllerDelegate>
- (void) openUrl:(NSURL*)url;
@end

NS_ASSUME_NONNULL_END
