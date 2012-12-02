#PCDevice#



Inherits From:    NSObject

Declared In:      PCDevice.h


##Overview##

The `PCDevice` class provides a singleton instance representing the current device running either iOS or Mac OS X. From this instance you can obtain information about the device such as assigned name, device model, and operating-system name and version.

You also use the `PCDevice` instance to detect changes in the device’s characteristics, such as physical orientation. You get the current orientation using the orientation property or receive change notifications by registering for the `PCDeviceOrientationDidChangeNotification` notification. Before using either of these techniques to get orientation data, you must enable data delivery by setting the `generatesDeviceOrientationNotifications` property to `YES`. When you no longer need to track the device orientation, set the `generatesDeviceOrientationNotifications` property to `NO` to disable the delivery of notifications.

Similarly, you can use the `PCDevice` instance to obtain information and notifications about changes to the battery’s charge state (described by the `batteryState` property) and charge level (described by the `batteryLevel` property). The `PCDevice` instance also provides access to the network connection state (described by the `connectionState` property). The network connection state represents the availability of Internet communication and whether the device is connected via a mobile data connection. Enable battery monitoring or connection monitoring only when you need it.

##Tasks##

###Getting the Shared Device Instance###
    + currentDevice
    PCCurrentDevice

###Determining Available Features###
    multitaskingSupported      (property)
    pushNotificationsSupported (property)
    iCloudKeyValSyncSupported  (property)
    iCloudFileSyncSupported    (property)

###Identifying the Device and Operating System###
    name             (property)
    systemName       (property)
    systemVersion    (property)
    model            (property)
    uniqueIdentifier (property)

###Getting the Device Orientation###
    orientation                              (property)
    generatesDeviceOrientationNotificiations (property)

###Getting the Device Battery State###
    batteryLevel             (property)
    batteryMonitoringEnabled (property)
    batteryState             (property)

###Getting the Device Network Connection State###
    connectionState                       (property)
    generatesConnectionStateNotifications (property)
    
##Properties##

**batteryLevel**

> The battery charge level for the device.

    @property(nonatomic, readonly) float batteryLevel
    
> *Discussion*

>> Battery level ranges from 0.0 (fully discharged) to 1.0 (100% charged). Before accessing this property, ensure that battery monitoring is enabled.
>> If battery monitoring is not enabled, battery state is `PCDeviceBatteryStateUnknown` and the value of this property is -1.0.
    
**batteryMonitoringEnabled**

> A Boolean value indicating whether battery monitoring is enabled (`YES`) or not (`NO`).

    @property(nonatomic, getter = isBatteryMonitoringEnabled) BOOL batteryMonitoringEnabled
    
> *Discussion*

>> Enable battery monitoring if you need to be notified of changes to the battery state, or if you want to check the battery charge level.
>> The default value of this property is `NO`, which:

>> - Disables the posting of battery-related notifications
>> - Disables the ability to read battery charge level and battery state

**batteryState**

> The battery state for the device.

    @property(nonatomic, readonly) PCDeviceBatteryState batteryState
    
> *Discussion*

>> The value for `batteryState` is one of the constants in `PCDeviceBatteryState`.
>> If battery monitoring is not enabled, the value of this property is `PCDeviceBatteryStateUnknown`.

**connectionState**

> The network connection state for the device.

    @property (nonatomic, readonly) PCDeviceConnectionState connectionState
    
> *Discussion*

>> The value for `connectionState` be `PCDeviceConnectionStateUknown` if some error occurrs, and `PCDeviceConnectionStateDisconnected` if Internet is unreachable.

**generatesConnectionStateNotifications**

> A Boolean value that indicates whether the receiver generates connection notifications (`YES`) or not (`NO`).

    @property (nonatomic, getter = isGeneratingConnectionStateNotifications) BOOL generatesConnectionStateNotifications

**generatesDeviceOrientationNotifications**

> A Boolean value that indicates whether the receiver generates orientation notifications.

    @property (nonatomic, getter = isGeneratingDeviceOrientationNotifications) BOOL generatesDeviceOrientationNotifications

> *Discussion*

>> If the value of this property is `YES`, the shared `PCDevice` object posts an `PCDeviceOrientationDidChangeNotification` notification when the device changes orientation.
>> If the value is `NO`, it generates no orientation notifications. This property has no effect in the Mac OS X environment.
    
