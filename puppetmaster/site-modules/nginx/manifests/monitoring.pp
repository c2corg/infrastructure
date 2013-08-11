class nginx::monitoring {

  nginx::site { 'nginx_status':
    content => '
server {
  listen 127.0.0.1:9000;
  server_name localhost;

  location /nginx_status {
    stub_status on;
    access_log off;
    allow 127.0.0.1;
    deny all;
  }
}
',
  }

  collectd::config::plugin { 'nginx monitoring':
    plugin   => 'nginx',
    settings => 'URL "http://127.0.0.1:9000/nginx_status"',
    require  => Service['nginx'],
  }

}
