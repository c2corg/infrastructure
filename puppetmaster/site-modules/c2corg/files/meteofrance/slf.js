/*
 * This script parses SLF's snow bulletins and renders associated images
 * It must be run with phantomjs
 */

var system = require("system"),
    webPage = require("webpage"),
    fs = require("fs");

var config = {
  languages: [ "FR", "DE", "IT", "EN" ],
  base_avalanche_url: "http://www.slf.ch/lawinenbulletin/lawinengefahr/index_",
  base_snowpack_url: "http://www.slf.ch/lawinenbulletin/schneedecke_wetter/index_",
  json_file: "slf.json",
  user_agent: "SLFBot/1.0 (phantomjs/camptocamp.org)",
  options: {
    debug: false
  }
};

function usage() {
  console.log("Usage: " + args[0] + " [option] ... language");
  console.log("Available options: ");
  console.log("    --help / -h         : display this message");
  console.log("    --debug / -d        : display debug information");
  console.log("    --working-dir=<dir> : change working directory");
}

function info(msg) {
  if (config.options.debug) {
    console.log("> " + msg);
  }
}

// arguments parsing
var args = system.args;

if (args.length === 1) {
  usage();
  phantom.exit(1);
}

for (var i=1; i<args.length; i++) {
  var matches = /([a-zA-Z-]+)(=(.*))?/.exec(args[i]);

  if (matches) {
    var option = matches[1],
        value = matches[3];
  }

  switch (option) {
    case "--help":
    case "-h":
      usage();
      phantom.exit();
    case "--debug":
    case "-d":
      config.options.debug = true;
      break;
    case "--working-dir":
      if (!fs.exists(value)) {
        console.log("invalid working directory: " + value);
        phantom.exit(1);
      }
      info("changing working directory to " + value);
      fs.changeWorkingDirectory(value);
      break;
    default:
      if (i !== args.length - 1) {
        console.log("Unknown option: " + args[i] + i + " " + length);
        phantom.exit(1);
      }
      break;
  }
}

var language = args[args.length - 1];
if (config.languages.indexOf(language) < 0) {
  console.log("Invalid language code");
  usage();
  phantom.exit(1);
}

