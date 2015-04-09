/**
 * @class      SimplePlayerViewController SimplePlayerViewController.m "SimplePlayerViewController.m"
 * @brief      A Player that can be used to simply load an embed code and play it
 * @details    SimplePlayerViewController in Ooyala Sample Apps
 * @date       12/12/14
 * @copyright  Copyright (c) 2014 Ooyala, Inc. All rights reserved.
 */


#import "FreewheelPlayerViewController.h"
#import <OoyalaSDK/OOOoyalaPlayerViewController.h>
#import <OoyalaSDK/OOOoyalaPlayer.h>
#import <OoyalaSDK/OOPlayerDomain.h>
#import <OoyalaFreewheelSDK/OOFreewheelManager.h>

@interface FreewheelPlayerViewController ()
@property OOOoyalaPlayerViewController *ooyalaPlayerViewController;
@property (nonatomic) OOFreewheelManager *adsManager;
@property NSString *embedCode;
@property NSString *nib;
@property NSString *pcode;
@property NSString *playerDomain;
@end

@implementation FreewheelPlayerViewController

#pragma mark - Init player from Nib
- (id)initWithPlayerSelectionOption:(PlayerSelectionOption *)playerSelectionOption {
    self = [super initWithPlayerSelectionOption: playerSelectionOption];
    self.nib = @"PlayerSimple";
    
    // changed the PCODE
    self.pcode =@"R3ZHExOjHcfMbqoMxpYBE7PbDEyB";
    
    //Player domain same as AccedoODC team code.
    self.playerDomain = @"http://www.ooyala.com";
    
    if (self.playerSelectionOption) {
        
        //changing the embed code  - Movie Name - " Fear X "
        self.embedCode = @"5qYnhxczrXraqNWF98-S_QNHAeR5k6sM";
        // Can use Embed code same as Andriod Sample : @"NwNnRiczqVVb9EtAZPEf-MzHK9iFlE4i";(TV Asset)
        
        self.title = self.playerSelectionOption.title;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    [[NSBundle mainBundle] loadNibNamed:self.nib owner:self options:nil];
}

#pragma mark - Observers for  Ooyala Player
/**
 *  adding Observervers to the Player to get the notifications
 */
-(void)addObserversForOoyalaVideoplayer
{
    // Language Change Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChangeNotificationHandler:) name:OOOoyalaPlayerLanguageChangedNotification object:_ooyalaPlayerViewController.player];
    
    // To Listen all Player Error notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerErrorHandler:)name:OOOoyalaPlayerErrorNotification object:nil];
    
    
    // Play back completed notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackCompleteHandler:) name:OOOoyalaPlayerPlayCompletedNotification object:_ooyalaPlayerViewController.player];
    
    if (!(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
    {
        [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(closeFullscreen:) name:OOOoyalaPlayerViewControllerFullscreenExit object:self.ooyalaPlayerViewController];
    }
}

/**
 *  Removes Added Observer for Player
 */
- (void)removeObserversForOoyalaVideoplayer
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OOOoyalaPlayerLanguageChangedNotification object:self.ooyalaPlayerViewController.player];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:nil object:_ooyalaPlayerViewController.player];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:OOOoyalaPlayerErrorNotification object:nil];
    
    // removing the omniture notifier from Observers Eye
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OmnitureNotification" object:_ooyalaPlayerViewController.player];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OOOoyalaPlayerPlayCompletedNotification object:self.ooyalaPlayerViewController.player];
    
    if (!(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:OOOoyalaPlayerViewControllerFullscreenExit object:self.ooyalaPlayerViewController.player];
        
    }
    
}

