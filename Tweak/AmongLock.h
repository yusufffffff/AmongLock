#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import <Cephei/HBPreferences.h>

HBPreferences* preferences;

extern BOOL enabled;

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

BOOL useAsWallpaperSwitch = NO;

@interface CSPasscodeViewController : UIViewController
- (void)ejectionVideoFinishedPlaying;
@end

@interface CSCoverSheetViewController : UIViewController
@end

@interface MTMaterialView : UIView
@end

@interface SBUISimpleFixedDigitPasscodeEntryField : UIView
@end

@interface SBUIPasscodeTextField : UIView
@property(assign, nonatomic)id delegate;
@end

@interface SBNumberPadWithDelegate : UIControl
@end

@interface SBPasscodeNumberPadButton : UIControl
- (void)changePasscodeButtonImages;
- (void)failedPasscodeAttemptAnimation:(NSNotification *)notification;
@end

@interface TPNumberPadButton : UIControl
@end

@interface SBLockScreenManager : NSObject
- (BOOL)isUILocked;
@end

@interface SBUIProudLockIconView : UIView
- (void)receiveHideNotification:(NSNotification *)notification;
@end

@interface SBFLockScreenDateView : UIView
- (void)receiveHideNotification:(NSNotification *)notification;
@end

@interface CSQuickActionsButton : UIView
- (void)receiveHideNotification:(NSNotification *)notification;
@end

@interface CSTeachableMomentsContainerView : UIView
- (void)receiveHideNotification:(NSNotification *)notification;
@end

@interface SBUIButton : UIButton
@end