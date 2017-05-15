#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMock/OCMock.h>
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "MSAppDelegateForwarderPrivate.h"
#import "MSAppDelegate.h"
#import "MSMockCustomAppDelegate.h"
#import "MSMockOriginalAppDelegate.h"
#import "MSUtility+Application.h"

@interface MSAppDelegateForwarderTest : XCTestCase

@property(nonatomic) MSMockOriginalAppDelegate *originalAppDelegateMock;
@property(nonatomic) MSMockCustomAppDelegate *customAppDelegateMock;
@property(nonatomic) UIApplication *appMock;

@end

/*
 * We use of blocks for test validition but test frameworks contain macro capturing self that we can't avoid.
 * Ignoring retain cycle warning for this test code.
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"

@implementation MSAppDelegateForwarderTest

- (void)setUp {
  [super setUp];

  // Mock app delegate.
  self.appMock = OCMClassMock([UIApplication class]);
  self.originalAppDelegateMock = [MSMockOriginalAppDelegate new];
  self.customAppDelegateMock = [MSMockCustomAppDelegate new];
  id utilMock = OCMClassMock([MSUtility class]);
  OCMStub([utilMock sharedAppDelegate]).andReturn(self.originalAppDelegateMock);
}

- (void)tearDown {

  // Clear delegates.
  MSAppDelegateForwarder.delegates = [NSHashTable new];
  [super tearDown];
}

- (void)testAddAppDelegateSelectorToSwizzle {

  // If
  NSUInteger currentCount = MSAppDelegateForwarder.selectorsToSwizzle.count;
  SEL expectedSelector = @selector(testAddAppDelegateSelectorToSwizzle);
  NSString *expectedSelectorStr = NSStringFromSelector(expectedSelector);

  // Then
  assertThatBool([MSAppDelegateForwarder.selectorsToSwizzle containsObject:expectedSelectorStr], isFalse());

  // When
  [MSAppDelegateForwarder addAppDelegateSelectorToSwizzle:expectedSelector];

  // Then
  assertThatInteger(MSAppDelegateForwarder.selectorsToSwizzle.count, equalToInteger(currentCount + 1));
  assertThatBool([MSAppDelegateForwarder.selectorsToSwizzle containsObject:expectedSelectorStr], isTrue());

  // When
  [MSAppDelegateForwarder addAppDelegateSelectorToSwizzle:expectedSelector];

  // Then
  assertThatInteger(MSAppDelegateForwarder.selectorsToSwizzle.count, equalToInteger(currentCount + 1));
  assertThatBool([MSAppDelegateForwarder.selectorsToSwizzle containsObject:expectedSelectorStr], isTrue());
  [MSAppDelegateForwarder.selectorsToSwizzle removeObject:expectedSelectorStr];
}

- (void)testForwardUnknownSelector {

  /*
   * If
   */

  // Calling an unknown selector on the forwarder must still throw an exception.
  XCTestExpectation *exceptionCaughtExpectation =
      [self expectationWithDescription:@"Caught!! That exception will go nowhere."];

  /*
   * When
   */
  @try {
    [[MSAppDelegateForwarder new] performSelector:@selector(testForwardUnknownSelector)];
  } @catch (NSException *ex) {

    /*
     * Then
     */
    assertThat(ex.name, is(NSInvalidArgumentException));
    assertThatBool([ex.reason containsString:@"unrecognized selector sent"], isTrue());
    [exceptionCaughtExpectation fulfill];
  }
  [self waitForExpectations:@[ exceptionCaughtExpectation ] timeout:1];
}

