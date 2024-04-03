services:

  ## POSTFIX
  ## =================

  postfix-inbound:
    image: private/postfix:latest
    build:
      context: ./postfix/Dockerfiles/
      dockerfile: Dockerfile
    container_name: postfix-inbound
    env_file: .env
    environment:
      MAIL_CONFIG: /etc/postfix/conf.d/
    volumes:
      - ./postfix/conf.d/inbound/:/etc/postfix/conf.d/:rw
      - cert_dir:/etc/acme.sh/:ro
    restart: unless-stopped
    depends_on:
      - email
    networks:
      - default
      - proxy

  postfix-outbound:
    image: private/postfix:latest
    build:
      context: ./postfix/Dockerfiles/
      dockerfile: Dockerfile
    container_name: postfix-outbound
    env_file: .env
    environment:
      MAIL_CONFIG: /etc/postfix/conf.d/
    volumes:
      - ./postfix/conf.d/outbound/:/etc/postfix/conf.d:rw
      - cert_dir:/etc/acme.sh/:ro
    restart: unless-stopped
    depends_on:
      - email
