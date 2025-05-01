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

  environment.launchAgents."vpn-autoconnect.plist" = {
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
}