- (void)testWithoutCustomDelegate {

  // If
  NSURL *expectedURL = [NSURL URLWithString:@"https://www.contoso.com/sending-positive-waves"];
  NSDictionary *expectedAnnotation = @{};
  BOOL expectedReturnedValue = YES;
  UIApplication *appMock = self.appMock;
  XCTestExpectation *originalCalledExpectation = [self expectationWithDescription:@"Original delegate called."];
  NSString *originalOpenURLiOS42Selector =
      NSStringFromSelector(@selector(application:openURL:sourceApplication:annotation:));
  self.originalAppDelegateMock.delegateValidators[originalOpenURLiOS42Selector] =
      ^(UIApplication *application, NSURL *url, NSString *sApplication, id annotation) {

        // Then
        assertThat(application, is(appMock));
        assertThat(url, is(expectedURL));
        assertThat(sApplication, nilValue());
        assertThat(annotation, is(expectedAnnotation));
        [originalCalledExpectation fulfill];
        return expectedReturnedValue;
      };

  // When
  BOOL returnedValue = [self.originalAppDelegateMock application:self.appMock
                                                         openURL:expectedURL
                                               sourceApplication:nil
                                                      annotation:expectedAnnotation];

  // Then
  assertThatInt(MSAppDelegateForwarder.delegates.count, equalToInt(0));
  assertThatBool(returnedValue, is(@(expectedReturnedValue)));
  [self waitForExpectations:@[ originalCalledExpectation ] timeout:1];
}

- (void)testWithOneCustomDelegate {

  // If
  NSURL *expectedURL = [NSURL URLWithString:@"https://www.contoso.com/sending-positive-waves"];
  NSDictionary *expectedAnnotation = @{};
  BOOL expectedReturnedValue = YES;
  UIApplication *appMock = self.appMock;
  XCTestExpectation *originalCalledExpectation = [self expectationWithDescription:@"Original delegate called."];
  XCTestExpectation *customCalledExpectation = [self expectationWithDescription:@"Custom delegate called."];
  NSString *originalOpenURLiOS42Selector =
      NSStringFromSelector(@selector(application:openURL:sourceApplication:annotation:));
  self.originalAppDelegateMock.delegateValidators[originalOpenURLiOS42Selector] =
      ^(UIApplication *application, NSURL *url, NSString *sApplication, id annotation) {

        // Then
        assertThat(application, is(appMock));
        assertThat(url, is(expectedURL));
        assertThat(sApplication, nilValue());
        assertThat(annotation, is(expectedAnnotation));
        [originalCalledExpectation fulfill];
        return expectedReturnedValue;
      };
  NSString *customOpenURLiOS42Selector =
      NSStringFromSelector(@selector(application:openURL:sourceApplication:annotation:returnedValue:));
  self.customAppDelegateMock.delegateValidators[customOpenURLiOS42Selector] =
      ^(UIApplication *application, NSURL *url, NSString *sApplication, id annotation, BOOL returnedValue) {

        // Then
        assertThat(application, is(appMock));
        assertThat(url, is(expectedURL));
        assertThat(sApplication, nilValue());
        assertThat(annotation, is(expectedAnnotation));
        assertThatBool(returnedValue, is(@(expectedReturnedValue)));
        [customCalledExpectation fulfill];
        return expectedReturnedValue;
      };
  [MSAppDelegateForwarder swizzleOriginalDelegate:self.originalAppDelegateMock];
  [MSAppDelegateForwarder addDelegate:self.customAppDelegateMock];

  // When
  BOOL returnedValue = [self.originalAppDelegateMock application:self.appMock
                                                         openURL:expectedURL
                                               sourceApplication:nil
                                                      annotation:expectedAnnotation];

  // Then
  assertThatBool(returnedValue, is(@(expectedReturnedValue)));
  [self waitForExpectations:@[ originalCalledExpectation, customCalledExpectation ] timeout:1];
}

