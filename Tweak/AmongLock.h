#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import <sys/utsname.h>
#import <Cephei/HBPreferences.h>

HBPreferences* preferences;

extern BOOL enabled;

BOOL isiPhone = NO;
BOOL isiPod = NO;
BOOL isiPad = NO;

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

// background video
BOOL useAsWallpaperSwitch = NO;

// hiding
BOOL hideEmergencyButtonSwitch = NO;
BOOL hideBackspaceButtonSwitch = NO;
BOOL hideCancelButtonSwitch = NO;
BOOL hideFaceIDAnimationSwitch = YES;

// miscellaneous
BOOL tapToDismissEjectionSwitch = YES;

@interface CSPasscodeViewController : UIViewController
- (void)ejectionVideoFinishedPlaying;
@end

@interface CSCoverSheetViewController : UIViewController
@end

@interface MTMaterialView : UIView
@end

@interface SBUISimpleFixedDigitPasscodeEntryField : UIView
@end

@interface SBUINumericPasscodeEntryFieldBase : UIView
@property(assign, nonatomic)unsigned long long maxNumbersAllowed;
@end

@interface SBUIPasscodeTextField : UIView
@property(assign, nonatomic)id delegate;
- (void)setText:(NSString *)arg1;
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