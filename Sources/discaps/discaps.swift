// discaps.swift
// Made by Taj C (forcequit)

import Foundation
import Darwin
import IOKit
import IOKit.storage
import CoreGraphics
import AppKit

// MARK: - Caps Lock State
func isCapsLockOn() -> Bool {
    return CGEventSource.keyState(.combinedSessionState, key: 57)
}

@MainActor var legitInterval: TimeInterval = 0.00050
@MainActor func setInterval() {
    if isCapsLockOn() {
        legitInterval = 0.01050
    } else {
        legitInterval = 0.00050
    }
}

// MARK: - Blink Caps Lock LED
@MainActor
func blinkCapsLock(times: Int = 1, interval: TimeInterval = legitInterval) {
    let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
    let match: [[String: Any]] = [[
        kIOHIDDeviceUsagePageKey as String: kHIDPage_GenericDesktop,
        kIOHIDDeviceUsageKey as String: kHIDUsage_GD_Keyboard
    ]]
    IOHIDManagerSetDeviceMatchingMultiple(manager, match as CFArray)
    
    let openRc = IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
    if openRc == kIOReturnNotPermitted {
        print("Input Monitoring permissions need to be granted, exiting...")
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!)
        exit(1)
    }
    
    guard let devicesCF = IOHIDManagerCopyDevices(manager) else { return }
    let devices = devicesCF as! Set<IOHIDDevice>
    
    func toggle(_ on: Bool) {
        for device in devices {
            guard let elementsCF = IOHIDDeviceCopyMatchingElements(device, nil, 0) else { continue }
            let elements = elementsCF as! [IOHIDElement]
            for e in elements {
                if IOHIDElementGetUsagePage(e) == kHIDPage_LEDs &&
                   IOHIDElementGetUsage(e) == UInt32(kHIDUsage_LED_CapsLock) {
                    let value = IOHIDValueCreateWithIntegerValue(
                        kCFAllocatorDefault,
                        e,
                        mach_absolute_time(),
                        on ? 1 : 0
                    )
                    IOHIDDeviceSetValue(device, e, value)
                }
            }
        }
    }
    
    let capsOn = isCapsLockOn()
    for _ in 1...times {
        if capsOn {
            toggle(false)
            Thread.sleep(forTimeInterval: interval)
            toggle(true)
        } else {
            toggle(true)
            Thread.sleep(forTimeInterval: interval)
            toggle(false)
        }
        Thread.sleep(forTimeInterval: interval)
    }
}

// MARK: - Disk Monitoring
func getDiskBytes() -> (read: UInt64, write: UInt64) {
    var totalRead: UInt64 = 0
    var totalWrite: UInt64 = 0
    guard let matchingDict = IOServiceMatching("IOBlockStorageDriver") else {
        return (0, 0)
    }
    var iterator: io_iterator_t = 0
    let result = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &iterator)
    guard result == KERN_SUCCESS else {
        return (0, 0)
    }
    defer { IOObjectRelease(iterator) }
    while case let service = IOIteratorNext(iterator), service != 0 {
        defer { IOObjectRelease(service) }
        guard let properties = IORegistryEntryCreateCFProperty(
            service,
            "Statistics" as CFString,
            kCFAllocatorDefault,
            0
        )?.takeRetainedValue() as? [String: Any] else {
            continue
        }
        if let bytesRead = properties["Bytes (Read)"] as? UInt64 {
            totalRead += bytesRead
        }
        if let bytesWritten = properties["Bytes (Write)"] as? UInt64 {
            totalWrite += bytesWritten
        }
    }
    return (totalRead, totalWrite)
}

@main
struct main {
    static func main() {
        // MARK: - Argument Handling
        let args = CommandLine.arguments
        let silent = args.contains("-s") || args.contains("--silent")
        if args.contains("-v") || args.contains("--version") {
            print("discaps version 1.0.0")
            print("    Made by Taj C (forcequit)")
            print("    Check this out on GitHub, at https://github.com/forcequitOS/discaps")
            exit(0)
        }
        if args.contains("-h") || args.contains("--help") {
            print("")
            print("Usage:")
            print("    discaps [arguments]")
            print("")
            print("Arguments:")
            print("    --silent, -s         - silences command-line output")
            print("    --version, -v        - displays current version of discaps")
            print("    --help, -h           - shows this help menu")
            print("")
            exit(0)
        }
        
        // MARK: - Main Loop
        var previousBytes = getDiskBytes()
        
        while true {
            setInterval()
            Thread.sleep(forTimeInterval: legitInterval)
            let currentBytes = getDiskBytes()
            if currentBytes.read > previousBytes.read || currentBytes.write > previousBytes.write {
                if !silent {
                    print("Read: \(currentBytes.read), Write: \(currentBytes.write)")
                }
                blinkCapsLock()
            }
            previousBytes = currentBytes
        }
    }
}
