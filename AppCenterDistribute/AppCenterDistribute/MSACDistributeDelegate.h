// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <AppCenterDistribute/MSACReleaseDetails.h>

@class MSACDistribute;

@protocol MSACDistributeDelegate <NSObject>

@optional

/**
 * Callback method that will be called whenever a new release is available for update.
 *
 * @param distribute The instance of MSACDistribute.
 * @param details Release details for the update.
 *
 * @return Return YES if you want to take update control by overriding default update dialog, NO otherwise.
 *
 * @see [MSACDistribute notifyUpdateAction:]
 */
- (BOOL)distribute:(MSACDistribute *)distribute releaseAvailableWithDetails:(MSACReleaseDetails *)details;

@end
