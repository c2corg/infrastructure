class c2corg::webserver::svg {

  include c2corg::webserver

  package { "inkscape": ensure => present }

  /* Fonts used by SVG routines */
  package { [
    "ttf-mscorefonts-installer", "gsfonts", "texlive-fonts-extra",
    "texlive-fonts-recommended", "gsfonts-x11",
    "ttf-bitstream-vera", "ttf-dejavu"]:
  }
}
