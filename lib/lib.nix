lib:
let
  isAllOf = filters: device: lib.fold (next: memo: memo && (next device)) true filters;
  isOneOf = filters: device: lib.fold (next: memo: memo || (next device)) false filters;

  canonicalSort = list: with lib; sort (a: b: a < b) (unique list);

  hasAmdCpu =
    { hardware, ... }:
    builtins.any (
      device: device.hardware_class == "cpu" && device.detail.vendor_name == "AuthenticAMD"
    ) hardware;

  hasIntelCpu =
    { hardware, ... }:
    builtins.any (
      device: device.hardware_class == "cpu" && device.detail.vendor_name == "GenuineIntel"
    ) hardware;

in
{
  inherit isAllOf isOneOf canonicalSort;
  inherit hasAmdCpu hasIntelCpu;

  isMassStorageController =
    {
      base_class ? { },
      ...
    }:
    (base_class.value or null) == 1;
  isNetworkController =
    {
      base_class ? { },
      ...
    }:
    (base_class.value or null) == 2;
  isDisplayController =
    {
      base_class ? { },
      ...
    }:
    (base_class.value or null) == 3;
  isMultimediaController =
    {
      base_class ? { },
      ...
    }:
    (base_class.value or null) == 4;
  isMemoryController =
    {
      base_class ? { },
      ...
    }:
    (base_class.value or null) == 5;
  isBridge =
    {
      base_class ? { },
      ...
    }:
    (base_class.value or null) == 6;
  isCommunicationController =
    {
      base_class ? { },
      ...
    }:
    (base_class.value or null) == 7;
  isGenericSystemPeripheral =
    {
      base_class ? { },
      ...
    }:
    (base_class.value or null) == 8;
  isInputDeviceController =
    {
      base_class ? { },
      ...
    }:
    (base_class.value or null) == 9;
  isDockingStation =
    {
      base_class ? { },
      ...
    }:
    (base_class.value or null) == 10;
  isProcessor =
    {
      base_class ? { },
      ...
    }:
    (base_class.value or null) == 11;
  isSerialBusController =
    {
      base_class ? { },
      ...
    }:
    (base_class.value or null) == 12;
  isWirelessController =
    {
      base_class ? { },
      ...
    }:
    (base_class.value or null) == 13;
  isIntelligentController =
    {
      base_class ? { },
      ...
    }:
    (base_class.value or null) == 14;
  isSatelliteCommunicationsController =
    {
      base_class ? { },
      ...
    }:
    (base_class.value or null) == 15;
  isEncryptionController =
    {
      base_class ? { },
      ...
    }:
    (base_class.value or null) == 16;
  isSignalProcessingController =
    {
      base_class ? { },
      ...
    }:
    (base_class.value or null) == 17;
  isProcessingAccelerator =
    {
      base_class ? { },
      ...
    }:
    (base_class.value or null) == 18;
  isNonEssentialInstrumentation =
    {
      base_class ? { },
      ...
    }:
    (base_class.value or null) == 19;
  isCoprocessor =
    {
      base_class ? { },
      ...
    }:
    (base_class.value or null) == 64;

  isFirewireController =
    {
      base_class ? { },
      sub_class ? { },
      ...
    }:
    (base_class.value or null) == 12 && (sub_class.value or null) == 0;

  isUsbController =
    {
      base_class ? { },
      sub_class ? { },
      ...
    }:
    (base_class.value or null) == 12 && (sub_class.value or null) == 3;

  # Intel VT-x, virtualization support enabled in BIOS.
  supportsIntelKvm =
    report:
    (hasIntelCpu report)
    && builtins.any (
      {
        detail ? { },
        ...
      }:
      builtins.elem "vmx" detail.features or [ ]
    ) report.hardware;

  # AMD SVM,virtualization enabled in BIOS.
  supportsAmdKvm =
    report:
    (hasAmdCpu report)
    && builtins.any (
      {
        detail ? { },
        ...
      }:
      builtins.elem "svm" detail.features or [ ]
    ) report.hardware;

  devicesFilter =
    { vendorId, deviceIds }:
    isAllOf [
      (item: (item.vendor.value or null) == vendorId)
      (item: builtins.elem (item.device.value or null) deviceIds)
    ];

  pci.devices = import ./pci/devices.nix;
}
