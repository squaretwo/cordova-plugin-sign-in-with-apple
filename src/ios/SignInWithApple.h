#import <AuthenticationServices/AuthenticationServices.h>
#import <Cordova/CDVPlugin.h> // this already includes Foundation.h

#ifndef SignInWithApple_h
#define SignInWithApple_h

@interface SignInWithApple : CDVPlugin <ASAuthorizationControllerDelegate>
- (void)pluginInitialize;
- (NSArray<ASAuthorizationScope> *)convertScopes:(NSArray<NSNumber *> *)scopes API_AVAILABLE(ios(13.0));
- (void)isAvailable(CDVInvokedUrlCommand *)command;
- (void)signin:(CDVInvokedUrlCommand *)command;
@end

#endif /* SignInWithApple_h */
