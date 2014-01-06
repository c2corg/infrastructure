/*
 * This script parses Meteofrance's snow bulletins and renders associated images
 */

var system = require("system"),
    webPage = require("webpage"),
    fs = require("fs");

var config = {
  base_url: "http://www.meteofrance.com/previsions-meteo-montagne/bulletin-avalanches/",
  json_file: "meteofrance.json",
  user_agent: "MFBot/1.0 (phantomjs/camptocamp.org)",
  options: {
    debug: false
  },
  departments: [{
    id: "74",
    url: "haute-savoie/avdept74",
    name: "Haute-Savoie",
    mountain_ranges: [{
      name: "Chablais",
      url: "chablais/OPP01",
      id: "OPP01"
    }, {
      name: "Aravis",
      url: "aravis/OPP02",
      id: "OPP02"
    }, {
      name: "Mont-Blanc",
      url: "mont-blanc/OPP03",
      id: "OPP03"
    }]
  }, {
    id: "73",
    url: "savoie/avdept73",
    name: "Savoie",
    mountain_ranges: [{
      name: "Bauges",
      url: "bauges/OPP04",
      id: "OPP04"
    }, {
      name: "Beaufortin",
      url: "beaufortin/OPP05",
      id: "OPP05"
    }, {
      name: "Haute-Tarentaise",
      url: "haute-tarentaise/OPP06",
      id: "OPP06"
    }, {
      name: "Maurienne",
      url: "maurienne/OPP09",
      id: "OPP09"
    }, {
      name: "Vanoise",
      url: "vanoise/OPP10",
      id: "OPP10"
    }, {
      name: "Haute-Maurienne",
      url: "haute-maurienne/OPP11",
      id: "OPP11"
    }]
  }, {
    id: "38",
    url: "isere/avdept38",
    name: "Isère",
    mountain_ranges: [{
      name: "Chartreuse",
      url: "chartreuse/OPP07",
      id: "OPP07"
    }, {
      name: "Belledonne",
      url: "belledonne/OPP08",
      id: "OPP08"
    }, {
      name: "Grandes-Rousses",
      url: "grandes-rousses/OPP12",
      id: "OPP12"
    }, {
      name: "Vercors",
      url: "vercors/OPP14",
      id: "OPP14"
    }, {
      name: "Oisans",
      url: "oisans/OPP15",
      id: "OPP15"
    }]
  }, {
    id: "04",
    url: "alpes-de-haute-provence/avdept04",
    name: "Alpes-de-Haute-Provence",
    mountain_ranges: [{
      name: "Ubaye",
      url: "ubaye/OPP21",
      id: "OPP21"
    }, {
      name: "Haut-Var/Haut-Verdon",
      url: "haut-var-haut-verdon/OPP22",
      id: "OPP22"
    }]
  }, {
    id: "06",
    url: "alpes-maritimes/avdept06",
    name: "Alpes-Maritime",
    mountain_ranges: [{
      name: "Haut-Var/Haut-Verdon",
      url: "haut-var-haut-verdon/OPP22",
      id: "OPP22"
    }, {
      name: "Mercantour",
      url: "mercantour/OPP23",
      id: "OPP23"
    }]
  }, {
    id: "05",
    url: "hautes-alpes/avdept05",
    name: "Hautes-Alpes",
    mountain_ranges: [{
      name: "Thabor",
      url: "thabor/OPP13",
      id: "OPP13"
    }, {
      name: "Pelvoux",
      url: "pelvoux/OPP16",
      id: "OPP16"
    }, {
      name: "Queyras",
      url: "queyras/OPP17",
      id: "OPP17"
    }, {
      name: "Dévoluy",
      url: "devoluy/OPP18",
      id: "OPP18"
    }, {
      name: "Champsaur",
      url: "champsaur/OPP19",
      id: "OPP19"
    }, {
      name: "Embrunnais-Parpaillon",
      url: "embrunnais-parpaillon/OPP20",
      id: "OPP20"
    }]
  }, {
    id: "2a",
    url: "corse-du-sud/avdept2a",
    name: "Corse-du-Sud",
    mountain_ranges: [{
      name: "Cinto-Rotondo",
      url: "cinto-rotondo/OPP40",
      id: "OPP40"
    }, {
      name: "Renoso",
      url: "renoso/OPP41",
      id: "OPP41"
    }]
  }, {
    id: "2b",
    url: "haute-corse/avdept2b",
    name: "Haute-Corse",
    mountain_ranges: [{
      name: "Cinto-Rotondo",
      url: "cinto-rotondo/OPP40",
      id: "OPP40"
    }, {
      name: "Renoso",
      url: "renoso/OPP41",
      id: "OPP41"
    }]
  }, {
    id: "andorre",
    url: "andorre/avandorre",
    name: "Andorre",
    mountain_ranges: [{
      name: "Andorre",
      url: "andorre/OPP71",
      id: "OPP71"
    }]
  }, {
    id: "09",
    url: "ariege/avdept09",
    name: "Ariège",
    mountain_ranges: [{
      name: "Couserans",
      url: "couserans/OPP69",
      id: "OPP69"
    }, {
      name: "Haute-Ariège",
      url: "haute-ariege/OPP70",
      id: "OPP70"
    }, {
      name: "Orlu-St-Barthelemy",
      url: "orlu-st-barthelemy/OPP72",
      id: "OPP72"
    }]
  }, {
    id: "31",
    url: "haute-garonne/avdept31",
    name: "Haute-Garonne",
    mountain_ranges: [{
      name: "Luchonnais",
      url: "luchonnais/OPP68",
      id: "OPP68"
    }, {
      name: "Couserans",
      url: "couserans/OPP69",
      id: "OPP69"
    }]
  }, {
    id: "65",
    url: "hautes-pyrenees/avdept65",
    name: "Hautes-Pyrénées",
    mountain_ranges: [{
      name: "Haute-Bigorre",
      url: "haute-bigorre/OPP66",
      id: "OPP66"
    }, {
      name: "Aure-Louron",
      url: "aure-louron/OPP67",
      id: "OPP67"
    }]
  }, {
    id: "64",
    url: "pyrenees-atlantiques/avdept64",
    name: "Pyrénées-Atlantiques",
    mountain_ranges: [{
      name: "Pays-Basque",
      url: "pays-basque/OPP64",
      id: "OPP64"
    }, {
      name: "Aspe-Ossau",
      url: "aspe-ossau/OPP65",
      id: "OPP65"
    }]
  }, {
    id: "66",
    url : "pyrenees-orientales.avdept66",
    name: "Pyrénées-Orientales",
    mountain_ranges: [{
      name: "Capcir-Puymorens",
      url: "capcir-puymorens/OPP73",
      id: "OPP73"
    }, {
      name: "Cerdagne-Canigou",
      url: "cerdagne-canigou/OPP74",
      id: "OPP74"
    }]
  }]
};

