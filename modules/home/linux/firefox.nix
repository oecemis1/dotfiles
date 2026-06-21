{ ... }:
{
  flake.modules.homeManager.linux =
    { config, ... }:
    {
      programs.firefox = {
        enable = true;
        profiles."${config.home.username}" = {

          search = {
            # default = "google";
            default = "ddg";
            force = true;
            engines = {
              "amazondotcom-us".metaData.hidden = true;
              "bing".metaData.hidden = true;
              "ebay".metaData.hidden = true;
              "wikipedia".metaData.hidden = true;

              "ddg" = {
                urls = [
                  {
                    template = "https://duckduckgo.com";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                definedAliases = [ ",d" ];
              };
              "google" = {
                urls = [
                  {
                    template = "https://google.com/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                definedAliases = [ ",go" ];
              };
              "Nix Packages" = {
                urls = [
                  {
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "type";
                        value = "packages";
                      }
                      {
                        name = "unstable";
                        value = "channel";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                definedAliases = [ ",np" ];
              };
              "youtube" = {
                urls = [
                  {
                    template = "https://www.youtube.com/results";
                    params = [
                      {
                        name = "search_query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                definedAliases = [ ",yt" ];
              };
              "GitHub" = {
                urls = [
                  {
                    template = "https://github.com/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                definedAliases = [ ",gi" ];
              };
            };
          };

          settings = {
            "browser.urlbar.suggest.trending" = false;
            "browser.urlbar.trimURLs" = false;

            "full-screen-api.transition-duration.enter" = "0 0";
            "full-screen-api.transition-duration.leave" = "0 0";
            "full-screen-api.warning.delay" = -1;
            "full-screen-api.warning.timeout" = 0;

            "browser.newtabpage.introShown" = false;
            "browser.urlbar.resultMenu.keyboardAccessible" = false;
            "widget.use-xdg-desktop-portal.file-picker" = 1;
            "browser.tabs.tabmanager.enabled" = true; # BUG: if false, screen jumps 1px up/down everytime a tab is closed
            "network.trr.mode" = 2; # DOH
            # enable extensions in mozilla sites
            "extensions.webextensions.restrictedDomains" = "";
            "privacy.resistFingerprinting.block_mozAddonManager" = true;
            "browser.translations.select.enable" = false;
            "browser.gesture.swipe.left" = ""; # bullshit
            "browser.gesture.swipe.right" = ""; # bullshit2
            "app.normandy.enabled" = false;
            "app.shield.optoutstudies.enabled" = false;
            "browser.protections_panel.infoMessage.seen" = true; # disable tracking protection info
            "dom.private-attribution.submission.enabled" = false; # stop doing dumb stuff mozilla

            "beacon.enabled" = false; # No bluetooth location BS in my webbrowser please
            "device.sensors.enabled" = false; # This isn't a phone
            "geo.enabled" = false; # Disable geolocation alltogether

            # Disable telemetry for privacy reasons
            "toolkit.telemetry.archive.enabled" = false;
            "toolkit.telemetry.enabled" = false; # enforced by nixos
            "toolkit.telemetry.server" = "";
            "toolkit.telemetry.unified" = false;
            "extensions.webcompat-reporter.enabled" = false; # don't report compability problems to mozilla
            "datareporting.policy.dataSubmissionEnabled" = false;
            "datareporting.healthreport.uploadEnabled" = false;
            "browser.ping-centre.telemetry" = false;
            "browser.urlbar.eventTelemetry.enabled" = false; # (default)

            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "browser.sessionstore.restore_pinned_tabs_on_demand" = true;
            "browser.compactmode.show" = true;
            "browser.toolbars.bookmarks.visibility" = "always";
            "browser.uidensity" = 1;
            "browser.download.autohideButton" = false;
            "ui.key.menuAccessKeyFocuses" = false;
            "ui.key.menuAccessKey" = 0;
            "findbar.highlightAll" = true;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.newtabpage.activity-stream.system.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "services.sync.prefs.sync.browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "services.sync.prefs.sync.browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.feeds.topsites" = false;
            "browser.newtabpage.activity-stream.showSearch" = false;
            "browser.startup.page" = 3; # restore previous session
            "trailhead.firstrun.didSeeAboutWelcome" = true; # Disable welcome splash
            "general.autoScroll" = true; # Drag middle-mouse to scroll
            "extensions.pocket.enabled" = false;
            "media.ffmpeg.vaapi.enabled" = true; # Enable hardware video acceleration
            "browser.aboutConfig.showWarning" = false;
          };
        };
      };
    };
}
