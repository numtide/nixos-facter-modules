lib:
let

  inherit (lib) assertMsg;

  hasCpu =
    name:
    {
      hardware ? { },
      ...
    }:
    let
      cpus = hardware.cpu or [ ];
    in
    assert assertMsg (hardware != { }) "no hardware entries found in the report";
    assert assertMsg (cpus != [ ]) "no cpu entries found in the report";
    builtins.any (
      {
        vendor_name ? null,
        ...
      }:
      assert assertMsg (vendor_name != null) "detail.vendor_name not found in cpu entry";
      vendor_name == name
    ) cpus;

  collectDrivers = list: lib.foldl' (lst: value: lst ++ value.driver_modules or [ ]) [ ] list;
  stringSet = list: builtins.attrNames (builtins.groupBy lib.id list);
in
{
  inherit hasCpu collectDrivers stringSet;
  hasAmdCpu = hasCpu "AuthenticAMD";
  hasIntelCpu = hasCpu "GenuineIntel";
}