- (void)testWithOneCustomDelegateNotReturningValue {

  // If
  NSData *expectedToken = [@"Device token" dataUsingEncoding:NSUTF8StringEncoding];
  UIApplication *appMock = self.appMock;
  XCTestExpectation *originalCalledExpectation = [self expectationWithDescription:@"Original delegate called."];
  XCTestExpectation *customCalledExpectation = [self expectationWithDescription:@"Custom delegate called."];
  NSString *didRegisterNotificationSelector =
      NSStringFromSelector(@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:));
  self.originalAppDelegateMock.delegateValidators[didRegisterNotificationSelector] =
      ^(UIApplication *application, NSData *deviceToken) {

        // Then
        assertThat(application, is(appMock));
        assertThat(deviceToken, is(expectedToken));
        [originalCalledExpectation fulfill];
      };
  self.customAppDelegateMock.delegateValidators[didRegisterNotificationSelector] =
      ^(UIApplication *application, NSData *deviceToken) {

        // Then
        assertThat(application, is(appMock));
        assertThat(deviceToken, is(expectedToken));
        [customCalledExpectation fulfill];
      };
  [MSAppDelegateForwarder swizzleOriginalDelegate:self.originalAppDelegateMock];
  [MSAppDelegateForwarder addDelegate:self.customAppDelegateMock];

  // When
  [self.originalAppDelegateMock application:appMock didRegisterForRemoteNotificationsWithDeviceToken:expectedToken];

  // Then
  [self waitForExpectations:@[ originalCalledExpectation, customCalledExpectation ] timeout:1];
}

- (void)testDontForwardSelectorsNotToOverrideIfAlreadyImplementedByOriginalDelegate {

  // If
  NSDictionary *expectedUserInfo = @{ @"key" : @"value" };
  void (^expectedCompletionHandler)(UIBackgroundFetchResult result) =
      ^(__attribute__((unused)) UIBackgroundFetchResult result) {
      };
  UIApplication *appMock = self.appMock;
  XCTestExpectation *originalCalledExpectation = [self expectationWithDescription:@"Original delegate called."];
  NSString *selector =
      NSStringFromSelector(@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:));
  self.originalAppDelegateMock.delegateValidators[selector] =
      ^(UIApplication *application, NSDictionary *userInfo, void (^completionHandler)(UIBackgroundFetchResult result)) {

        // Then
        assertThat(application, is(appMock));
        assertThat(userInfo, is(expectedUserInfo));
        assertThat(completionHandler, is(expectedCompletionHandler));
        [originalCalledExpectation fulfill];
      };
  self.customAppDelegateMock.delegateValidators[selector] =
      ^(__attribute__((unused)) UIApplication *application, __attribute__((unused)) NSData *deviceToken) {

        // Then
        XCTFail(@"This method is already implemented in the original delegate and is marked not to be swizzled.");
      };
  [MSAppDelegateForwarder swizzleOriginalDelegate:self.originalAppDelegateMock];
  [MSAppDelegateForwarder addDelegate:self.customAppDelegateMock];

  // When
  [self.originalAppDelegateMock application:appMock
               didReceiveRemoteNotification:expectedUserInfo
                     fetchCompletionHandler:expectedCompletionHandler];

  // Then
  assertThatBool([MSAppDelegateForwarder.selectorsNotToOverride containsObject:selector], isTrue());
  [self waitForExpectations:@[ originalCalledExpectation ] timeout:1];
}

