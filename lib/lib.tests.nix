facterLib: with facterLib; {
  hasCpu = {
    testErrorWithoutHardwareSection = {
      expr = (hasCpu "foo") { };
      expectedError.msg = "no hardware entries found in the report";
    };
    testErrorWithoutCpuSection = {
      expr = (hasCpu "foo") { hardware.cpu = [ ]; };
      expectedError.msg = "no cpu entries found in the report";
    };
    testErrorWithoutVendorName = {
      expr = (hasCpu "foo") { hardware.cpu = [ { } ]; };
      expectedError.msg = "detail.vendor_name not found in cpu entry";
    };
    testMatch = {
      expr = map (hasCpu "CoolProcessor") [
        { hardware.cpu = [ { vendor_name = "foo"; } ]; }
        { hardware.cpu = [ { vendor_name = "CoolProcessor"; } ]; }
      ];
      expected = [
        false
        true
      ];
    };
  };

  testHasAmdCpu = {
    expr = map hasAmdCpu [
      { hardware.cpu = [ { vendor_name = "foo"; } ]; }
      { hardware.cpu = [ { vendor_name = "AuthenticAMD"; } ]; }
    ];
    expected = [
      false
      true
    ];
  };

  testHasIntelCpu = {
    expr = map hasIntelCpu [
      { hardware.cpu = [ { vendor_name = "foo"; } ]; }
      { hardware.cpu = [ { vendor_name = "GenuineIntel"; } ]; }
    ];
    expected = [
      false
      true
    ];
  };
}
