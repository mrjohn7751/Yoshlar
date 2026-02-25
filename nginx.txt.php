server {
    server_name yoshlarnazorati.uz;

    # ========================
    # FLUTTER WEB
    # ========================
    root /var/www/Yoshlar/build/web;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # ========================
    # LARAVEL API
    # ========================
    location /api {
        alias /var/www/Yoshlar/backend/public;
        try_files $uri $uri/ @laravel;

        location ~ \.php$ {
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME /var/www/Yoshlar/backend/public/index.php;
            fastcgi_param REQUEST_URI $request_uri;
            fastcgi_pass unix:/run/php/php8.4-fpm.sock;
        }
    }

    location @laravel {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME /var/www/Yoshlar/backend/public/index.php;
        fastcgi_param REQUEST_URI $request_uri;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }

    # ========================
    # STORAGE (rasmlar)
    # ========================
    location /storage {
        alias /var/www/Yoshlar/backend/storage/app/public;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    client_max_body_size 50M;

    access_log /var/log/nginx/yoshlarnazorat_access.log;
    error_log /var/log/nginx/yoshlarnazorat_error.log;

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/yoshlarnazorati.uz/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/yoshlarnazorati.uz/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}

server {
    if ($host = yoshlarnazorati.uz) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

    listen 80;
    server_name yoshlarnazorati.uz;
    return 404; # managed by Certbot
}