- (void)testWithMultipleCustomDelegates {

  // If
  NSURL *expectedURL = [NSURL URLWithString:@"https://www.contoso.com/sending-positive-waves"];
  NSDictionary *expectedAnnotation = @{};
  BOOL expectedReturnedValue = YES;
  XCTestExpectation *originalCalledExpectation = [self expectationWithDescription:@"Original delegate called."];
  XCTestExpectation *customCalledExpectation1 = [self expectationWithDescription:@"Custom delegate 1 called."];
  XCTestExpectation *customCalledExpectation2 = [self expectationWithDescription:@"Custom delegate 2 called."];
  UIApplication *appMock = self.appMock;
  NSString *originalOpenURLiOS42Selector =
      NSStringFromSelector(@selector(application:openURL:sourceApplication:annotation:));
  self.originalAppDelegateMock.delegateValidators[originalOpenURLiOS42Selector] =
      ^(UIApplication *application, NSURL *url, NSString *sApplication, id annotation) {

        // Then
        assertThat(application, is(appMock));
        assertThat(url, is(expectedURL));
        assertThat(sApplication, nilValue());
        assertThat(annotation, is(expectedAnnotation));
        [originalCalledExpectation fulfill];
        return expectedReturnedValue;
      };
  MSMockCustomAppDelegate *customAppDelegateMock1 = [MSMockCustomAppDelegate new];
  NSString *customOpenURLiOS42Selector =
      NSStringFromSelector(@selector(application:openURL:sourceApplication:annotation:returnedValue:));
  customAppDelegateMock1.delegateValidators[customOpenURLiOS42Selector] =
      ^(UIApplication *application, NSURL *url, NSString *sApplication, id annotation, BOOL returnedValue) {

        // Then
        assertThat(application, is(appMock));
        assertThat(url, is(expectedURL));
        assertThat(sApplication, nilValue());
        assertThat(annotation, is(expectedAnnotation));
        assertThatBool(returnedValue, is(@(expectedReturnedValue)));
        [customCalledExpectation1 fulfill];
        return expectedReturnedValue;
      };
  MSMockCustomAppDelegate *customAppDelegateMock2 = [MSMockCustomAppDelegate new];
  customAppDelegateMock2.delegateValidators[customOpenURLiOS42Selector] =
      ^(UIApplication *application, NSURL *url, NSString *sApplication, id annotation, BOOL returnedValue) {

        // Then
        assertThat(application, is(appMock));
        assertThat(url, is(expectedURL));
        assertThat(sApplication, nilValue());
        assertThat(annotation, is(expectedAnnotation));
        assertThatBool(returnedValue, is(@(expectedReturnedValue)));
        [customCalledExpectation2 fulfill];
        return expectedReturnedValue;
      };
  [MSAppDelegateForwarder swizzleOriginalDelegate:customAppDelegateMock1];
  [MSAppDelegateForwarder swizzleOriginalDelegate:customAppDelegateMock2];
  [MSAppDelegateForwarder addDelegate:customAppDelegateMock1];
  [MSAppDelegateForwarder addDelegate:customAppDelegateMock2];

  // When
  BOOL returnedValue = [self.originalAppDelegateMock application:self.appMock
                                                         openURL:expectedURL
                                               sourceApplication:nil
                                                      annotation:expectedAnnotation];

  // Then
  assertThatBool(returnedValue, is(@(expectedReturnedValue)));
  [self waitForExpectations:@[ originalCalledExpectation, customCalledExpectation1, customCalledExpectation2 ]
                    timeout:1];
}

- (void)testWithRemovedCustomDelegate {

  // If
  NSURL *expectedURL = [NSURL URLWithString:@"https://www.contoso.com/sending-positive-waves"];
  NSDictionary *expectedAnnotation = @{};
  BOOL expectedReturnedValue = YES;
  UIApplication *appMock = self.appMock;
  XCTestExpectation *originalCalledExpectation = [self expectationWithDescription:@"Original delegate called."];
  NSString *originalOpenURLiOS42Selector =
      NSStringFromSelector(@selector(application:openURL:sourceApplication:annotation:));
  self.originalAppDelegateMock.delegateValidators[originalOpenURLiOS42Selector] =
      ^(UIApplication *application, NSURL *url, NSString *sApplication, id annotation) {

        // Then
        assertThat(application, is(appMock));
        assertThat(url, is(expectedURL));
        assertThat(sApplication, nilValue());
        assertThat(annotation, is(expectedAnnotation));
        [originalCalledExpectation fulfill];
        return expectedReturnedValue;
      };
  NSString *customOpenURLiOS42Selector =
      NSStringFromSelector(@selector(application:openURL:sourceApplication:annotation:returnedValue:));
  self.customAppDelegateMock.delegateValidators[customOpenURLiOS42Selector] =
      ^(__attribute__((unused)) UIApplication *application, __attribute__((unused)) NSURL *url,
        __attribute__((unused)) NSString *sApplication, __attribute__((unused)) id annotation,
        __attribute__((unused)) BOOL returnedValue) {

        // Then
        XCTFail(@"Custom delegate got called but is removed.");
        return expectedReturnedValue;
      };
  [MSAppDelegateForwarder swizzleOriginalDelegate:self.originalAppDelegateMock];
  [MSAppDelegateForwarder addDelegate:self.customAppDelegateMock];
  [MSAppDelegateForwarder removeDelegate:self.customAppDelegateMock];

  // When
  BOOL returnedValue = [self.originalAppDelegateMock application:self.appMock
                                                         openURL:expectedURL
                                               sourceApplication:nil
                                                      annotation:expectedAnnotation];

  // Then
  assertThatBool(returnedValue, is(@(expectedReturnedValue)));
  [self waitForExpectations:@[ originalCalledExpectation ] timeout:1];
}

