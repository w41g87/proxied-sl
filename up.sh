#!/bin/env bash

ere_quote() {
  # this escapes regex reserved characters
  # it also escapes / for subsequent use with sed
  sed 's/[][\/\.|$(){}?+*^]/\\&/g' <<< "$*"
}

DOMAIN=$(grep "^DOMAIN" .env | awk -F '=' '{print $2}')
SUBDOMAIN=$(grep "^SUBDOMAIN" .env | awk -F '=' '{print $2}')
PG_USERNAME=$(grep "^POSTGRES_USER" .env | awk -F '=' '{print $2}')
PG_PASSWORD=$(grep "^POSTGRES_PASSWORD" .env | awk -F '=' '{print $2}')
SH_API=$(grep "^SPAMHAUS_API" .env | awk -F '=' '{print $2}')
CERT=$(grep "^CERT_DIR" .env | awk -F '=' '{print $2}')
PK=$(grep "^PRIVKEY_PATH" .env | awk -F '=' '{print $2}')
FC=$(grep "^FULLCHAIN_PATH" .env | awk -F '=' '{print $2}')
INT_NET=$(grep "^INT_NET" .env | awk -F '=' '{print $2}')
EXT_NET=$(grep "^EXT_NET" .env | awk -F '=' '{print $2}')

if [ -z "$SUBDOMAIN" ]; then
  SUBDOMAIN="app"
fi

mkdir -p ./postfix/conf.d/inbound
mkdir -p ./postfix/conf.d/outbound

echo Generating postfix config
sed -e "s|app.domain.tld|${SUBDOMAIN}.${DOMAIN}|g" -e "s|domain.tld|${DOMAIN}|g" -e "s|privkey_path|${PK}|g" -e "s|fullchain_path|${FC}|g" -e "s|spamhaus_api|${SH_API}|g" ./postfix/conf.d/main_i.cf.tpl > ./postfix/conf.d/inbound/main.cf
sed -e "s|app.domain.tld|${SUBDOMAIN}.${DOMAIN}|g" -e "s|domain.tld|${DOMAIN}|g" -e "s|privkey_path|${PK}|g" -e "s|fullchain_path|${FC}|g" ./postfix/conf.d/main_o.cf.tpl > ./postfix/conf.d/outbound/main.cf

if [ ! -f ./postfix/conf.d/inbound/virtual ]; then
  sed -e "s/domain.tld/${DOMAIN}/g" ./postfix/conf.d/virtual.tpl > ./postfix/conf.d/inbound/virtual
fi
if [ ! -f ./postfix/conf.d/outbound/virtual ]; then
  sed -e "s/domain.tld/${DOMAIN}/g" ./postfix/conf.d/virtual.tpl > ./postfix/conf.d/outbound/virtual
fi
if [ ! -f ./postfix/conf.d/inbound/virtual-regexp ]; then
  sed -e "s/domain.tld/${DOMAIN}/g" ./postfix/conf.d/virtual-regexp.tpl > ./postfix/conf.d/inbound/virtual-regexp
fi
if [ ! -f ./postfix/conf.d/outbound/virtual-regexp ]; then
  sed -e "s/domain.tld/${DOMAIN}/g" ./postfix/conf.d/virtual-regexp.tpl > ./postfix/conf.d/outbound/virtual-regexp
fi

sed -e "s/myuser/${PG_USERNAME}/g" ./postfix/conf.d/pgsql-relay-domains.cf.tpl >./postfix/conf.d/inbound/pgsql-relay-domains.cf
sed -i -e "s/mypassword/$(ere_quote ${PG_PASSWORD})/g" ./postfix/conf.d/inbound/pgsql-relay-domains.cf
sed -i -e "s/domain.tld/${DOMAIN}/g" ./postfix/conf.d/inbound/pgsql-relay-domains.cf

sed -e "s/myuser/${PG_USERNAME}/g" ./postfix/conf.d/pgsql-transport-maps.cf.tpl >./postfix/conf.d/inbound/pgsql-transport-maps.cf
sed -i -e "s/mypassword/$(ere_quote ${PG_PASSWORD})/g" ./postfix/conf.d/inbound/pgsql-transport-maps.cf
sed -i -e "s/domain.tld/${DOMAIN}/g" ./postfix/conf.d/inbound/pgsql-transport-maps.cf

sed -e "s/myuser/${PG_USERNAME}/g" ./postfix/conf.d/pgsql-relay-domains.cf.tpl >./postfix/conf.d/outbound/pgsql-relay-domains.cf
sed -i -e "s/mypassword/$(ere_quote ${PG_PASSWORD})/g" ./postfix/conf.d/outbound/pgsql-relay-domains.cf
sed -i -e "s/domain.tld/${DOMAIN}/g" ./postfix/conf.d/outbound/pgsql-relay-domains.cf

sed -e "s/myuser/${PG_USERNAME}/g" ./postfix/conf.d/pgsql-transport-maps.cf.tpl >./postfix/conf.d/outbound/pgsql-transport-maps.cf
sed -i -e "s/mypassword/$(ere_quote ${PG_PASSWORD})/g" ./postfix/conf.d/outbound/pgsql-transport-maps.cf
sed -i -e "s/domain.tld/${DOMAIN}/g" ./postfix/conf.d/outbound/pgsql-transport-maps.cf

sed -e "s/spamhaus_api/${SH_API}/g" ./postfix/conf.d/dnsbl-reply-map > ./postfix/conf.d/inbound/dnsbl-reply-map
sed -e "s/spamhaus_api/${SH_API}/g" ./postfix/conf.d/dnsbl_reply > ./postfix/conf.d/inbound/dnsbl_reply

sed -e "s/spamhaus_api/${SH_API}/g" ./postfix/conf.d/dnsbl-reply-map > ./postfix/conf.d/outbound/dnsbl-reply-map
sed -e "s/spamhaus_api/${SH_API}/g" ./postfix/conf.d/dnsbl_reply > ./postfix/conf.d/outbound/dnsbl_reply

cp ./postfix/conf.d/aliases ./postfix/conf.d/inbound/
cp ./postfix/conf.d/aliases ./postfix/conf.d/outbound/
cp ./postfix/conf.d/master_i.cf ./postfix/conf.d/inbound/master.cf
cp ./postfix/conf.d/master_o.cf ./postfix/conf.d/outbound/master.cf

sed -e "s|cert_dir|${CERT}|g" ./postfix-compose.yaml.tpl > ./postfix-compose.yaml
sed -e "s/internal_network/${INT_NET}/g" -e "s/external_network/${EXT_NET}/g" ./docker-compose.yaml.tpl > ./docker-compose.yaml

docker compose up --detach $@
