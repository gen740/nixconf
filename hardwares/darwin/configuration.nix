{
  pkgs,
  ...
}:
{
  system = {
    stateVersion = 5;
    primaryUser = "gen";
    defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        _HIHideMenuBar = true;
      };
      dock = {
        autohide = true;
      };
    };
  };
  users.users.gen.home = "/Users/gen";

  networking.hostName = "gen740";

  nix = {
    linux-builder.enable = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  environment = {
    systemPackages = with pkgs; [
      xquartz
    ];
    launchAgents = {
      "org.nixos.xquartz.startx.plist" = {
        enable = true;
        text = ''
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
          <plist version="1.0">
            <dict>
              <key>Label</key>
              <string>org.nixos.xquartz.startx</string>
              <key>ProgramArguments</key>
              <array>
                <string>${pkgs.xquartz}/libexec/launchd_startx</string>
                <string>${pkgs.xquartz}/bin/startx</string>
                <string>--</string>
                <string>${pkgs.xquartz}/bin/Xquartz</string>
              </array>
              <key>Sockets</key>
              <dict>
                <key>org.nixos.xquartz:0</key>
                <dict>
                  <key>SecureSocketWithKey</key>
                  <string>DISPLAY</string>
                </dict>
              </dict>
              <key>ServiceIPC</key>
              <true/>
              <key>EnableTransactions</key>
              <true/>
            </dict>
          </plist>
        '';
      };
    };
    launchDaemons = {
      "org.nixos.xquartz.privileged_startx.plist" = {
        enable = true;
        text = ''
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
          <plist version="1.0">
            <dict>
              <key>Label</key>
              <string>org.nixos.xquartz.privileged_startx</string>
              <key>ProgramArguments</key>
              <array>
                <string>${pkgs.xquartz}/libexec/privileged_startx</string>
                <string>-d</string>
                <string>${pkgs.xquartz}/etc/X11/xinit/privileged_startx.d</string>
              </array>
              <key>MachServices</key>
              <dict>
                <key>org.nixos.xquartz.privileged_startx</key>
                <true/>
              </dict>
              <key>TimeOut</key>
              <integer>120</integer>
              <key>EnableTransactions</key>
              <true/>
            </dict>
          </plist>
        '';
      };
    };
  };
}
