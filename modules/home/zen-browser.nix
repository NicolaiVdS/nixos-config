{ inputs, ... }:
{
  flake.modules.homeManager.zen-browser = { pkgs, ... }: {
    imports = [ inputs.zen-browser.homeModules.beta ];

    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;

      # Profile-level user preferences
      profiles.default = {
        settings = {
          # Zen-specific UI & setup bypass
          "zen.welcome-screen.seen" = true;
          "zen.workspaces.continue-where-left-off" = false;
          "zen.view.compact.hide-tabbar" = true;
          "zen.urlbar.behavior" = "float-on-type";

          # Generic Firefox first-run / onboarding bypass
          "browser.aboutwelcome.enabled" = false;
          "browser.startup.homepage_override.mstone" = "ignore";
          "startup.homepage_welcome_url" = "";
          "startup.homepage_welcome_url.additional" = "";
          "trailhead.firstrun.branches" = "nofirstrun-empty";
        };

        search = {
          force = true;
          default = "ddg";
        };
      };

      policies = {
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;

        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };

        Preferences = {
          "browser.startup.homepage" = {
            Value = "about:blank";
            Status = "locked";
          };
          # Prevents first-run welcome tour tab from opening
          "browser.aboutwelcome.enabled" = {
            Value = false;
            Status = "locked";
          };
        };

        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          "446900e4-71c2-419f-a6a7-df9c091e268b" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            installation_mode = "normal_installed";
          };
        };

        "3rdparty".Extensions."uBlock0@raymondhill.net".toOverwrite = {
          filterLists = [
            "user-filters"
            "ublock-filters"
            "ublock-badware"
            "ublock-privacy"
            "ublock-unbreak"
            "adguard-spyware-url"
          ];
          trustedSiteDirectives = [
            "nvds.be"
          ];
        };
      };
    };
  };
}
