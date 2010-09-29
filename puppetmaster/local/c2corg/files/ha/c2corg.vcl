backend c2corg {
  .host = "192.168.192.3";
  .port = "80";
  .probe = {
    .url = "/probe.txt";
    .timeout = 1 s;
    .interval = 5 s;
    .window = 5;
    .threshold = 2;
  }
}

sub vcl_recv {

  if ( req.url == "/probe.txt" ) {
    error 200 "I am healthy";
  }
}

/*
 * Add a header indicating hit/miss
 */
sub vcl_deliver {
  if (obj.hits > 0) {
    set resp.http.X-Cache = "HIT";
    set resp.http.X-Cache-Hits = obj.hits;
  } else {
    set resp.http.X-Cache = "MISS";
  }
}