**iCloudKeyValSyncSupported**

> A Boolean value indicating whether iCloud key-value synchronization is supported on the current device.

    @property (nonatomic, readonly, getter = isiCloudKeyValSyncSupported) BOOL iCloudKeyValSyncSupported
    
**iCloudFileSyncSupported**

> A Boolean value indicating whether iCloud file synchronization is supported and configured on the current device.

    @property (nonatomic, readonly, getter = isiCloudFileSyncSupported) BOOL iCloudFileSyncSupported

**model**

> The model of the device.

    @property (nonatomic, readonly, retain) NSString *model
    
**multitaskingSupported**

> A Boolean value indicating whether multitasking is supported on the current device.

    @property (nonatomic, readonly, getter = isMultitaskingSupported) BOOL multitaskingSupported
    
**name**

> The name identifying the device.

    @property (nonatomic, readonly, retain) NSString *name
    
**orientation**

> Returns the physical orientation of the device.

    @property (nonatomic, readonly) PCDeviceOrientation orientation
    
> *Discussion*

>> The value of the property is constant that indicates the current orientation of the device. This value represents the physical orientation of the device and may be different from the current orientation of your application's user interface. See `PCDeviceOrientation` for descriptions of the possible values.
>> The value of this property always returns `PCDeviceOrientationUnknown` unless orentation notifications have been enabled by setting `generatesDeviceOrientationNotifications` to `YES`.
>> The value of this property always returns `PCDeviceOrientationPortrait` on the Mac OS X platform.

**pushNotificationsSupported**

> A Boolean value indicating whether push notifications are supported on the current device.

    @property (nonatomic, readonly, getter = arePushNotificationsSupported) BOOL pushNotificationsSupported

**systemName**

> The name of the operating system running on the device represented by the receiver.

    @property (nonatomic, readonly, retain) NSString *systemName
    
**systemVersion**

> The current version of the operating system.

    @property (nonatomic, readonly, retain) NSString *systemVersion
    
**uniqueIdentifier**

> An alphanumeric string unique to each device with regard to your app.

    @property (nonatomic, readonly, retain) NSString *uniqueIdentifier
    
> *Discussion*

>> Because this method does not rely on the deprecated `uniqueIdentifier` property of `UIDevice`, it is safe to use.
>> This property uses the `CFUUIDCreate` function to create a UUID, and writes it to the `defaults` database using the `NSUserDefaults` class.
    
**userInterfaceIdiom**

> The style of interface to use on the current device.

    @property (nonatomic, readonly) PCUserInterfaceIdiom userInterfaceIdiom
    
> *Discussion*

>> For universal applications and cross-compiling applications, you can use this property to tailor the behavior of your application for a specific type of device.

##Class Methods##

**currentDevice**

> Returns an object representing the current device.

    + (PCDevice *)currentDevice
    
> *Return Value:*

>> A singleton object that represents the current device.

##Constants and Macros##

**PCCurrentDevice**

> Returns the shared object representing the current device.

    #define PCCurrentDevice [PCDevice currentDevice]
    
**PCDeviceBatteryState**

> The battery power state of the device

    typedef enum
    {
        PCDeviceBatteryStateUnknown,
        PCDeviceBatteryStateUnplugged,
        PCDeviceBatteryStateCharging,
        PCDeviceBatteryStateFull
    } PCDeviceBatteryState;

> *Constants*

>> - `PCDeviceBatteryStateUnknown`: The battery state for the device cannot be determined.
>> - `PCDeviceBatteryStateUnplugged`: The device is not plugged into power; the battery is discharging.
>> - `PCDeviceBatteryStateCharging`: The device is plugged into power and the battery is less that 100% charged.
>> - `PCDeviceBatteryStateFull`: The device is plugged into power and the battery is 100% charged.

**PCDeviceConnectionState**

> The network connection state of the device.

    typedef enum
    {
        PCDeviceConnectionStateUnknown,
        PCDeviceConnectionStateMobile,
        PCDeviceConnectionStateWiFi,
        PCDeviceConnectionStateDisconnected
    } PCDeviceConnectionState;

> *Constants*

