//
//  PCDevice.h
//  PCDevice
//
//  Created by Patrick Perini on 2/14/12.
//  Licensing information availabe in README.md
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SCNetworkReachability.h>

#if !TARGET_OS_IPHONE
    #import <sys/sysctl.h>
    #import <IOKit/ps/IOPSKeys.h>
    #import <IOKit/ps/IOPowerSources.h>
    #import <SystemConfiguration/SystemConfiguration.h>
#endif


#pragma mark - Global Constants
#define PCCurrentDevice [PCDevice currentDevice]
extern  NSString *const PCDeviceOrientationDidChangeNotification;
extern  NSString *const PCDeviceBatteryLevelDidChangeNotification;
extern  NSString *const PCDeviceBatteryStateDidChangeNotification;
extern  NSString *const PCDeviceConnectionStateDidChangeNotification;

#pragma mark - Global Enumerations
typedef enum
{
    PCUserInterfaceIdiomPhone,
    PCUserInterfaceIdiomPad,
    PCUserInterfaceIdiomDesktop
} PCUserInterfaceIdiom;

typedef enum
{
    PCDeviceBatteryStateUnknown,
    PCDeviceBatteryStateUnplugged,
    PCDeviceBatteryStateCharging,
    PCDeviceBatteryStateFull,
} PCDeviceBatteryState;

typedef enum
{
    PCDeviceOrientationUknown,
    PCDeviceOrientationPortrait,
    PCDeviceOrientationPortraitUpsideDown,
    PCDeviceOrientationLandscapeLeft,
    PCDeviceOrientationLandscapeRight,
    PCDeviceOrientationFaceUp,
    PCDeviceOrientationFaceDown
} PCDeviceOrientation;

typedef enum
{
    PCDeviceConnectionStateUnknown,
    PCDeviceConnectionStateMobile,
    PCDeviceConnectionStateWiFi,
    PCDeviceConnectionStateDisconnected
} PCDeviceConnectionState;

#pragma mark - Global Macros
#define PCDeviceOrientationIsPortrait(orientation)                \
        (orientation == PCDeviceOrientationPortrait            || \
         orientation == PCDeviceOrientationPortraitUpsideDown)

#define PCDeviceOrientationIsLandscape(orientation)               \
        (orientation == PCDeviceOrientationLandscapeLeft       || \
         orientation == PCDeviceOrientationLandscapeRight)

#pragma mark - Public Interface
@interface PCDevice : NSObject
{
    #pragma mark ... Instance Variables
    @private
    BOOL _batteryMonitoringEnabled;
    BOOL _generateConnectionStateNotifications;
}

#pragma mark ... Class Methods
+ (PCDevice *) currentDevice;

#pragma mark ... Instance Properties
#pragma mark ... ... System Identification Information
@property (nonatomic, readonly, retain)                                    NSString *name;
@property (nonatomic, readonly, retain)                                    NSString *systemName;
@property (nonatomic, readonly, retain)                                    NSString *systemVersion;
@property (nonatomic, readonly, retain)                                    NSString *model;
@property (nonatomic, readonly, retain)                                    NSString *uniqueIdentifier;
#pragma mark ... ... System State Information
#pragma mark ... ... ... User Interface Idiom Information
@property (nonatomic, readonly)                                            PCUserInterfaceIdiom userInterfaceIdiom;
#pragma mark ... ... ... Orientation Information
@property (nonatomic, readonly)                                            PCDeviceOrientation orientation;
@property (nonatomic, getter = isGeneratingDeviceOrientationNotifications) BOOL generatesDeviceOrientationNotifications;
#pragma mark ... ... ... Multitasking Information
@property (nonatomic, readonly, getter = isMultitaskingSupported)          BOOL multitaskingSupported;
#pragma mark ... ... ... Push Notification Information
@property (nonatomic, readonly, getter = arePushNotificationsSupported)    BOOL pushNotificationsSupported;
#pragma mark ... ... ... iCloud Synchronization Information
@property (nonatomic, readonly, getter = isiCloudKeyValSyncSupported)      BOOL iCloudKeyValSyncSupported;
@property (nonatomic, readonly, getter = isiCloudFileSyncSupported)        BOOL iCloudFileSyncSupported;
#pragma mark ... ... ... Batter Information
@property (nonatomic, readonly)                                            float batteryLevel;
@property (nonatomic, getter = isBatteryMonitoringEnabled)                 BOOL batteryMonitoringEnabled;
@property (nonatomic, readonly)                                            PCDeviceBatteryState batteryState;
#pragma mark ... ... ... Network Connection Information
@property (nonatomic, readonly)                                            PCDeviceConnectionState connectionState;
@property (nonatomic, getter = isGeneratingConnectionStateNotifications)   BOOL generatesConnectionStateNotifications;

@end