- (void)testDontForwardOnDisable {

  // If
  NSURL *expectedURL = [NSURL URLWithString:@"https://www.contoso.com/sending-positive-waves"];
  NSDictionary *expectedAnnotation = @{};
  BOOL expectedReturnedValue = YES;
  UIApplication *appMock = self.appMock;
  XCTestExpectation *originalCalledExpectation = [self expectationWithDescription:@"Original delegate called."];
  NSString *originalOpenURLiOS42Selector =
      NSStringFromSelector(@selector(application:openURL:sourceApplication:annotation:));
  self.originalAppDelegateMock.delegateValidators[originalOpenURLiOS42Selector] =
      ^(UIApplication *application, NSURL *url, NSString *sApplication, id annotation) {

        // Then
        assertThat(application, is(appMock));
        assertThat(url, is(expectedURL));
        assertThat(sApplication, nilValue());
        assertThat(annotation, is(expectedAnnotation));
        [originalCalledExpectation fulfill];
        return expectedReturnedValue;
      };
  NSString *customOpenURLiOS42Selector =
      NSStringFromSelector(@selector(application:openURL:sourceApplication:annotation:returnedValue:));
  self.customAppDelegateMock.delegateValidators[customOpenURLiOS42Selector] =
      ^(__attribute__((unused)) UIApplication *application, __attribute__((unused)) NSURL *url,
        __attribute__((unused)) NSString *sApplication, __attribute__((unused)) id annotation,
        __attribute__((unused)) BOOL returnedValue) {

        // Then
        XCTFail(@"Custom delegate got called but is removed.");
        return expectedReturnedValue;
      };
  [MSAppDelegateForwarder swizzleOriginalDelegate:self.originalAppDelegateMock];
  [MSAppDelegateForwarder addDelegate:self.customAppDelegateMock];
  MSAppDelegateForwarder.enabled = NO;

  // When
  BOOL returnedValue = [self.originalAppDelegateMock application:self.appMock
                                                         openURL:expectedURL
                                               sourceApplication:nil
                                                      annotation:expectedAnnotation];

  // Then
  assertThatBool(returnedValue, is(@(expectedReturnedValue)));
  [self waitForExpectations:@[ originalCalledExpectation ] timeout:1];
  MSAppDelegateForwarder.enabled = YES;
}

