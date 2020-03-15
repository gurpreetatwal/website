# vi: ft=nginx

# https://www.gatwal.com -> https://gatwal.com
server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;

  server_name www.gatwal.com;

  ssl_certificate /etc/letsencrypt/live/gatwal.com/fullchain.pem; # managed by Certbot
  ssl_certificate_key /etc/letsencrypt/live/gatwal.com/privkey.pem; # managed by Certbot

  ##
  ## Referrer Policy (enabled by default)
  ##
  ## see: https://scotthelme.co.uk/a-new-security-header-referrer-policy/

  set $server_referrer_policy "no-referrer-when-downgrade";

  ##
  ## X-XSS-Protection (enabled by default)
  ##

  set $server_x_xss_protection "1; mode=block";

  return 301 $scheme://$host$request_uri;

}

server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;

  server_name gatwal.com;

  error_log /var/log/nginx/gatwal.error.log;
  access_log /var/log/nginx/gatwal.access.log;

  ssl_certificate /etc/letsencrypt/live/gatwal.com/fullchain.pem; # managed by Certbot
  ssl_certificate_key /etc/letsencrypt/live/gatwal.com/privkey.pem; # managed by Certbot

  root /home/static/sites/gatwal.com;

  location / {
    # First attempt to serve request as file, then
    # as directory, then fall back to displaying a 404.
    try_files $uri $uri/ =404;
  }

  ##
  ## Custom Error Pages
  ##

  # error_page 404 /404.html;
  # location = /404.html {
  #   root /usr/share/nginx/html;
  #   internal;
  # }

  # error_page 500 502 503 504 /custom_50x.html;
  # location = /custom_50x.html {
  #   root /usr/share/nginx/html;
  #   internal;
  # }

  ##
  ## Cors Settings
  ##

  # set $server_cors "*";
  # include h5bp/cross-origin/requests.conf
  # include h5bp/cross-origin/resource_timing.conf

  ##
  ## System File Blocker
  ##

  include h5bp/location/security_file_access.conf;

  ##
  ## Versioned file names
  ##
  ## Enable this if the build process doesn't produce versioned file.
  ## This will  allow you to use "virtual URLs" ie file.1.2.js for
  ## a file named file.js

  # include h5bp/location/web_performance_filename-based_cache_busting.conf

  ##
  ## CSP
  ##

  # set $server_content_security_policy "";
  # include h5bp/security/content-security-policy.conf

  ##
  ## Referrer Policy (enabled by default)
  ##
  ## see: https://scotthelme.co.uk/a-new-security-header-referrer-policy/

  set $server_referrer_policy "no-referrer-when-downgrade";

  ##
  ## X-Frame-Options
  ##

  # set $server_x_frame_options "DENY";
  # include h5bp/security/x-frame-options.conf

  ##
  ## X-XSS-Protection (enabled by default)
  ##

  set $server_x_xss_protection "1; mode=block";

  ##
  ## Cache Expiration
  ##

  include h5bp/web_performance/cache_expiration.conf;

  ##
  ## Prebuilt Gzip or Brotli files
  ##
  ## This will cause 2 IO requests if the .gz (or .br) file is not available

  # gzip_static on;
  # brotli_static on;

}
