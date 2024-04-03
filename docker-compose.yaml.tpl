include:
  - simple-login-compose.yaml
  - postfix-compose.yaml

networks:
  default:
    external: true
    name: internal_network
  proxy:
    external: true
    name: external_network
