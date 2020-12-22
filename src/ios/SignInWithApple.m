#import <AuthenticationServices/AuthenticationServices.h>
#import <Cordova/CDVPlugin.h> // this already includes Foundation.h

@interface SignInWithApple : CDVPlugin <ASAuthorizationControllerDelegate> {
  NSMutableString *_callbackId;
}
@end

@implementation SignInWithApple
- (void)pluginInitialize {
  NSLog(@"SignInWithApple initialize");
}

- (NSArray<ASAuthorizationScope> *)convertScopes:(NSArray<NSNumber *> *)scopes API_AVAILABLE(ios(13.0)) {
  NSMutableArray<ASAuthorizationScope> *convertedScopes = [NSMutableArray array];

  for (NSNumber *scope in scopes) {
    ASAuthorizationScope convertedScope = [self convertScope:scope];
    if (convertedScope != nil) {
      [convertedScopes addObject:convertedScope];
    }
  }

  return convertedScopes;
}

- (ASAuthorizationScope)convertScope:(NSNumber *)scope API_AVAILABLE(ios(13.0)) {
  switch (scope.integerValue) {
    case 0:
      return ASAuthorizationScopeFullName;
    case 1:
      return ASAuthorizationScopeEmail;
    default:
      return nil;
  }
}

- (void)isAvailable:(CDVInvokedUrlCommand *)command {
  _callbackId = [NSMutableString stringWithString:command.callbackId];

  BOOL returnValue = YES;
  if (@available(iOS 13.0, *)) {
    returnValue = NO;
  }
    
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsBool:returnValue];
  [self.commandDelegate sendPluginResult:pluginResult
                              callbackId:command.callbackId];
}

- (void)signin:(CDVInvokedUrlCommand *)command {
  NSDictionary *options = command.arguments[0];
  NSLog(@"SignInWithApple signin()");

  if (@available(iOS 13, *)) {
    _callbackId = [NSMutableString stringWithString:command.callbackId];

    ASAuthorizationAppleIDProvider *provider = [[ASAuthorizationAppleIDProvider alloc] init];
    ASAuthorizationAppleIDRequest *request = [provider createRequest];

    if (options[@"requestedScopes"]) {
        request.requestedScopes = [self convertScopes:options[@"requestedScopes"]];
    }

    ASAuthorizationController *controller = [[ASAuthorizationController alloc]
        initWithAuthorizationRequests:@[ request ]];
    controller.delegate = self;
    [controller performRequests];
  } else {
    NSLog(@"SignInWithApple signin() ignored because your iOS version < 13");

    CDVPluginResult *result =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                      messageAsDictionary:@{
                        @"error" : @"PLUGIN_ERROR",
                        @"code" : @"",
                        @"localizedDescription" : @"",
                        @"localizedFailureReason" : @"",
                      }];
    [self.commandDelegate sendPluginResult:result
                                callbackId:command.callbackId];
  }
}

- (void)authorizationController:(ASAuthorizationController *)controller
    didCompleteWithAuthorization:(nonnull ASAuthorization *)authorization
    API_AVAILABLE(ios(13.0)) {
  ASAuthorizationAppleIDCredential *appleIDCredential = [authorization credential];

  NSDictionary *fullName;
  NSDictionary *fullNamePhonetic;
  if (appleIDCredential.fullName) {
    if (appleIDCredential.fullName.phoneticRepresentation) {
      fullNamePhonetic = @{
        @"namePrefix" : appleIDCredential.fullName.phoneticRepresentation.namePrefix ?: @"",
        @"givenName" : appleIDCredential.fullName.phoneticRepresentation.givenName ?: @"",
        @"middleName" : appleIDCredential.fullName.phoneticRepresentation.middleName ?: @"",
        @"familyName" : appleIDCredential.fullName.phoneticRepresentation.familyName ?: @"",
        @"nameSuffix" : appleIDCredential.fullName.phoneticRepresentation.nameSuffix ?: @"",
        @"nickname" : appleIDCredential.fullName.phoneticRepresentation.nickname ?: @""
      };
    }
    fullName = @{
      @"namePrefix" : appleIDCredential.fullName.namePrefix ?: @"",
      @"givenName" : appleIDCredential.fullName.givenName ?: @"",
      @"middleName" : appleIDCredential.fullName.middleName ?: @"",
      @"familyName" : appleIDCredential.fullName.familyName ?: @"",
      @"nameSuffix" : appleIDCredential.fullName.nameSuffix ?: @"",
      @"nickname" : appleIDCredential.fullName.nickname ?: @"",
      @"phoneticRepresentation" : fullNamePhonetic ?: @{}
    };
  }
  NSString *identityToken =
      [[NSString alloc] initWithData:appleIDCredential.identityToken
                            encoding:NSUTF8StringEncoding];
  NSString *authorizationCode =
      [[NSString alloc] initWithData:appleIDCredential.authorizationCode
                            encoding:NSUTF8StringEncoding];
  NSDictionary *dic = @{
    @"user" : appleIDCredential.user ?: @"",
    @"state" : appleIDCredential.state ?: @"",
    @"fullName" : fullName ?: @{},
    @"email" : appleIDCredential.email ?: @"",
    @"identityToken" : identityToken,
    @"authorizationCode" : authorizationCode
  };

  CDVPluginResult *result =
      [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                    messageAsDictionary:dic];
  [self.commandDelegate sendPluginResult:result callbackId:_callbackId];
}

- (void)authorizationController:(ASAuthorizationController *)controller
           didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0)) {
  NSLog(@" error => %@ ", [error localizedDescription]);

  CDVPluginResult *result =
      [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                    messageAsDictionary:@{
                      @"error" : @"ASAUTHORIZATION_ERROR",
                      @"code" : error.code
                          ? [NSString stringWithFormat:@"%ld", (long)error.code]
                          : @"",
                      @"localizedDescription" : error.localizedDescription ?: @"",
                      @"localizedFailureReason" : error.localizedFailureReason ?: @"",
                    }];
  [self.commandDelegate sendPluginResult:result callbackId:_callbackId];
}

@end
