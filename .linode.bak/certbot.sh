#!/usr/bin/env bash

if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker-compose is not installed.' >&2
  exit 1
fi

personal_domains=(www.langton.cloud)
personal_email="chris@langton.cloud"
trivialsec_domains=(status.trivialsec.com docs.trivialsec.com)
email="support@trivialsec.com"
rsa_key_size=4096
base_path="/root/nginx"

mkdir -p ${base_path}/certs
if [ ! -e "${base_path}/options-ssl-nginx.conf" ]; then
  cat > ${base_path}/options-ssl-nginx.conf <<CONFIG
ssl_session_cache shared:le_nginx_SSL:10m;
ssl_stapling on;
ssl_stapling_verify on;
ssl_session_timeout 5m;
ssl_session_tickets off;
ssl_protocols TLSv1.2 TLSv1.3;
ssl_prefer_server_ciphers on;
ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA";
CONFIG
fi
if [ ! -e "${base_path}/ssl-dhparams.pem" ]; then
  cat > ${base_path}/ssl-dhparams.pem <<CONFIG
-----BEGIN DH PARAMETERS-----
MIICCAKCAgEAzMIBPMMfoTKzg0vEnwjDj6KsbGR1zhtgEY+oydmHyazwbJXv+2pC
jAEbz2Xmzhi4+GdkNq2Wxxzll1Mwn67vJ6vbOhECgdykZB/7/ioGgftwwklJts3c
e57RsDMv70sdZoKCV0R+XHYRzHGirwnopZkBeDC5cAiCzBOeOubNbTkJfjglv0QZ
6laWDmPLqphz6ZUR5r7oHqdr/D8KMEq0KN/GQTdvpW7tGko6fTyKETmoV3Dc1bXU
Kj5XxPlIF98UJ0zTV6CCYWeM8DQgLSfrtxAPHFPVjcFb4LSyUpmhAsGo7p0kIEby
MHez1YWxHo+Y7n2JkeA5v3SKJSI9k9Sp0oaIYwHnRX5Pze5I+zHAWlDfPcxpCWfj
maDB1txrA6Q8g6VV8bYKt4LEBMSW4LtFFRoQEC6un1gj8DDGieLaJ1H2+q+4NCeg
p+W2ELuH5RXBgBA+F8EHgyqyp70olEYpi+kdO3CFGFOMVCTHA7TUNNePT3MDjyBH
Ei2W2sUiEX9jKkCZib56UQhDoQFbIuqegCMzaj9LrIVleJcftvGNtRBlGVz6JR1f
uSWOxsjNRxvEe2J94H3o1ilNvHjhd1uj9tw5Y3zBss2j6NG/UMpVWdTHEkO5/owk
tylRRVJiJKNyTRMa1+oAGDxQi2Zw2SDM92vAg5oQfnnPfKuwB44BbTMCAQI=
-----END DH PARAMETERS-----
CONFIG
fi

for domain in "${trivialsec_domains[@]}"; do
  mkdir -p ${base_path}/certs/${domain}
  echo "Generating rsa:${rsa_key_size} x509 certificate for ${domain}"
  openssl genrsa -out ${base_path}/certs/${domain}/privkey.pem ${rsa_key_size}
  echo "Create the signing (csr)"
  openssl req -new -sha512 \
      -key ${base_path}/certs/${domain}/privkey.pem \
      -subj "/C=AU/O=Trivial Security Pty Ltd/OU=Trivial Security/CN=${domain}" \
      -out ${base_path}/certs/${domain}.csr
  openssl req -in ${base_path}/certs/${domain}.csr -noout -text
  certbot certonly --agree-tos --noninteractive \
      -d ${domain} \
      --dns-route53 \
      --no-eff-email \
      --email ${email} \
      --csr ${base_path}/certs/${domain}.csr \
      --fullchain-path ${base_path}/certs/${domain}/fullchain.pem \
      --chain-path ${base_path}/certs/${domain}/chain.pem \
      --cert-path ${base_path}/certs/${domain}/leaf.pem \
      --key-path ${base_path}/certs/${domain}/privkey.pem \
      --rsa-key-size ${rsa_key_size}

done

for domain in "${personal_domains[@]}"; do
  mkdir -p ${base_path}/certs/${domain}
  echo "Generating rsa:${rsa_key_size} x509 certificate for ${domain}"
  openssl genrsa -out ${base_path}/certs/${domain}/privkey.pem ${rsa_key_size}
  echo "Create the signing (csr)"
  openssl req -new -sha512 \
      -key ${base_path}/certs/${domain}/privkey.pem \
      -subj "/C=AU/CN=${domain}" \
      -out ${base_path}/certs/${domain}.csr
  openssl req -in ${base_path}/certs/${domain}.csr -noout -text
  AWS_CONFIG_FILE=/root/.aws/personal_credentials certbot certonly --agree-tos --noninteractive \
      -d ${domain} \
      --dns-route53 \
      --no-eff-email \
      --email ${personal_email} \
      --csr ${base_path}/certs/${domain}.csr \
      --fullchain-path ${base_path}/certs/${domain}/fullchain.pem \
      --chain-path ${base_path}/certs/${domain}/chain.pem \
      --cert-path ${base_path}/certs/${domain}/leaf.pem \
      --key-path ${base_path}/certs/${domain}/privkey.pem \
      --rsa-key-size ${rsa_key_size}

done

echo "### Starting nginx ..."
docker-compose stop nginx
docker-compose up -d nginx
echo
