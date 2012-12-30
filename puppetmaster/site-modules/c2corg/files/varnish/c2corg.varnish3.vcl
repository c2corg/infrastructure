backend symfony {
  .host = "192.168.192.4";
  .port = "80";
  .probe = {
    .request =
      "HEAD /probe.txt HTTP/1.1"
      "Host: www.camptocamp.org"
      "Connection: close"
      "Accept-Encoding: foo/bar";
    .timeout = 1 s;
    .interval = 5 s;
    .window = 5;
    .threshold = 2;
  }
}

backend failover {
  .host = "192.168.192.70";
  .port = "80";
  .probe = {
    .request =
      "HEAD /probe.txt HTTP/1.1"
      "Host: www.camptocamp.org"
      "Connection: close"
      "Accept-Encoding: foo/bar";
    .timeout = 1 s;
    .interval = 5 s;
    .window = 5;
    .threshold = 2;
  }
}

backend stats {
  .host = "192.168.192.75";
  .port = "8000";
}

backend meta {
  .host = "192.168.192.4";
  .port = "80";
}

backend metaskirando {
  .host = "192.168.192.4";
  .port = "80";
}

sub vcl_recv {

  if ( req.url == "/probe.txt" ) {
    // switch to eject varnish from haproxy
    error 200 "I am healthy";
    //error 502 "I am sick";
  }

  /* backend definition */
  if (req.http.host ~ "^s\..*camptocamp\.org") {
    set req.backend = symfony;

    /* everything should get served directly from cache */
    remove req.http.Cookie;
  }

  elsif (req.http.host ~ "(www|m)\..*camptocamp\.org" || req.http.host ~ "^camptocamp\.org") {
    set req.backend = symfony;

    /* allow static content to get served directly from cache */
    if (req.url ~ "\.(gif|png|jpg|jpeg|svg)$") {
      remove req.http.Cookie;
    }
  }

  elsif (req.http.host ~ "^stats\..*camptocamp\.org") {
    set req.backend = stats;
  }

  elsif (req.http.host ~ "^meta\..*camptocamp\.org") {
    set req.backend = meta;
  }

  elsif (req.http.host ~ "^metaskirando\..*camptocamp\.org") {
    set req.backend = metaskirando;
  }

  else {
    error 404 "Unknown virtual host";
  }

  /* in case symfony is dead, use failover backend */
  if (req.backend == symfony && !req.backend.healthy) {
    set req.backend = failover;
  }

  /* in case both backends are down, serve expired content from cache */
  elsif (req.backend == failover && !req.backend.healthy) {
    remove req.http.Cookie;
    set req.grace = 14d;
    return(lookup);
  }
}

sub vcl_fetch {

  if (req.http.host ~ "^s\..*camptocamp\.org") {

    /* everything should get served directly from cache */
    remove beresp.http.Set-Cookie;
  }

  elsif (req.http.host ~ "(www|m)\..*camptocamp\.org" || req.http.host ~ "^camptocamp\.org") {
    if (req.url ~ "\.(gif|png|jpg|jpeg)$") {
      // allow pictures to get stored in cache
      remove beresp.http.Set-Cookie;
    } else {
      set beresp.ttl = 6h; // default TTL for generated content
    }
  }

  set beresp.grace = 14d; // time to keep expired objects in cache

}

sub vcl_deliver {

  // Add a header indicating hit/miss
  if (obj.hits > 0) {
    set resp.http.X-Cache = "HIT";
    set resp.http.X-Cache-Hits = obj.hits;
  } else {
    set resp.http.X-Cache = "MISS";
  }
}
