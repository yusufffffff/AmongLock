#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>

AVQueuePlayer* backgroundPlayer;
AVPlayerLooper* backgroundPlayerLooper;
AVPlayerItem* backgroundPlayerItem;
AVPlayerLayer* backgroundPlayerLayer;

AVPlayer* ejectionPlayer;
AVPlayerItem* ejectionPlayerItem;
AVPlayerLayer* ejectionPlayerLayer;

UIImageView* passcodeBackground;
UIImageView* passcodeButton;

UIImageView* emergencyButtonImage;
UIImageView* backspaceButtonImage;
UIImageView* cancelButtonImage;

@interface CSPasscodeViewController : UIViewController
- (void)ejectionVideoFinishedPlaying;
@end

@interface SBNumberPadWithDelegate : UIView
@end

@interface SBPasscodeNumberPadButton : UIView
- (void)changePasscodeButtonImages;
@end

@interface TPNumberPadButton : UIView
@end

@interface SBLockScreenManager : NSObject
- (BOOL)isUILocked;
@end

@interface SBUIProudLockIconView : UIView
- (void)receiveHideNotification:(NSNotification *)notification;
@end

@interface CSTeachableMomentsContainerView : UIView
- (void)receiveHideNotification:(NSNotification *)notification;
@end

@interface SBUIButton : UIButton
@end