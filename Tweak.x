#import "AmongLock.h"

%group AmongLock

%hook CSPasscodeViewController

- (void)viewDidLoad { // add video players

	%orig;

	// background video
	NSString* backgroundFilePath = [NSString stringWithFormat:@"/Library/AmongLock/background.mp4"];
    NSURL* backgroundUrl = [NSURL fileURLWithPath:backgroundFilePath];

    if (!backgroundPlayerItem) backgroundPlayerItem = [AVPlayerItem playerItemWithURL:backgroundUrl];

    if (!backgroundPlayer) backgroundPlayer = [AVPlayer playerWithPlayerItem:backgroundPlayerItem];
    [backgroundPlayer setVolume:0.0];

    if (!backgroundPlayerLayer) backgroundPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:backgroundPlayer];
    [backgroundPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [backgroundPlayerLayer setFrame:[[[self view] layer] bounds]];
	[backgroundPlayerLayer setHidden:YES];

    [[[self view] layer] insertSublayer:backgroundPlayerLayer atIndex:1];


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

}

- (void)viewWillAppear:(BOOL)animated { // start background video playback when passcode view appears

	%orig;

	[backgroundPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];
	[backgroundPlayerLayer setHidden:NO];
	[backgroundPlayer play];

}

- (void)viewWillDisappear:(BOOL)animated { // stop background video playback when passcode view disappears

	%orig;

	[backgroundPlayerLayer setHidden:YES];
	[backgroundPlayer pause];
	[backgroundPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];

}

%end

%hook SBLockScreenManager

- (void)attemptUnlockWithPasscode:(id)arg1 finishUIUnlock:(BOOL)arg2 completion:(id)arg3 { // show video after failed attempt

	%orig;

	if ([self isUILocked]) {
		[ejectionPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];
		[ejectionPlayerLayer setHidden:NO];
		[ejectionPlayer play];
	} else {
		[ejectionPlayerLayer setHidden:YES];
		[ejectionPlayer pause];
		[ejectionPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];
	}

}

%end

%hook SBUIPasscodeLockViewBase 

- (void)_sendDelegateKeypadKeyDown { // play random button sound

	%orig;

	int randomNumber = arc4random_uniform(4);
	SystemSoundID sound = 0;
	AudioServicesDisposeSystemSoundID(sound);
	AudioServicesCreateSystemSoundID((CFURLRef) CFBridgingRetain([NSURL fileURLWithPath:[NSString stringWithFormat:@"/Library/AmongLock/button%d", randomNumber]]), &sound);
	AudioServicesPlaySystemSound((SystemSoundID)sound);

}

%end

%hook SBUIPasscodeBiometricResource

- (BOOL)hasBiometricAuthenticationCapabilityEnabled { // disable face id animation when swiping up

	return NO;

}

%end

%end

%ctor {

	%init(AmongLock);

}