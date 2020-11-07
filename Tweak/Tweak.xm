#import "AmongLock.h"

BOOL enabled;

%group AmongLock

%hook CSPasscodeViewController

- (void)viewDidLoad { // add video players

	%orig;

	// background video
	if (!useAsWallpaperSwitch) {
		NSString* backgroundFilePath = [NSString stringWithFormat:@"/Library/AmongLock/background.mp4"];
		NSURL* backgroundUrl = [NSURL fileURLWithPath:backgroundFilePath];

		if (!backgroundPlayerItem) backgroundPlayerItem = [AVPlayerItem playerItemWithURL:backgroundUrl];

		if (!backgroundPlayer) backgroundPlayer = [AVQueuePlayer playerWithPlayerItem:backgroundPlayerItem];
		[backgroundPlayer setVolume:0.0];

		if (!backgroundPlayerLooper) backgroundPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:backgroundPlayer templateItem:backgroundPlayerItem];

		if (!backgroundPlayerLayer) backgroundPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:backgroundPlayer];
		[backgroundPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
		[backgroundPlayerLayer setFrame:[[[self view] layer] bounds]];
		[backgroundPlayerLayer setHidden:YES];

		[[[self view] layer] insertSublayer:backgroundPlayerLayer atIndex:1];
	}


	// ejection video
	NSString* ejectionFilePath = [NSString stringWithFormat:@"/Library/AmongLock/ejection.mp4"];
    NSURL* ejectionUrl = [NSURL fileURLWithPath:ejectionFilePath];

    if (!ejectionPlayerItem) ejectionPlayerItem = [AVPlayerItem playerItemWithURL:ejectionUrl];

    if (!ejectionPlayer) ejectionPlayer = [AVPlayer playerWithPlayerItem:ejectionPlayerItem];
    [ejectionPlayer setVolume:1.0];

    if (!ejectionPlayerLayer) ejectionPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:ejectionPlayer];
    [ejectionPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [ejectionPlayerLayer setFrame:[[[self view] layer] bounds]];
	[ejectionPlayerLayer setHidden:YES];

    [[[self view] layer] addSublayer:ejectionPlayerLayer];

	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ejectionVideoFinishedPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:[ejectionPlayer currentItem]];

}

- (void)viewWillAppear:(BOOL)animated { // start background video playback when passcode view appears and play sound

	%orig;

	[[NSNotificationCenter defaultCenter] postNotificationName:@"amonglockHideElements" object:nil];

	if (!useAsWallpaperSwitch) {
		[backgroundPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];
		[backgroundPlayerLayer setHidden:NO];
		[backgroundPlayer play];
	}

	SystemSoundID sound = 0;
	AudioServicesDisposeSystemSoundID(sound);
	AudioServicesCreateSystemSoundID((CFURLRef) CFBridgingRetain([NSURL fileURLWithPath:@"/Library/AmongLock/passcodeAppeared.mp3"]), &sound);
	AudioServicesPlaySystemSound((SystemSoundID)sound);

}

- (void)viewWillDisappear:(BOOL)animated { // unhide faceid lock and homebar when passcode disappears

	%orig;

	[[NSNotificationCenter defaultCenter] postNotificationName:@"amonglockUnhideElements" object:nil];

	[ejectionPlayerLayer setHidden:YES];
	[ejectionPlayer pause];
	[ejectionPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];

}

%new
- (void)ejectionVideoFinishedPlaying { // reset buttons and hide ejection video when done playing

	[[NSNotificationCenter defaultCenter] postNotificationName:@"amonglockFailedAttemptReset" object:nil];
	[ejectionPlayerLayer setHidden:YES];
	[ejectionPlayer pause];
	[ejectionPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];

}

%end

%hook CSCoverSheetViewController

- (void)viewDidLoad {

	%orig;

	if (!useAsWallpaperSwitch) return;
	NSString* backgroundFilePath = [NSString stringWithFormat:@"/Library/AmongLock/background.mp4"];
	NSURL* backgroundUrl = [NSURL fileURLWithPath:backgroundFilePath];

	if (!backgroundPlayerItem) backgroundPlayerItem = [AVPlayerItem playerItemWithURL:backgroundUrl];

	if (!backgroundPlayer) backgroundPlayer = [AVQueuePlayer playerWithPlayerItem:backgroundPlayerItem];
	[backgroundPlayer setVolume:0.0];

	if (!backgroundPlayerLooper) backgroundPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:backgroundPlayer templateItem:backgroundPlayerItem];

	if (!backgroundPlayerLayer) backgroundPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:backgroundPlayer];
	[backgroundPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	[backgroundPlayerLayer setFrame:[[[self view] layer] bounds]];
	[backgroundPlayerLayer setHidden:YES];

	[[[self view] layer] insertSublayer:backgroundPlayerLayer atIndex:0];

}

