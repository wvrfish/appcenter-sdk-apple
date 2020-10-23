// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <AppCenterAnalytics/MSACLogWithNameAndProperties.h>

@class MSACEventProperties;
@class MSACMetadataExtension;

@interface MSACEventLog : MSACLogWithNameAndProperties

/**
 * Unique identifier for this event.
 */
@property(nonatomic, copy) NSString *eventId;

/**
 * Event properties.
 */
@property(nonatomic, strong) MSACEventProperties *typedProperties;

@end