function handle_bulletin(language) {
  var page, handle_avalanche, handle_snowpack, output = "";

  handle_avalanche = function() {

    page = webPage.create();
    page.settings.userAgent = config.user_agent;

    return page.open(config.base_avalanche_url + language, function(status) {
      if (status === "success") {
        return window.setTimeout(function() {
          info("Parsing avalanche page " + language);

          try {
            // section title
            output += page.evaluate(function() {
              return "<h2>" + $(".level1_on").text() + "</h2>";
            });

            // (flash) + edition time
             output += page.evaluate(function() {
               var div = $(".lawinenbulletin-header");
               div.find("h2").replaceWith(function() {
                 return "<div>" + this.innerHTML + "</div>";
               });
               div.find("a").remove(".infolink");
               return div[0].outerHTML;
             });

            // map
            var bcr = page.evaluate(function() {
              $(".mc-container").hide();
              return $("#lwp-dynmap").css("backgroundColor", "white")[0].getBoundingClientRect();
            });
            page.clipRect = {
              top: bcr.top,
              left: bcr.left,
              width: bcr.width,
              height: bcr.height
            };
            page.render("slf_" + language + "_map.png");
            info("Rendered image slf_" + language + "_map.png");
            output += "<div><img src='slf_" + language + "_map.png' /></div>";

            bcr = page.evaluate(function() {
              $("a.infolink").css("visibility", "hidden");
              return $(".gk-caption").css("backgroundColor", "white").css("marginTop", 0)[0].getBoundingClientRect();
            });
            page.clipRect = {
              top: bcr.top,
              left: bcr.left,
              width: bcr.width,
              height: bcr.height
            };
            page.render("slf_gk_caption.png");
            info("Rendered image slf_gk_caption.png");
            output += "<div><img src='slf_gk_caption.png' /></div>";

            // find different zones
            var zones = page.evaluate(function() {
              var html = "";
              $(".ui-dialog").each(function(i) {
                $this = $(this);
                // risk level
                html += "<h3>" + String.fromCharCode(65 + i) + " - " + $this.find(".dangerlevel").text() + "</h3>";
                //html += "%%IMG_" + i + "_OVERVIEW%%";
                // how long is it gonna last without breaking :)
                var id = /ui-dialog-title-lwp-dynmap-dialog-([0-9]+)/.exec($this.attr("aria-labelledby"))[1];
                html += "<img src='http://www.slf.ch/avalanche/bulletin/it/gk1_" + id + "_a_0.png' width='150' />";
                // snow type
                html += $this.find("h4")[0].outerHTML;
                // exposition
                html += $this.find("h5")[0].outerHTML;
                html += "%%IMG_" + i + "_SUMMARY%%";
                html += $this.find("p")[0].outerHTML;
                // dangerous places
                html += $this.find("h5")[1].outerHTML;
                html += $this.find("p")[1].outerHTML;
              });

              return html;
            });

            var zoneCount = zones.match(/%%IMG_[0-9]_SUMMARY%%/g).length;
            info(zoneCount + " zones found");

            for (i=0; i<zoneCount; i++) {
              // hide all dialog except the one we care for, and capture the summary image
              bcr = page.evaluate(function(i) {
                $(".ui-dialog").hide();
                return $(".ui-dialog").eq(i).show().css("top", 0).find("img")[0].getBoundingClientRect();
              }, i);
              page.clipRect = {
                top: bcr.top,
                left: bcr.left,
                width: bcr.width,
                height: bcr.height
              };
              page.render("slf_zone_" + String.fromCharCode(65 + i) + "_summary.png");
              info("Rendered image slf_zone_" + String.fromCharCode(65 + i) + "_summary.png");
              zones = zones.replace("%%IMG_" + i + "_SUMMARY%%", "<img src='slf_zone_" + String.fromCharCode(65 + i) + "_summary.png' />");
            }
            output += zones;

            page.close();
            return handle_snowpack();
          } catch(e) {
            console.log("An error occured when handling avalanche page " + language);
            phantom.exit(1);
          }
        }, 1000);
      } else {
        console.log("An error occured when retrieving avalanche page for " + language);
        phantom.exit(1);
      }
    });
  };

  handle_snowpack = function() {

    page = webPage.create();
    page.settings.userAgent = config.user_agent;

    return page.open(config.base_snowpack_url + language, function(status) {
      if (status === "success") {
         info("Parsing snowpack page " + language);

         try {
           // title
           output += page.evaluate(function() {
             return "<h2>" + $(".level1_on").text() + "</h2>";
           });

           // (flash) + edition time
           output += page.evaluate(function() {
             var div = $(".lawinenbulletin-header");
             div.find("h2").replaceWith(function() {
               return "<div>" + this.innerHTML + "</div>";
             });
             div.find("a").remove(".infolink");
             return div[0].outerHTML;
           });

           // content
           output += page.evaluate(function() {
             $(".header-3-grey-smal").replaceWith(function() {
               return "<h3>" + this.innerHTML + "</h3>";
             });
             $(".header-5-weather").replaceWith(function() {
               return "<h5>" + this.innerHTML + "</h5>";
             });

             var html = "";
             $(".snow-and-weather-block").each(function() {
               html+= this.outerHTML;
             });

             return html;
           });

           // weather footer
           output += page.evaluate(function() {
             return "<div><small>" + $(".footer-meteo-web")[0].innerHTML + "</small></div>";
           });

           page.close();
           return finalize();
         } catch(e) {
           console.log("An error occured when handling snowpack page " + language);
           phantom.exit(1);
         }
      } else {
         console.log("An error occured when retrieving snowpack page for " + language);
         phantom.exit(1);
      }
    });
  };

  finalize = function(ouput) {
    var json = fs.exists(config.json_file) && fs.isFile(config.json_file) && JSON.parse(fs.read(config.json_file)) || {};

    json[language] = {
      content: output,
      updated: Date()
    };
    try {
      fs.write(config.json_file, JSON.stringify(json));
    } catch (e) {
      console.log("Cannot write to file");
      phantom.exit(1);
    }

    info("Finished script correctly");
    info("Output is:");
    info(output);
    phantom.exit();
  };

  return handle_avalanche();
}

handle_bulletin(language);