function usage() {
  console.log("Usage: " + args[0] + " [option] ... department_code");
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
        console.log("Unknown option: " + args[i]);
        phantom.exit(1);
      }
      break;
  }
}

var dpt_code = args[args.length - 1];
var dpt = null;
for (i=0; i<config.departments.length; i++) {
  if (config.departments[i].id === dpt_code) {
    dpt = config.departments[i];
    break;
  }
}
if (!dpt) {
  console.log("Invalid department code");
  usage();
  phantom.exit(1);
}

function handle_dpt_pages(urls, urlClbk, finalClbk) {
  var page, next, retrieve, output = "";

  next = function(status, url) {
    page.close();
    urlClbk(status, url);
    return retrieve();
  };

  retrieve = function() {
    if (urls.length > 0) {
      var range = urls.shift();
      page = webPage.create();
      page.settings.userAgent = config.user_agent;

      return page.open(config.base_url + range.url, function(status) {
        if (status === "success") {
          return window.setTimeout((function() {
            info("Parsing " + (config.base_url + range.url));

            try {
              output += page.evaluate(function(url) {
                var section = $(".article-row:eq(0)");
                // mountain range title
                return "<a href='" + url + "'>" + section.find("h3")[0].outerHTML + "</a>"+
                // risk estimation
                       "<h3>" + section.find("h4").text() + "</h3>" +
                       section.find("p")[0].outerHTML;
              }, config.base_url + range.url);

              // risk cartouche
              var bcr = page.evaluate(function() {
                return $("#cartouche-risque")[0].getBoundingClientRect();
              });
              page.clipRect = {
                top: bcr.top,
                left: bcr.left + 22,
                width: 200,
                height: 80
              };
              page.render("mf_" + range.id + "_risk_cartouche.png");
              info("Rendered image mf_" + range.id + "_risk_cartouche.png");
              output += "<div><img src='mf_" + range.id + "_risk_cartouche.png' /></div>";

              // risk estimation & notation
              output += page.evaluate(function() {
                var section = $(".article-row:eq(0)");
                return section.children("p:eq(1)")[0].outerHTML + 
                       section.find(".bloc-last .right-box").html();
              });

              // snow stability
              output += page.evaluate(function() {
                var section = $(".article-row:eq(1)");
                return "<h3>" + section.find("h4").text() + "</h3>" +
                       section.find("p")[0].outerHTML +
                       $(".article-row:eq(2) h3")[0].outerHTML;
              });

              // recent snow
              bcr = page.evaluate(function() {
                return $("#epaisseur-container")[0].getBoundingClientRect();
              });
              page.clipRect = {
                top: bcr.top,
                left: bcr.left + 20,
                width: bcr.width,
                height: bcr.height
              };
              page.render("mf_" + range.id + "_chart.png");
              info("Rendered image mf_" + range.id + "_chart.png");
              output += "<div><img src='mf_" + range.id + "_chart.png' /></div>";

              // snow quality
              output += page.evaluate(function() {
                var section = $(".article-row:eq(3) .bloc-content");
                return section.find("h3")[0].outerHTML +
                       section.find("p")[0].outerHTML +
                       section.find("h3")[1].outerHTML;
              });

              // snow height figure
              bcr = page.evaluate(function() {
                return $(".epaisseur-neige-main-box")[0].getBoundingClientRect();
              });
              page.clipRect = {
                top: bcr.top + 1,
                left: bcr.left + 23,
                width: bcr.width - 2,
                height: bcr.height - 3
              };
              page.render("mf_" + range.id + "_snow.png");
              info("Rendered image mf_" + range.id + "_snow.png");
              output += "<div><img src='mf_" + range.id + "_snow.png' /></div>";

              // TODO weather forecast?

              // next risk
              output += page.evaluate(function() {
                var title = $(".article-row.last h4");
                var content = "<h3>" + title.text() + "</h3>";

                var options = title.siblings(".option");
                content += "<ul>";
                for (var i=0; i<options.length; i++) {
                  content += "<li>" + options[i].firstChild.nodeValue;
                  switch (options.eq(i).find("span").text()) {
                    case "low":
                      content += " &#2198;";
                      break;
                    case "medium":
                      content += " &#x2192;";
                      break;
                    case "high":
                      content += " &#x2197;";
                      break;
                    default:
                      content += " ?";
                      break;
                  }
                  content += "</li>";
                }
                content += "</ul>";

                return content;
              });

              return next(status, range.url);
            } catch (e) {
              console.log("An error occured when handling a page");
              phantom.exit(1);
            }
          }), 1000); // we need some time for the recent snow graph to appear
        } else {
          console.log("An error occured when retrieving a page");
          phantom.exit(1);
        }
      });
    } else {
      return finalClbk(output);
    }
  };

  return retrieve();
}

handle_dpt_pages(dpt.mountain_ranges, function(status, url) {
  if (status === "success") {
    return info("Correctly retrieved " + url);
  } else {
    return info("Failed when retrieving " + url);
  }
}, function(output) {
  var json = fs.exists(config.json_file) && fs.isFile(config.json_file) && JSON.parse(fs.read(config.json_file)) || {};

  json[dpt.id] = {
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
});
