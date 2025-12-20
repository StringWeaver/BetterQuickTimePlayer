//
//  SceneDelegate.m
//  BetterQuickTimePlayer
//
//  Created by StringWeaver on 2025/12/17.
//

#import "SceneDelegate.h"
#import "FileBrowserViewController.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate

// this function will be call if you attempt to open file with this app and it needs cold booting
- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    // URL Scheme / Universal Link
    if (connectionOptions.URLContexts.count > 0) {
        UIOpenURLContext *context = connectionOptions.URLContexts.anyObject;
        [self openUrl:context.URL];
    }
}

// this function will be call if you attempt to open file with this app and it is alive in backgroud
- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    UIOpenURLContext *context = URLContexts.anyObject;
    NSURL *url = context.URL;
    if (url) [self openUrl:url];
    
}

- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}

-(void)openUrl:(NSURL*) url{
    FileBrowserViewController* browser = (FileBrowserViewController *)self.window.rootViewController;
    [browser openUrl:url];
    [browser revealDocumentAtURL:url
                  importIfNeeded:NO
                      completion:^(NSURL * _Nullable revealedURL, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Reveal error: %@", error);
            return;
        }
        [browser openUrl:url];
    }];
}


@end