- (void)viewWillAppear:(BOOL)animated {

	%orig;

	if (!useAsWallpaperSwitch) return;
	[backgroundPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];
	[backgroundPlayerLayer setHidden:NO];
	[backgroundPlayer play];

}

- (void)viewWillDisappear:(BOOL)animated {

	%orig;

	if (!useAsWallpaperSwitch) return;
	[backgroundPlayerLayer setHidden:YES];
	[backgroundPlayer pause];
	[backgroundPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];

}

%end

%hook CSPasscodeBackgroundView

- (void)didMoveToWindow { // hide passcode blur and dim if background as wallpaper is enabled

	%orig;

	if (!useAsWallpaperSwitch) return;
	MTMaterialView* blurView = MSHookIvar<MTMaterialView *>(self, "_materialView");
	UIView* dimView1 = MSHookIvar<UIView *>(self, "_lightenSourceOverView");
	UIView* dimView2 = MSHookIvar<UIView *>(self, "_plusDView");

	[blurView setHidden:YES];
	[dimView1 setHidden:YES];
	[dimView2 setHidden:YES];

}

%end

%hook SBUISimpleFixedDigitPasscodeEntryField

- (void)didMoveToWindow { // add bulbs to the original passcode entry field

	%orig;

	[self setClipsToBounds:NO];

	NSMutableArray* indicators = MSHookIvar<NSMutableArray *>(self, "_characterIndicators");
	for (UIView* indicatorSubview in indicators) {
		UIImageView* bulb = [[UIImageView alloc] initWithFrame:[indicatorSubview bounds]];
		bulb.bounds = CGRectInset(bulb.frame, 2.5, -8.5);
		[bulb setImage:[UIImage imageWithContentsOfFile:@"/Library/AmongLock/bulbOff.png"]];
		[indicatorSubview addSubview:bulb];
	}

}

%end

%hook SBUIPasscodeTextField

- (void)setText:(NSString *)arg1 { // update bulbs when entering passcode

    %orig;

    if ([[self delegate] isKindOfClass:%c(SBUISimpleFixedDigitPasscodeEntryField)]) {
        NSMutableArray* indicators = [[self delegate] valueForKey:@"_characterIndicators"];

        for (short i = 0; i < 3; i++) {
            UIView* view = (UIView *)[indicators objectAtIndex:i];
            for (UIImageView* imageView in [view subviews]) {
                if ([imageView isKindOfClass:%c(UIImageView)]) {
					if (i < [arg1 length])
                        [imageView setImage:[UIImage imageWithContentsOfFile:@"/Library/AmongLock/bulbOn.png"]];
                    else
                        [imageView setImage:[UIImage imageWithContentsOfFile:@"/Library/AmongLock/bulbOff.png"]];
				}
            }
        }
    }

}

%end

%hook SBNumberPadWithDelegate

- (void)didMoveToWindow { // add passcode background image

	%orig;
	
	if (!passcodeBackground) {
		passcodeBackground = [[UIImageView alloc] initWithFrame:[self bounds]];
		passcodeBackground.bounds = CGRectInset(passcodeBackground.frame, -35, -35);
		[passcodeBackground setImage:[UIImage imageWithContentsOfFile:@"/Library/AmongLock/passcodeBackground.png"]];
	}

	if (![passcodeBackground isDescendantOfView:self]) [self insertSubview:passcodeBackground atIndex:0];

	self.transform = CGAffineTransformMakeScale(0.85, 0.85);

}

%end

%hook SBPasscodeNumberPadButton

- (void)didMoveToWindow { // add passcode button image

	%orig;

	passcodeButton = [[UIImageView alloc] initWithFrame:[self bounds]];
	passcodeButton.bounds = CGRectInset(passcodeButton.frame, 12, 7);
	[passcodeButton setImage:[UIImage imageWithContentsOfFile:@"/Library/AmongLock/passcodeButtonOff.png"]];

	if (![passcodeButton isDescendantOfView:self]) [self addSubview:passcodeButton];

	[self performSelector:@selector(changePasscodeButtonImages) withObject:self afterDelay:0.5];

	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedPasscodeAttemptAnimation:) name:@"amonglockFailedAttemptAnimation" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePasscodeButtonImages) name:@"amonglockFailedAttemptReset" object:nil];

}

