class c2corg::apacheconf::common {

  apache::vhost { "camptocamp.org":
    aliases => [
      "www.camptocamp.org",
      "s.camptocamp.org",
      "m.camptocamp.org",
      "symfony-backend.c2corg"],
    docroot => "/srv/www/camptocamp.org/web",
    cgibin  => false,
  }

  file { "/var/www/camptocamp.org/conf/camptocamp.org.conf":
    ensure  => link,
    target  => "/srv/www/camptocamp.org/config/camptocamp.org.conf",
    require => Apache::Vhost["camptocamp.org"],
  }

  apache::vhost { "meta.camptocamp.org":
    docroot => "/srv/www/meta.camptocamp.org/web",
    cgibin  => false,
  }

  file { "/var/www/meta.camptocamp.org/conf/camptocamp.org.conf":
    ensure  => link,
    target  => "/srv/www/meta.camptocamp.org/config/meta.camptocamp.org.conf",
    require => Apache::Vhost["meta.camptocamp.org"],
  }

}


class c2corg::apacheconf::prod inherits c2corg::apacheconf::common {

  include c2corg::apacheconf::redirections
  include apache::collectd

}

class c2corg::apacheconf::preprod inherits c2corg::apacheconf::common {

  include c2corg::apacheconf::redirections
  include apache::collectd

  Apache::Vhost["camptocamp.org"] {
    aliases +> ["www.preprod.c2corg", "s.preprod.c2corg", "m.preprod.c2corg"],
  }
}

class c2corg::apacheconf::dev inherits c2corg::apacheconf::common {

  Apache::Vhost["camptocamp.org"] {
    enable_default => false,
    aliases +> [$hostname, $fqdn],
  }
}


class c2corg::apacheconf::redirections {

  /* redirect requests without www */

  apache::directive { "avoid being indexed twice by search engines":
    vhost     => "camptocamp.org",
    directive => '
RewriteEngine On
RewriteCond %{HTTP_HOST} =camptocamp.org
RewriteRule /(.*)   http://www.camptocamp.org/$1 [R=301,L]
'
  }

  /* v4 to v5 URL redirections */

  apache::vhost { "redirect-v4v5":
    cgibin  => false,
    aliases => [
      "skirando.camptocamp.com",
      "alpinisme.camptocamp.com",
      "escalade.camptocamp.com",
      "www.skirando.ch",
      "skirando.ch",
      "www.escalade-online.com",
      "escalade-online.com"],
  }

  file { "/var/www/redirect-v4v5/private/v4v5map.txt":
    ensure  => present,
    source  => "puppet:///c2corg/apache/v4v5map.txt",
    notify  => Exec["make v4v5map"],
    require => Apache::Vhost["redirect-v4v5"],
  }

  exec { "make v4v5map":
    command     => "httxt2dbm -i v4v5map.txt -o v4v5map.dbm",
    cwd         => "/var/www/redirect-v4v5/private/",
    refreshonly => true,
    before      => Apache::Directive["redirect-v4v5"],
  }

