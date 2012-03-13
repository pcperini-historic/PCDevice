#ITDevice#



Inherits From:    NSObject

Declared In:      ITDevice.h


##Overview##

The `ITDevice` class provides a singleton instance representing the current device running either iOS or Mac OS X. From this instance you can obtain information about the device such as assigned name, device model, and operating-system name and version.

You also use the `ITDevice` instance to detect changes in the device’s characteristics, such as physical orientation. You get the current orientation using the orientation property or receive change notifications by registering for the `ITDeviceOrientationDidChangeNotification` notification. Before using either of these techniques to get orientation data, you must enable data delivery by setting the `generatesDeviceOrientationNotifications` property to `YES`. When you no longer need to track the device orientation, set the `generatesDeviceOrientationNotifications` property to `NO` to disable the delivery of notifications.

Similarly, you can use the `ITDevice` instance to obtain information and notifications about changes to the battery’s charge state (described by the `batteryState` property) and charge level (described by the `batteryLevel` property). The `ITDevice` instance also provides access to the network connection state (described by the `connectionState` property). The network connection state represents the availability of Internet communication and whether the device is connected via a mobile data connection. Enable battery monitoring or connection monitoring only when you need it.

##Tasks##

###Getting the Shared Device Instance###
    + currentDevice
    ITCurrentDevice

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
>> If battery monitoring is not enabled, battery state is `ITDeviceBatteryStateUnknown` and the value of this property is -1.0.
    
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

    @property(nonatomic, readonly) ITDeviceBatteryState batteryState
    
> *Discussion*

>> The value for `batteryState` is one of the constants in `ITDeviceBatteryState`.
>> If battery monitoring is not enabled, the value of this property is `ITDeviceBatteryStateUnknown`.

**connectionState**

> The network connection state for the device.

    @property (nonatomic, readonly) ITDeviceConnectionState connectionState
    
> *Discussion*

>> The value for `connectionState` be `ITDeviceConnectionStateUknown` if some error occurrs, and `ITDeviceConnectionStateDisconnected` if Internet is unreachable.

**generatesConnectionStateNotifications**

> A Boolean value that indicates whether the receiver generates connection notifications (`YES`) or not (`NO`).

    @property (nonatomic, getter = isGeneratingConnectionStateNotifications) BOOL generatesConnectionStateNotifications

**generatesDeviceOrientationNotifications**

> A Boolean value that indicates whether the receiver generates orientation notifications.

    @property (nonatomic, getter = isGeneratingDeviceOrientationNotifications) BOOL generatesDeviceOrientationNotifications

> *Discussion*

>> If the value of this property is `YES`, the shared `ITDevice` object posts an `ITDeviceOrientationDidChangeNotification` notification when the device changes orientation.
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

    @property (nonatomic, readonly) ITDeviceOrientation orientation
    
> *Discussion*

>> The value of the property is constant that indicates the current orientation of the device. This value represents the physical orientation of the device and may be different from the current orientation of your application's user interface. See `ITDeviceOrientation` for descriptions of the possible values.
>> The value of this property always returns `ITDeviceOrientationUnknown` unless orentation notifications have been enabled by setting `generatesDeviceOrientationNotifications` to `YES`.
>> The value of this property always returns `ITDeviceOrientationPortrait` on the Mac OS X platform.

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

    @property (nonatomic, readonly) ITUserInterfaceIdiom userInterfaceIdiom
    
> *Discussion*

>> For universal applications and cross-compiling applications, you can use this property to tailor the behavior of your application for a specific type of device.

##Class Methods##

**currentDevice**

> Returns an object representing the current device.

    + (ITDevice *)currentDevice
    
> *Return Value:*

>> A singleton object that represents the current device.

##Constants and Macros##

**ITCurrentDevice**

> Returns the shared object representing the current device.

    #define ITCurrentDevice [ITDevice currentDevice]
    
**ITDeviceBatteryState**

> The battery power state of the device

    typedef enum
    {
        ITDeviceBatteryStateUnknown,
        ITDeviceBatteryStateUnplugged,
        ITDeviceBatteryStateCharging,
        ITDeviceBatteryStateFull
    } ITDeviceBatteryState;

> *Constants*

>> - `ITDeviceBatteryStateUnknown`: The battery state for the device cannot be determined.
>> - `ITDeviceBatteryStateUnplugged`: The device is not plugged into power; the battery is discharging.
>> - `ITDeviceBatteryStateCharging`: The device is plugged into power and the battery is less that 100% charged.
>> - `ITDeviceBatteryStateFull`: The device is plugged into power and the battery is 100% charged.

**ITDeviceConnectionState**