%new
- (void)changePasscodeButtonImages { // change passcode images to the 'on' state images

	passcodeButton = [[UIImageView alloc] initWithFrame:[self bounds]];
	passcodeButton.bounds = CGRectInset(passcodeButton.frame, 12, 7);
	[passcodeButton setImage:[UIImage imageWithContentsOfFile:@"/Library/AmongLock/passcodeButtonOn.png"]];

	if (![passcodeButton isDescendantOfView:self]) [self addSubview:passcodeButton];

}

%new
- (void)failedPasscodeAttemptAnimation:(NSNotification *)notification {

	if (![notification.name isEqual:@"amonglockFailedAttemptAnimation"]) return;

	passcodeButton = [[UIImageView alloc] initWithFrame:[self bounds]];
	passcodeButton.bounds = CGRectInset(passcodeButton.frame, 12, 7);
	[passcodeButton setImage:[UIImage imageWithContentsOfFile:@"/Library/AmongLock/passcodeButtonFailed.png"]];

	if (![passcodeButton isDescendantOfView:self]) [self addSubview:passcodeButton];

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		passcodeButton = [[UIImageView alloc] initWithFrame:[self bounds]];
		passcodeButton.bounds = CGRectInset(passcodeButton.frame, 12, 7);
		[passcodeButton setImage:[UIImage imageWithContentsOfFile:@"/Library/AmongLock/passcodeButtonOn.png"]];

		if (![passcodeButton isDescendantOfView:self]) [self addSubview:passcodeButton];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.6 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		passcodeButton = [[UIImageView alloc] initWithFrame:[self bounds]];
		passcodeButton.bounds = CGRectInset(passcodeButton.frame, 12, 7);
		[passcodeButton setImage:[UIImage imageWithContentsOfFile:@"/Library/AmongLock/passcodeButtonFailed.png"]];

		if (![passcodeButton isDescendantOfView:self]) [self addSubview:passcodeButton];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.9 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		passcodeButton = [[UIImageView alloc] initWithFrame:[self bounds]];
		passcodeButton.bounds = CGRectInset(passcodeButton.frame, 12, 7);
		[passcodeButton setImage:[UIImage imageWithContentsOfFile:@"/Library/AmongLock/passcodeButtonOn.png"]];

		if (![passcodeButton isDescendantOfView:self]) [self addSubview:passcodeButton];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		passcodeButton = [[UIImageView alloc] initWithFrame:[self bounds]];
		passcodeButton.bounds = CGRectInset(passcodeButton.frame, 12, 7);
		[passcodeButton setImage:[UIImage imageWithContentsOfFile:@"/Library/AmongLock/passcodeButtonOff.png"]];

		if (![passcodeButton isDescendantOfView:self]) [self addSubview:passcodeButton];
	});

}

%end

%hook TPNumberPadButton

- (void)setColor:(UIColor *)arg1 { // remove passcode button background

	%orig(nil);

}

%end

// %hook SBUIPasscodeLockNumberPad

// - (void)didMoveToWindow { // add emergency, backspace and cancel button image

// 	%orig;

// 	SBUIButton* emergencyButton = MSHookIvar<SBUIButton *>(self, "_emergencyCallButton");
// 	SBUIButton* backspaceButton = MSHookIvar<SBUIButton *>(self, "_backspaceButton");
// 	SBUIButton* cancelButton = MSHookIvar<SBUIButton *>(self, "_cancelButton");

// 	[emergencyButton removeFromSuperview];
// 	[backspaceButton removeFromSuperview];
// 	[cancelButton removeFromSuperview];

// }

// %end

%hook SBLockScreenManager

- (void)attemptUnlockWithPasscode:(id)arg1 finishUIUnlock:(BOOL)arg2 completion:(id)arg3 { // show video after failed attempt, stop background video playback when passcode view disappears and play sound

	%orig;

	if ([self isUILocked]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"amonglockFailedAttemptAnimation" object:nil];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			[ejectionPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];
			[ejectionPlayerLayer setHidden:NO];
			[ejectionPlayer play];
		});

		SystemSoundID sound = 0;
		AudioServicesDisposeSystemSoundID(sound);
		AudioServicesCreateSystemSoundID((CFURLRef) CFBridgingRetain([NSURL fileURLWithPath:@"/Library/AmongLock/wrongPasscode.mp3"]), &sound);
		AudioServicesPlaySystemSound((SystemSoundID)sound);
	} else {
		[ejectionPlayerLayer setHidden:YES];
		[ejectionPlayer pause];
		[ejectionPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];

		if (!useAsWallpaperSwitch) {
			[backgroundPlayerLayer setHidden:YES];
			[backgroundPlayer pause];
			[backgroundPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];
		}

		SystemSoundID sound = 0;
		AudioServicesDisposeSystemSoundID(sound);
		AudioServicesCreateSystemSoundID((CFURLRef) CFBridgingRetain([NSURL fileURLWithPath:@"/Library/AmongLock/passcodeDisappeared.mp3"]), &sound);
		AudioServicesPlaySystemSound((SystemSoundID)sound);
	}

}

