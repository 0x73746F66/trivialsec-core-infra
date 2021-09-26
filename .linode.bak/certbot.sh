#!/usr/bin/env bash

if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker-compose is not installed.' >&2
  exit 1
fi

domains=(status.trivialsec.com www.langton.cloud docs.trivialsec.com)
rsa_key_size=4096
data_path="/root/letsencrypt"
email="chris@trivialsec.com" # Adding a valid address is strongly recommended
staging=0 # Set to 1 if you're testing your setup to avoid hitting request limits

if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  echo
fi

for domain in "${domains[@]}"; do
  path="/etc/letsencrypt/live/$domain"
  mkdir -p "$data_path/conf/live/$domain"

  dummy=$(docker-compose run --no-deps --use-aliases --rm --entrypoint "sh -c '[ -f ${path}/fullchain.pem ] && echo exist'" certbot)
  if [ -z "$dummy" ]; then
    echo "### Creating dummy certificate for $domain ..."
    docker-compose run --no-deps --use-aliases --rm --entrypoint "\
      openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
        -keyout '$path/privkey.pem' \
        -out '$path/fullchain.pem' \
        -subj '/CN=$domain'" certbot
    touch dummy-$domain
    echo
  fi

done

echo "### Starting nginx ..."
docker-compose up --force-recreate -d nginx
echo

sleep 5
for domain in "${domains[@]}"; do
  #if [ -f dummy-$domain ]; then
    echo "### Deleting dummy certificate for $domain ..."
    docker-compose run --no-deps --use-aliases --rm --entrypoint "\
      rm -Rf /etc/letsencrypt/live/$domain && \
      rm -Rf /etc/letsencrypt/archive/$domain && \
      rm -Rf /etc/letsencrypt/renewal/$domain.conf" certbot
    rm dummy-$domain
    echo

    echo "### Requesting Let's Encrypt certificate for $domain ..."

    # Select appropriate email arg
    case "$email" in
      "") email_arg="--register-unsafely-without-email" ;;
      *) email_arg="--email $email" ;;
    esac

    # Enable staging mode if needed
    if [ $staging != "0" ]; then staging_arg="--staging"; fi

    docker-compose run --no-deps --use-aliases --rm --entrypoint "\
      certbot certonly --webroot -w /var/www/certbot \
        $staging_arg \
        $email_arg \
        -d $domain \
        --rsa-key-size $rsa_key_size \
        --agree-tos \
        --force-renewal" certbot
    echo
  #fi

done

echo "### Reloading nginx ..."
docker-compose exec nginx nginx -s reload