#pragma mark  - View Did load
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create Ooyala ViewController
    OOOoyalaPlayer *player = [[OOOoyalaPlayer alloc] initWithPcode:self.pcode domain:[[OOPlayerDomain alloc] initWithString:self.playerDomain]];
    self.ooyalaPlayerViewController = [[OOOoyalaPlayerViewController alloc] initWithPlayer:player];
    
    // Adding Observers to track player functions
    [self addObserversForOoyalaVideoplayer];
    
    // Attach it to current view
    [self addChildViewController:_ooyalaPlayerViewController];
    [self.playerView addSubview:_ooyalaPlayerViewController.view];
    [self.ooyalaPlayerViewController.view setFrame:self.playerView.bounds];
    
    self.adsManager = [[OOFreewheelManager alloc] initWithOoyalaPlayerViewController:self.ooyalaPlayerViewController];
    
    //Setting FreeWheel parameter  - AccedoODC
    NSMutableDictionary *fwParameters = [[NSMutableDictionary alloc] init];
    
    [fwParameters setObject:@"382101"forKey:@"fw_ios_mrm_network_id"];
    [fwParameters setObject:@"5d494.v.fwmrm.net" forKey:@"fw_ios_ad_server"];
    [fwParameters setObject:@"382101:hott_ios_live" forKey:@"fw_ios_player_profile"];
    [fwParameters setObject:self.embedCode forKey:@"fw_ios_video_asset_id"];
    
    if ( (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)){
        [fwParameters setObject:@"dtv_ipad" forKey:@"fw_ios_site_section_id"];
    }
    else{
        [fwParameters setObject:@"dtv_iphone" forKey:@"fw_ios_site_section_id"];
    }
    
    [self.adsManager overrideFreewheelParameters:fwParameters];
    
    // Load the video
    [_ooyalaPlayerViewController.player setEmbedCode:self.embedCode];
    [_ooyalaPlayerViewController.player play];
}

#pragma mark  - Notification Handler - Functions
- (void) playbackCompleteHandler:(NSNotification*) notifiation{
    
    [self performCloseAction];
}


/**
 *  Close full screen Recieved from Player
 *  @param notification notification
 */
-(void) closeFullscreen:(NSNotification*)notification
{
    [self.ooyalaPlayerViewController dismissViewControllerAnimated:NO completion:nil];
    [self performSelector:@selector(performCloseAction) withObject:nil afterDelay:1.0];
}

/**
 *  Language Notification Recived from the Player
 *  @param notification notification
 */
- (void) languageChangeNotificationHandler:(NSNotification*)notification
{
    if ([notification.name isEqualToString:OOOoyalaPlayerLanguageChangedNotification]){
        NSArray* availableLanaguegs = [self.ooyalaPlayerViewController.player availableClosedCaptionsLanguages];
        for (NSString *language in availableLanaguegs){
            [self.ooyalaPlayerViewController.player setClosedCaptionsLanguage:language];
        }
        return;
    }
}

/**
 *  Error Notification Recived from the Player
 *  @param notification notification
 */
- (void) playerErrorHandler:(NSNotification*) notifiation{
    
    // Will be showing the Alert and the descriptions
    NSLog(@"Player Error");
    NSLog(@"Error Description %@:",self.ooyalaPlayerViewController.player.error);
    NSString *errorDes =   [NSString stringWithFormat:@"%@",self.ooyalaPlayerViewController.player.error];
    [[[UIAlertView alloc]initWithTitle:@"Alert!" message:errorDes delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
}


#pragma mark - Perform Close Action
/**
 *  Close action to close the Player
 */
-(void)performCloseAction{
    
    [self.ooyalaPlayerViewController.player pause];
    [_ooyalaPlayerViewController setFullscreen:FALSE];
    
    // removed the observer
    [self removeObserversForOoyalaVideoplayer];
    
    //    if(_isContinueWatching)
    //    {
    //        [self.delegate stoppedVideoAtIndex:self.indexOfVideo AtDuration:[NSNumber numberWithFloat:self.ooyalaPlayerViewController.player.playheadTime ]];
    //    }
    
    [self.ooyalaPlayerViewController.view removeFromSuperview];
    [self.ooyalaPlayerViewController removeFromParentViewController];
    [_ooyalaPlayerViewController removeFromParentViewController];
    self.ooyalaPlayerViewController = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

@end
