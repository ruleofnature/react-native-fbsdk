#import "RCTFBSDKLoginButtonManager.h"

#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTUtils.h>
#import <React/UIView+React.h>

#import "RCTConvert+FBSDKLogin.h"

@implementation RCTFBSDKLoginButtonManager

RCT_EXPORT_MODULE(RCTFBLoginButton)

#pragma mark - Object Lifecycle

- (UIView *)view
{
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.delegate = self;
    return loginButton;
}

#pragma mark - Properties

RCT_EXPORT_VIEW_PROPERTY(readPermissions, NSStringArray)

RCT_EXPORT_VIEW_PROPERTY(publishPermissions, NSStringArray)

RCT_CUSTOM_VIEW_PROPERTY(loginBehaviorIOS, FBSDKLoginBehavior, FBSDKLoginButton)
{
    [view setLoginBehavior:json ? [RCTConvert FBSDKLoginBehavior:json] : FBSDKLoginBehaviorBrowser];
}

RCT_EXPORT_VIEW_PROPERTY(defaultAudience, FBSDKDefaultAudience)

RCT_CUSTOM_VIEW_PROPERTY(tooltipBehaviorIOS, FBSDKLoginButtonTooltipBehavior, FBSDKLoginButton)
{
    [view setTooltipBehavior:json ? [RCTConvert FBSDKLoginButtonTooltipBehavior:json] : FBSDKLoginButtonTooltipBehaviorAutomatic];
}

#pragma mark - FBSDKLoginButtonDelegate

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    NSDictionary *event = @{
                            @"type": @"loginFinished",
                            @"target": loginButton.reactTag,
                            @"error": error ? RCTJSErrorFromNSError(error) : [NSNull null],
                            @"result": error ? [NSNull null] : @{
                                    @"isCancelled": @(result.isCancelled),
                                    @"grantedPermissions": result.isCancelled ? [NSNull null] : result.grantedPermissions.allObjects,
                                    @"declinedPermissions": result.isCancelled ? [NSNull null] : result.declinedPermissions.allObjects,
                                    },
                            };
    
    [self.bridge.eventDispatcher sendInputEventWithName:@"topChange" body:event];
    [self.bridge.eventDispatcher sendEvent:event];
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    NSDictionary *event = @{
                            @"target": loginButton.reactTag,
                            };
    
    [self.bridge.eventDispatcher sendInputEventWithName:@"topChange" body:event];
    [self.bridge.eventDispatcher sendEvent:event];
}

@end