  apache::directive { "redirect-v4v5":
    vhost     => "redirect-v4v5",
    directive => '
# This is related to https://dev.camptocamp.org/trac/c2corg/ticket/196

RewriteEngine on
#RewriteLog /tmp/rewrite.log
#RewriteLogLevel 3

# generate v4v5map.txt with "makev4v5map.sh > v4v5map.txt"
# generate v4v5map.dbm with "httxt2dbm -i v4v5map.txt -o v4v5map.dbm"
#RewriteMap v4v5 txt:/var/www/redirect-v4v5/private/v4v5map.txt
RewriteMap v4v5 dbm:/var/www/redirect-v4v5/private/v4v5map.dbm

# redirect legacy names to *.camptocamp.com
RewriteCond %{SERVER_NAME} ^(www.skirando.ch|skirando.ch)$
RewriteRule ^(.*)$    http://skirando.camptocamp.com/$1 [R=301,L]

RewriteCond %{SERVER_NAME} ^(www.escalade-online.com|escalade-online.com)$
RewriteRule ^(.*)$    http://escalade.camptocamp.com/$1 [R=301,L]

# redirect based on v4 to v5 map
RewriteCond %{SERVER_NAME} ^skirando.camptocamp.com$
RewriteRule ^(.*)/(sommet|gipfel|vetta|summit|cumbre|rewrite_summit)([0-9]{1,6})(.html)(.*)$  http://www.camptocamp.org/summits/${v4v5:a$3} [R=301,L]
RewriteCond %{SERVER_NAME} ^skirando.camptocamp.com$
RewriteRule ^(.*)/(itineraire|route|itinerario|rewrite_iti)([0-9]{1,6})(.html)(.*)$           http://www.camptocamp.org/routes/${v4v5:d$3} [R=301,L]
RewriteCond %{SERVER_NAME} ^skirando.camptocamp.com$
RewriteRule ^(.*)/(sortie|tour|gita|salida|outing|rewrite_outing)([0-9]{1,6})(.html)(.*)$     http://www.camptocamp.org/outings/${v4v5:f$3} [R=301,L]
RewriteCond %{SERVER_NAME} ^skirando.camptocamp.com$
RewriteRule ^(.*)/(photo|bild|fotografia|photograph|rewrite_photo)([0-9]{1,6})(.html)(.*)$    http://www.camptocamp.org/images/${v4v5:h$3} [R=301,L]

RewriteCond %{SERVER_NAME} ^alpinisme.camptocamp.com$
RewriteRule ^(.*)/(sommet|gipfel|vetta|summit|cumbre|rewrite_summit)([0-9]{1,6})(.html)(.*)$  http://www.camptocamp.org/summits/${v4v5:a$3} [R=301,L]
RewriteCond %{SERVER_NAME} ^alpinisme.camptocamp.com$
RewriteRule ^(.*)/(itineraire|route|itinerario|rewrite_iti)([0-9]{1,6})(.html)(.*)$           http://www.camptocamp.org/routes/${v4v5:e$3} [R=301,L]
RewriteCond %{SERVER_NAME} ^alpinisme.camptocamp.com$
RewriteRule ^(.*)/(sortie|tour|gita|salida|outing|rewrite_outing)([0-9]{1,6})(.html)(.*)$     http://www.camptocamp.org/outings/${v4v5:g$3} [R=301,L]
RewriteCond %{SERVER_NAME} ^alpinisme.camptocamp.com$
RewriteRule ^(.*)/(photo|bild|fotografia|photograph|rewrite_photo)([0-9]{1,6})(.html)(.*)$    http://www.camptocamp.org/images/${v4v5:i$3} [R=301,L]

RewriteCond %{SERVER_NAME} ^escalade.camptocamp.com$
RewriteRule ^(.*)/(area|site|sitio|gebiet|localita|rewrite_area)([0-9]{0,6})(.html)(.*)$      http://www.camptocamp.org/sites/${v4v5:b$3} [R=301,L]
RewriteCond %{SERVER_NAME} ^escalade.camptocamp.com$
RewriteRule ^(.*)/(sector|secteur|bereich|settore|rewrite_sector)([0-9]{0,6})(.html)(.*)$     http://www.camptocamp.org/sites/${v4v5:c$3} [R=301,L]
RewriteCond %{SERVER_NAME} ^escalade.camptocamp.com$
RewriteRule ^(.*)/(photo|bild|fotografia|photograph|rewrite_photo)([0-9]{1,6})(.html)(.*)$    http://www.camptocamp.org/images/${v4v5:j$3} [R=301,L]
RewriteCond %{SERVER_NAME} ^escalade.camptocamp.com$
RewriteRule ^.*/guide.html                                                                    http://www.camptocamp.org/sites [R=301,L]

RewriteCond %{QUERY_STRING} ^reason=cbrowse
RewriteRule ^.*/guide.html       http://www.camptocamp.org/summits [R=301,L]
RewriteCond %{QUERY_STRING} ^reason=ibrowse
RewriteRule ^.*/guide.html       http://www.camptocamp.org/routes [R=301,L]
RewriteCond %{QUERY_STRING} ^reason=sbrowse
RewriteRule ^.*/guide.html       http://www.camptocamp.org/outings [R=301,L]
RewriteCond %{QUERY_STRING} ^condpro=1
RewriteRule ^.*/guide.html       http://www.camptocamp.org/outings [R=301,L]
RewriteCond %{QUERY_STRING} ^reason=cond
RewriteRule ^.*/guide.html       http://www.camptocamp.org/outings/conditions [R=301,L]
RewriteCond %{QUERY_STRING} ^reason=rbrowse
RewriteRule ^.*/guide.html       http://www.camptocamp.org/areas [R=301,L]

RewriteRule ^.*/content.html     http://www.camptocamp.org/articles [R=301,L]
RewriteRule ^.*/categorie.*html  http://www.camptocamp.org/articles [R=301,L]

# catch all rules
RewriteRule ^.*/forum/.*$         http://www.camptocamp.org/forums/  [R=301,L]
RewriteRule ^.*/guide/c.*$        http://www.camptocamp.org/summits/ [R=301,L]
RewriteRule ^.*/guide/i.*$        http://www.camptocamp.org/routes/  [R=301,L]
RewriteRule ^.*/guide/s.*$        http://www.camptocamp.org/outings/ [R=301,L]
RewriteRule ^.*/(rewrite_topos|topos|guias|rewrite_biblio|biblio|biblioteca|library).*$     http://www.camptocamp.org/books/ [R=301,L]
RewriteRule ^.*/(rewrite_refuge|refuge|refugio|rifugio).*$      http://www.camptocamp.org/huts/ [R=301,L]

RewriteCond %{SERVER_NAME} ^skirando.camptocamp.com$
RewriteRule ^.*$      http://www.camptocamp.org/skitouring [R=301,L]

RewriteCond %{SERVER_NAME} ^escalade.camptocamp.com$
RewriteRule ^.*$      http://www.camptocamp.org/rock_climbing [R=301,L]

RewriteRule ^.*$      http://www.camptocamp.org/ [R=301,L]
',
  }
}
