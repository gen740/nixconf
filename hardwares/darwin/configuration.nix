{
  pkgs,
  ...
}:
let
  vpnAutoConnectScript = pkgs.writeShellScript "vpn-autoconnect" ''
    VPN_NAME="VPN"
    STATUS=$(networksetup -showpppoestatus "$VPN_NAME" 2>/dev/null)
    if [ "$STATUS" = "disconnected" ]; then
      networksetup -connectpppoeservice "$VPN_NAME"
    fi
  '';
in
{
  system = {
    stateVersion = 5;
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

  nix = {
    linux-builder.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      xquartz
    ];
    launchAgents = {
      "vpn-autoconnect.plist" = {
        enable = true;
        text = ''
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
          <plist version="1.0">
          <dict>
            <key>Label</key>
            <string>org.nixos.vpn-autoconnect</string>

            <key>ProgramArguments</key>
            <array>
              <string>${vpnAutoConnectScript}</string>
            </array>

            <key>RunAtLoad</key>
            <true/>

            <key>StartInterval</key>
            <integer>60</integer>

            <key>StandardOutPath</key>
            <string>/tmp/vpn-autoconnect.log</string>

            <key>StandardErrorPath</key>
            <string>/tmp/vpn-autoconnect.err</string>
          </dict>
          </plist>
        '';
      };
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
