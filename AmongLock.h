#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>

AVPlayer* ejectionPlayer;
AVPlayerItem* ejectionPlayerItem;
AVPlayerLayer* ejectionPlayerLayer;

AVPlayer* backgroundPlayer;
AVPlayerItem* backgroundPlayerItem;
AVPlayerLayer* backgroundPlayerLayer;

@interface CSPasscodeViewController : UIViewController
@end

@interface SBLockScreenManager : NSObject
- (BOOL)isUILocked;
@end