%end

%hook SBUIPasscodeLockViewBase

- (void)_sendDelegateKeypadKeyDown { // play random button sound when pressing passcode button

	%orig;

	SystemSoundID sound = 0;
	AudioServicesDisposeSystemSoundID(sound);
	AudioServicesCreateSystemSoundID((CFURLRef) CFBridgingRetain([NSURL fileURLWithPath:[NSString stringWithFormat:@"/Library/AmongLock/button%d.mp3", arc4random_uniform(4)]]), &sound);
	AudioServicesPlaySystemSound((SystemSoundID)sound);

}

%end

%hook SBUIPasscodeBiometricResource

- (BOOL)hasBiometricAuthenticationCapabilityEnabled { // disable faceid animation when swiping up

	return NO;

}

%end

%hook SBUIProudLockIconView

- (id)initWithFrame:(CGRect)frame { // add notification observer

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"amonglockHideElements" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"amonglockUnhideElements" object:nil];

	return %orig;

}

%new
- (void)receiveHideNotification:(NSNotification *)notification { // hide or unhide faceid lock

	if ([notification.name isEqual:@"amonglockHideElements"])
		[self setHidden:YES];
	else if ([notification.name isEqual:@"amonglockUnhideElements"])
		[self setHidden:NO];

}

- (void)dealloc { // remove observer
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	%orig;

}

%end

%hook SBFLockScreenDateView

- (id)initWithFrame:(CGRect)frame { // add notification observer

	if (useAsWallpaperSwitch) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"amonglockHideElements" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"amonglockUnhideElements" object:nil];
	}

	return %orig;

}

%new
- (void)receiveHideNotification:(NSNotification *)notification { // hide or unhide homebar

	if ([notification.name isEqual:@"amonglockHideElements"])
		[self setHidden:YES];
	else if ([notification.name isEqual:@"amonglockUnhideElements"])
		[self setHidden:NO];

}

- (void)dealloc { // remove observer
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	%orig;

}

%end

%hook SBUIPasscodeLockViewWithKeypad

- (void)setStatusTitleView:(UILabel *)arg1 { // hide enter passcode text

	%orig(nil);

}

- (void)touchesBegan:(id)arg1 withEvent:(id)arg2 { // hide ejection video when tapping the bottom of the screen

	%orig;

	if (![ejectionPlayerLayer isHidden]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"amonglockFailedAttemptReset" object:nil];
		[ejectionPlayerLayer setHidden:YES];
		[ejectionPlayer pause];
		[ejectionPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];
	}

}

%end

%hook CSQuickActionsButton

- (id)initWithFrame:(CGRect)frame { // add notification observer

	if (useAsWallpaperSwitch) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"amonglockHideElements" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"amonglockUnhideElements" object:nil];
	}

	return %orig;

}

%new
- (void)receiveHideNotification:(NSNotification *)notification { // hide or unhide homebar

	if ([notification.name isEqual:@"amonglockHideElements"])
		[self setHidden:YES];
	else if ([notification.name isEqual:@"amonglockUnhideElements"])
		[self setHidden:NO];

}

- (void)dealloc { // remove observer
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	%orig;

}

%end

%hook CSTeachableMomentsContainerView

- (id)initWithFrame:(CGRect)frame { // add notification observer

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"amonglockHideElements" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideNotification:) name:@"amonglockUnhideElements" object:nil];

	return %orig;

}

%new
- (void)receiveHideNotification:(NSNotification *)notification { // hide or unhide homebar

	if ([notification.name isEqual:@"amonglockHideElements"])
		[self setHidden:YES];
	else if ([notification.name isEqual:@"amonglockUnhideElements"])
		[self setHidden:NO];

}

- (void)dealloc { // remove observer
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	%orig;

}

%end

%end

%ctor {

	preferences = [[HBPreferences alloc] initWithIdentifier:@"love.litten.amonglockpreferences"];

	[preferences registerBool:&enabled default:nil forKey:@"Enabled"];

	// Background
	[preferences registerBool:&useAsWallpaperSwitch default:NO forKey:@"useAsWallpaper"];

	if (enabled) {
		%init(AmongLock);
	}

}