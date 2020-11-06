#import "AmongLock.h"

%group AmongLock

%hook CSPasscodeViewController

- (void)viewDidLoad { // add video players

	%orig;

	// background video
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


	// ejection video
	NSString* ejectionFilePath = [NSString stringWithFormat:@"/Library/AmongLock/ejectionX3.mp4"];
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

	[backgroundPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];
	[backgroundPlayerLayer setHidden:NO];
	[backgroundPlayer play];

	SystemSoundID sound = 0;
	AudioServicesDisposeSystemSoundID(sound);
	AudioServicesCreateSystemSoundID((CFURLRef) CFBridgingRetain([NSURL fileURLWithPath:@"/Library/AmongLock/passcodeAppeared.mp3"]), &sound);
	AudioServicesPlaySystemSound((SystemSoundID)sound);

}

- (void)viewWillDisappear:(BOOL)animated { // unhide faceid lock and homebar when passcode disappears

	%orig;

	[[NSNotificationCenter defaultCenter] postNotificationName:@"amonglockUnhideElements" object:nil];

}

%new
- (void)ejectionVideoFinishedPlaying { // hide ejection video when done playing

	[ejectionPlayerLayer setHidden:YES];
	[ejectionPlayer pause];
	[ejectionPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];

}

%end

%hook SBNumberPadWithDelegate

// - (void)setFrame:(CGRect)frame {

// 	CGRect newFrame = frame;
// 	newFrame.origin.y += 130;

// 	%orig(newFrame);

// }

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

}

%new
- (void)changePasscodeButtonImages {

	passcodeButton = [[UIImageView alloc] initWithFrame:[self bounds]];
	passcodeButton.bounds = CGRectInset(passcodeButton.frame, 12, 7);
	[passcodeButton setImage:[UIImage imageWithContentsOfFile:@"/Library/AmongLock/passcodeButtonOn.png"]];

	if (![passcodeButton isDescendantOfView:self]) [self addSubview:passcodeButton];

}

%end

%hook TPNumberPadButton

- (void)setColor:(UIColor *)arg1 { // remove passcode button background

	%orig(nil);

}

%end

%hook SBUIPasscodeLockNumberPad

- (void)didMoveToWindow { // add emergency, backspace and cancel button image

	%orig;

	SBUIButton* emergencyButton = MSHookIvar<SBUIButton *>(self, "_emergencyCallButton");
	SBUIButton* backspaceButton = MSHookIvar<SBUIButton *>(self, "_backspaceButton");
	SBUIButton* cancelButton = MSHookIvar<SBUIButton *>(self, "_cancelButton");

	[emergencyButton removeFromSuperview];
	[backspaceButton removeFromSuperview];
	[cancelButton removeFromSuperview];

	// emergencyButtonImage = [[UIImageView alloc] initWithFrame:[emergencyButton bounds]];
	// [emergencyButtonImage setImage:[UIImage imageWithContentsOfFile:@"/Library/AmongLock/passcodeButton.png"]];
	// emergencyButtonImage.bounds = CGRectInset(emergencyButtonImage.frame, 15, 10);
	// if (![emergencyButtonImage isDescendantOfView:emergencyButton]) [emergencyButton addSubview:emergencyButtonImage];

	// backspaceButtonImage = [[UIImageView alloc] initWithFrame:[backspaceButton bounds]];
	// [backspaceButtonImage setImage:[UIImage imageWithContentsOfFile:@"/Library/AmongLock/passcodeButton.png"]];
	// backspaceButtonImage.bounds = CGRectInset(backspaceButtonImage.frame, 15, 10);
	// if (![backspaceButtonImage isDescendantOfView:backspaceButton]) [backspaceButton addSubview:backspaceButtonImage];

	// cancelButtonImage = [[UIImageView alloc] initWithFrame:[cancelButton bounds]];
	// [cancelButtonImage setImage:[UIImage imageWithContentsOfFile:@"/Library/AmongLock/passcodeButton.png"]];
	// cancelButtonImage.bounds = CGRectInset(cancelButtonImage.frame, 15, 10);
	// if (![cancelButtonImage isDescendantOfView:cancelButton]) [cancelButton addSubview:cancelButtonImage];

}

%end

%hook SBLockScreenManager

- (void)attemptUnlockWithPasscode:(id)arg1 finishUIUnlock:(BOOL)arg2 completion:(id)arg3 { // show video after failed attempt, stop background video playback when passcode view disappears and play sound

	%orig;

	if ([self isUILocked]) {
		[ejectionPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];
		[ejectionPlayerLayer setHidden:NO];
		[ejectionPlayer play];

		SystemSoundID sound = 0;
		AudioServicesDisposeSystemSoundID(sound);
		AudioServicesCreateSystemSoundID((CFURLRef) CFBridgingRetain([NSURL fileURLWithPath:@"/Library/AmongLock/wrongPasscode.mp3"]), &sound);
		AudioServicesPlaySystemSound((SystemSoundID)sound);
	} else {
		[ejectionPlayerLayer setHidden:YES];
		[ejectionPlayer pause];
		[ejectionPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];

		[backgroundPlayerLayer setHidden:YES];
		[backgroundPlayer pause];
		[backgroundPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];

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

%hook SBUIPasscodeLockViewWithKeypad

- (void)setStatusTitleView:(UILabel *)arg1 { // hide enter passcode text

	%orig(nil);

}

- (void)touchesBegan:(id)arg1 withEvent:(id)arg2 { // hide ejection video when tapping the bottom of the screen

	%orig;

	if (![ejectionPlayerLayer isHidden]) {
		[ejectionPlayerLayer setHidden:YES];
		[ejectionPlayer pause];
		[ejectionPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];
	}

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

%hook SBUIPasscodeBiometricResource

- (BOOL)hasBiometricAuthenticationCapabilityEnabled { // disable faceid animation when swiping up

	return NO;

}

%end

%end

%ctor {

	%init(AmongLock);

}