> The network connection state of the device.

    typedef enum
    {
        ITDeviceConnectionStateUnknown,
        ITDeviceConnectionStateMobile,
        ITDeviceConnectionStateWiFi,
        ITDeviceConnectionStateDisconnected
    } ITDeviceConnectionState;

> *Constants*

>> - `ITDeviceConnectionStateUnknown`: The connection state for the device cannot be determined.
>> - `ITDeviceConnectionStateMobile`: The device is connected to the Internet via a mobile provider.
>> - `ITDeviceConnectionStateWiFi`: The device is connected to the Internet via WiFi.
>> - `ITDeviceConnectionStateDisconnected`: The device is not connected to the Internet.

**ITDeviceOrientation**

> The physical orientation of the device.

    typedef enum
    {
        ITDeviceOrientationUnknown,
        ITDeviceOrientationPortrait,
        ITDeviceOrientationPortraitUpsideDown,
        ITDeviceOrientationLandscapeLeft,
        ITDeviceOrientationLandscapeRight,
        ITDeviceOrientationFaceUp,
        ITDeviceOrientationFaceDown
    } ITDeviceOrientation;
    
> *Constants*

>> - `ITDeviceOrientationUnknown`: The orientation of the device cannot be determined.
>> - `ITDeviceOrientationPortrait`: The device is in portrait mode, with the device held upright.
>> - `ITDeviceOrientationPortraitUpsideDown`: The device is in portrait mode but upside down.
>> - `ITDeviceOrientationLandscapeLeft`: The device is in landscape mode, turned counter-clockwise from portrait.
>> - `ITDeviceOrientationLandscapeRight`: The device is in landscape mode, turn clockwise from portrait.
>> - `ITDeviceOrientationFaceUp`: The device is held parallel to the ground with the screen facing upwards.
>> - `ITDeviceOrientationFaceDown`: The device is held parallel to the ground with the screen facing downwards.

**ITUserInterfaceIdiom**

> The type of interface that should be used on the current device.

    typedef enum
    {
        ITUserInterfaceIdiomPhone,
        ITUserInterfaceIdiomPad,
        ITUserInterfaceIdiomDesktop
    } ITUserInterfaceIdiom;

> *Constants*

>> - `ITUserInterfaceIdiomPhone`: The user interface should be designed for the iPhone and iPod Touch.
>> - `ITUserInterfaceIdiomPad`: The user interface should be designed for the iPad.
>> - `ITUserInterfaceIdiomDesktop`: The user interface should be designed for Mac OS X.

**ITDeviceOrientationIsPortrait**

> Returns `YES` if the given orientation is portrait, upside down or otherwise.

    #define ITDeviceOrientationIsPortrait(orientation) (orientation == ITDeviceOrientationPortrait || orientation == ITDeviceOrientationPortraitUpsideDown)

**ITDeviceOrientationIsLandscape**

> Returns `YES` if the given orientation is either landscape left or landscape right.

    #define ITDeviceOrientationIsLandscape(orientation) (orientation == ITDeviceOrientationLandscapeLeft || orientation == ITDeviceOrientationLandscapeRight)

##Notifications##

**ITDeviceBatteryLevelDidChangeNotification**

> Posted when the battery level changes. For this notification to be sent, you must set the `batteryMonitoryingEnabled` property to `YES`.
> Notifications for battery level change are sent no more frequently than once per minute.

**ITDeviceBatteryStateDidChangeNotification**

> Posted when the battery state changes. For this notification to be sent, you must set the `batteryMonitoringEnabled` property to `YES`.
> Notifications for battery state change are sent no more frequently than once per minute.

**ITDeviceConnectionStateDidChangeNotification**

> Posted when the connection state changes.
> Notifications for connection state change are sent no more frequently than once per minute.

**ITDeviceOrientationDidChangeNotification**

> Posted when the orientation of the device changes.
> This notification will never be posted on the Mac OS X platform.

#License#

License Agreement for Source Code provided by Inspyre Technologies

This software is supplied to you by Inspyre Technologies in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this software constitutes acceptance of these terms. If you do not agree with these terms, please do not use, install, modify or redistribute this software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Inspyre Technologies grants you a personal, non-exclusive license, to use, reproduce, modify and redistribute the software, with or without modifications, in source and/or binary forms; provided that if you redistribute the software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the software, and that in all cases attribution of Inspyre Technologies as the original author of the source code shall be included in all such resulting software products or distributions. Neither the name, trademarks, service marks or logos of Inspyre Technologies may be used to endorse or promote products derived from the software without specific prior written permission from Inspyre Technologies. Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Inspyre Technologies herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the software may be incorporated.

The software is provided by Inspyre Technologies on an "AS IS" basis. Inspyre Technologies MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL Inspyre Technologies BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF Inspyre Technologies HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.