- (void)testReturnValueChaining {

  // If
  NSURL *expectedURL = [NSURL URLWithString:@"https://www.contoso.com/sending-positive-waves"];
  NSDictionary *expectedAnnotation = @{};
  BOOL initialReturnValue = YES;
  __block BOOL expectedReturnedValue;
  XCTestExpectation *originalCalledExpectation = [self expectationWithDescription:@"Original delegate called."];
  XCTestExpectation *customCalledExpectation1 = [self expectationWithDescription:@"Custom delegate 1 called."];
  XCTestExpectation *customCalledExpectation2 = [self expectationWithDescription:@"Custom delegate 2 called."];
  UIApplication *appMock = self.appMock;
  NSString *originalOpenURLiOS42Selector =
      NSStringFromSelector(@selector(application:openURL:sourceApplication:annotation:));
  self.originalAppDelegateMock.delegateValidators[originalOpenURLiOS42Selector] =
      ^(UIApplication *application, NSURL *url, NSString *sApplication, id annotation) {

        // Then
        assertThat(application, is(appMock));
        assertThat(url, is(expectedURL));
        assertThat(sApplication, nilValue());
        assertThat(annotation, is(expectedAnnotation));
        [originalCalledExpectation fulfill];
        expectedReturnedValue = initialReturnValue;
        return expectedReturnedValue;
      };
  MSMockCustomAppDelegate *customAppDelegateMock1 = [MSMockCustomAppDelegate new];
  MSMockCustomAppDelegate *customAppDelegateMock2 = [MSMockCustomAppDelegate new];
  NSString *customOpenURLiOS42Selector =
      NSStringFromSelector(@selector(application:openURL:sourceApplication:annotation:returnedValue:));
  customAppDelegateMock1.delegateValidators[customOpenURLiOS42Selector] =
      ^(UIApplication *application, NSURL *url, NSString *sApplication, id annotation, BOOL returnedValue) {

        // Then
        assertThat(application, is(appMock));
        assertThat(url, is(expectedURL));
        assertThat(sApplication, nilValue());
        assertThat(annotation, is(expectedAnnotation));
        assertThatBool(returnedValue, is(@(expectedReturnedValue)));
        expectedReturnedValue = !returnedValue;
        [customCalledExpectation1 fulfill];
        return expectedReturnedValue;
      };
  customAppDelegateMock2.delegateValidators[customOpenURLiOS42Selector] =
      ^(UIApplication *application, NSURL *url, NSString *sApplication, id annotation, BOOL returnedValue) {

        // Then
        assertThat(application, is(appMock));
        assertThat(url, is(expectedURL));
        assertThat(sApplication, nilValue());
        assertThat(annotation, is(expectedAnnotation));
        assertThatBool(returnedValue, is(@(expectedReturnedValue)));
        expectedReturnedValue = !returnedValue;
        [customCalledExpectation2 fulfill];
        return expectedReturnedValue;
      };
  [MSAppDelegateForwarder swizzleOriginalDelegate:customAppDelegateMock1];
  [MSAppDelegateForwarder swizzleOriginalDelegate:customAppDelegateMock2];
  [MSAppDelegateForwarder addDelegate:customAppDelegateMock1];
  [MSAppDelegateForwarder addDelegate:customAppDelegateMock2];

  // When
  BOOL returnedValue = [self.originalAppDelegateMock application:self.appMock
                                                         openURL:expectedURL
                                               sourceApplication:nil
                                                      annotation:expectedAnnotation];

  // Then
  assertThatBool(returnedValue, is(@(expectedReturnedValue)));
  [self waitForExpectations:@[ originalCalledExpectation, customCalledExpectation1, customCalledExpectation2 ]
                    timeout:1];
}

- (void)testForwardMethodNotImplementedByOriginalDelegate {

  // If
  NSURL *expectedURL = [NSURL URLWithString:@"https://www.contoso.com/sending-positive-waves"];
  NSDictionary<UIApplicationOpenURLOptionsKey, id> *expectedOptions = @{};
  BOOL expectedReturnedValue = NO;
  UIApplication *appMock = self.appMock;
  XCTestExpectation *customCalledExpectation = [self expectationWithDescription:@"Custom delegate called."];
  NSString *customOpenURLiOS42Selector = NSStringFromSelector(@selector(application:openURL:options:returnedValue:));
  self.customAppDelegateMock.delegateValidators[customOpenURLiOS42Selector] =
      ^(UIApplication *application, NSURL *url, NSDictionary<UIApplicationOpenURLOptionsKey, id> *options,
        BOOL returnedValue) {

        // Then
        assertThat(application, is(appMock));
        assertThat(url, is(expectedURL));
        assertThat(options, is(expectedOptions));
        assertThatBool(returnedValue, is(@(expectedReturnedValue)));
        [customCalledExpectation fulfill];
        return expectedReturnedValue;
      };
  [MSAppDelegateForwarder swizzleOriginalDelegate:self.originalAppDelegateMock];
  [MSAppDelegateForwarder addDelegate:self.customAppDelegateMock];

// When
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
  BOOL returnedValue =
      [self.originalAppDelegateMock application:self.appMock openURL:expectedURL options:expectedOptions];
#pragma clang diagnostic pop

  // Then
  assertThatBool(returnedValue, is(@(expectedReturnedValue)));
  [self waitForExpectations:@[ customCalledExpectation ] timeout:1];
}

#pragma clang diagnostic pop

@end
