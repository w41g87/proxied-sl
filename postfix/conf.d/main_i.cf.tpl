# POSTFIX config file, adapted for SimpleLogin
smtpd_banner = $myhostname ESMTP $mail_name (Debian)
biff = no

# appending .domain is the MUA's job.
append_dot_mydomain = no

# Uncomment the next line to generate "delayed mail" warnings
#delay_warning_time = 4h

readme_directory = no

# See http://www.postfix.org/COMPATIBILITY_README.html -- default to 2 on
# fresh installs.
compatibility_level = 3.6

# TLS parameters
smtpd_tls_cert_file=/etc/acme.sh/fullchain_path
smtpd_tls_key_file=/etc/acme.sh/privkey_path
smtpd_tls_session_cache_database = lmdb:${data_directory}/smtpd_scache
smtp_tls_session_cache_database = lmdb:${data_directory}/smtp_scache
smtp_tls_security_level = may
smtpd_tls_security_level = may

# See /usr/share/doc/postfix/TLS_README.gz in the postfix-doc package for
# information on enabling SSL in the smtp client.

alias_maps = lmdb:/etc/postfix/conf.d/aliases
mynetworks_style = subnet
proxy_interfaces = domain.tld

# set domain here
myhostname = app.domain.tld
mydomain = domain.tld
myorigin = domain.tld

relay_domains = pgsql:/etc/postfix/conf.d/pgsql-relay-domains.cf
transport_maps = pgsql:/etc/postfix/conf.d/pgsql-transport-maps.cf

# HELO restrictions
smtpd_delay_reject = yes
smtpd_helo_required = yes
smtpd_helo_restrictions =
    reject_non_fqdn_helo_hostname,
    reject_invalid_helo_hostname,
    permit

# Sender restrictions:
smtpd_sender_restrictions =
    reject_non_fqdn_sender,
    reject_unknown_sender_domain,
    permit

# Recipient restrictions:
smtpd_recipient_restrictions =
   reject_unauth_pipelining,
   reject_non_fqdn_recipient,
   reject_unknown_recipient_domain,
   reject_unauth_destination,
   reject_rhsbl_sender         spamhaus_api.dbl.dq.spamhaus.net=127.0.1.[2..99],
   reject_rhsbl_helo           spamhaus_api.dbl.dq.spamhaus.net=127.0.1.[2..99],
   reject_rhsbl_reverse_client spamhaus_api.dbl.dq.spamhaus.net=127.0.1.[2..99],
   reject_rhsbl_sender         spamhaus_api.zrd.dq.spamhaus.net=127.0.2.[2..24],
   reject_rhsbl_helo           spamhaus_api.zrd.dq.spamhaus.net=127.0.2.[2..24],
   reject_rhsbl_reverse_client spamhaus_api.zrd.dq.spamhaus.net=127.0.2.[2..24],
   permit

# Relay restrictions
smtpd_relay_restrictions = 
   permit_auth_destination,
   reject

# Postscreen spam protection
postscreen_dnsbl_sites = 
   spamhaus_api.zen.dq.spamhaus.net=127.0.0.[2..255]*3,
   b.barracudacentral.org=127.0.0.[2..11]*2,
   bl.spameatingmonkey.net*2,
   bl.spamcop.net,
   dnsbl.sorbs.net,
   list.dnswl.org=127.[0..255].[0..255].0*-2,
   list.dnswl.org=127.[0..255].[0..255].1*-4,
   list.dnswl.org=127.[0..255].[0..255].[2..3]*-6

postscreen_dnsbl_reply_map = texthash:/etc/postfix/conf.d/dnsbl_reply
postscreen_dnsbl_threshold = 3
postscreen_greet_action = enforce
postscreen_dnsbl_action = enforce
rbl_reply_maps = lmdb:/etc/postfix/conf.d/dnsbl-reply-map

# Proxy protocol
postscreen_upstream_proxy_protocol = haproxy
postscreen_upstream_proxy_timeout = 5s

# Log output

maillog_file=/dev/stdout

virtual_alias_domains = 
virtual_alias_maps = lmdb:/etc/postfix/conf.d/virtual, regexp:/etc/postfix/conf.d/virtual-regexp

