class c2corg::webserver::svg {

  include c2corg::webserver

  /* Fonts used by SVG routines */
  package { [
    "msttcorefonts", "gsfonts", "texlive-fonts-extra",
    "texlive-fonts-recommended", "gsfonts-x11",
    "ttf-bitstream-vera", "ttf-dejavu"]:
  }
}