>> - `PCDeviceConnectionStateUnknown`: The connection state for the device cannot be determined.
>> - `PCDeviceConnectionStateMobile`: The device is connected to the Internet via a mobile provider.
>> - `PCDeviceConnectionStateWiFi`: The device is connected to the Internet via WiFi.
>> - `PCDeviceConnectionStateDisconnected`: The device is not connected to the Internet.

**PCDeviceOrientation**

> The physical orientation of the device.

    typedef enum
    {
        PCDeviceOrientationUnknown,
        PCDeviceOrientationPortrait,
        PCDeviceOrientationPortraitUpsideDown,
        PCDeviceOrientationLandscapeLeft,
        PCDeviceOrientationLandscapeRight,
        PCDeviceOrientationFaceUp,
        PCDeviceOrientationFaceDown
    } PCDeviceOrientation;
    
> *Constants*

>> - `PCDeviceOrientationUnknown`: The orientation of the device cannot be determined.
>> - `PCDeviceOrientationPortrait`: The device is in portrait mode, with the device held upright.
>> - `PCDeviceOrientationPortraitUpsideDown`: The device is in portrait mode but upside down.
>> - `PCDeviceOrientationLandscapeLeft`: The device is in landscape mode, turned counter-clockwise from portrait.
>> - `PCDeviceOrientationLandscapeRight`: The device is in landscape mode, turn clockwise from portrait.
>> - `PCDeviceOrientationFaceUp`: The device is held parallel to the ground with the screen facing upwards.
>> - `PCDeviceOrientationFaceDown`: The device is held parallel to the ground with the screen facing downwards.

**PCUserInterfaceIdiom**

> The type of interface that should be used on the current device.

    typedef enum
    {
        PCUserInterfaceIdiomPhone,
        PCUserInterfaceIdiomPad,
        PCUserInterfaceIdiomDesktop
    } PCUserInterfaceIdiom;

> *Constants*

>> - `PCUserInterfaceIdiomPhone`: The user interface should be designed for the iPhone and iPod Touch.
>> - `PCUserInterfaceIdiomPad`: The user interface should be designed for the iPad.
>> - `PCUserInterfaceIdiomDesktop`: The user interface should be designed for Mac OS X.

**PCDeviceOrientationIsPortrait**

> Returns `YES` if the given orientation is portrait, upside down or otherwise.

    #define PCDeviceOrientationIsPortrait(orientation) (orientation == PCDeviceOrientationPortrait || orientation == PCDeviceOrientationPortraitUpsideDown)

**PCDeviceOrientationIsLandscape**

> Returns `YES` if the given orientation is either landscape left or landscape right.

    #define PCDeviceOrientationIsLandscape(orientation) (orientation == PCDeviceOrientationLandscapeLeft || orientation == PCDeviceOrientationLandscapeRight)

##Notifications##

**PCDeviceBatteryLevelDidChangeNotification**

> Posted when the battery level changes. For this notification to be sent, you must set the `batteryMonitoryingEnabled` property to `YES`.
> Notifications for battery level change are sent no more frequently than once per minute.

**PCDeviceBatteryStateDidChangeNotification**

> Posted when the battery state changes. For this notification to be sent, you must set the `batteryMonitoringEnabled` property to `YES`.
> Notifications for battery state change are sent no more frequently than once per minute.

**PCDeviceConnectionStateDidChangeNotification**

> Posted when the connection state changes.
> Notifications for connection state change are sent no more frequently than once per minute.

**PCDeviceOrientationDidChangeNotification**

> Posted when the orientation of the device changes.
> This notification will never be posted on the Mac OS X platform.

#License#

License Agreement for Source Code provided by Patrick Perini

This software is supplied to you by Patrick Perini in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this software constitutes acceptance of these terms. If you do not agree with these terms, please do not use, install, modify or redistribute this software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Patrick Perini grants you a personal, non-exclusive license, to use, reproduce, modify and redistribute the software, with or without modifications, in source and/or binary forms; provided that if you redistribute the software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the software, and that in all cases attribution of Patrick Perini as the original author of the source code shall be included in all such resulting software products or distributions. Neither the name, trademarks, service marks or logos of Patrick Perini may be used to endorse or promote products derived from the software without specific prior written permission from Patrick Perini. Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Patrick Perini herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the software may be incorporated.

The software is provided by Patrick Perini on an "AS IS" basis. Patrick Perini MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL Patrick Perini BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF Patrick Perini HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.