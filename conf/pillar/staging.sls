#!yaml|gpg

environment: staging

domain: enketo-staging.rescue.org

enketo:
  name: "IRC Enketo Staging"

# Addtional public environment variables to set for the project
env:
  FOO: BAR

# Note: Redis on AWS Elasticache controls access without using the Redis
# passwords, so we don't need to set passwords here.
# http://docs.aws.amazon.com/AmazonElastiCache/latest/UserGuide/GettingStarted.AuthorizeAccess.html
redis:
  main:
     host: "enketo-staging-main.slkv7p.0001.use1.cache.amazonaws.com"
     port: "6379"
  cache:
     host: "enketo-stg-cache.slkv7p.0001.use1.cache.amazonaws.com"
     port: "6379"

secrets:
  enketo_api_key: |-
      -----BEGIN PGP MESSAGE-----
      Version: GnuPG v1
      Comment: GPGTools - http://gpgtools.org

      hQEMA44iVTbDeQVoAQgAh5kA0arSs+H7VGuiTJdqL9/TrygbKq6ZHbfsEnBPhfA6
      CGEJgZxC/EX4E1k3/Rx0bkyq3mFwtI8INTRn6bIztvlFlpGuPf5n82TFSUlZNnRv
      XDgjGz8c0heJxH1pWxcluZpwUz6Rp2K/+xQZt3Ve/Ll1z8Ym7pzMqpClSSNs5nsv
      OO9Ba82t+ndMb/qNvvJrLWLjDdMjTDfKE2mlILVeomwhvZ+gIoFiI2K8M/fTcbfO
      kSnnJK7+yD9zKU+4GYdUOmRCR2v8pqQs0vVskoRiN23b9fSxu2f//0zykXBtRRbM
      N9wqO2kODWcJzBVYr3/N2NpjaW952TioGp38tWRujdJOAUeZpdBomPCJSYQcfKzu
      hQnMbks0VJZzwiPNQ4MwMkeXIEhwcX62l94zq5kkDokr//JiOCfp0I0TPU2WD0OB
      seJGwB/u/pHsKdWaeKe+
      =MmLd
      -----END PGP MESSAGE-----
  enketo_encryption_key:  |-
      -----BEGIN PGP MESSAGE-----
      Version: GnuPG v1
      Comment: GPGTools - http://gpgtools.org

      hQEMA44iVTbDeQVoAQf+LXnbldc2FRrZ+/aoqJtvesFh49YiFSFOgfpZN476B/xU
      cUZ0Y8ID4qwyt07aLd5I3UYTpIntVo23WaEeHHchP/wXhCz6ACdVITONDZhruFgA
      kPVQqChOy/UNHtEl4m4DKWTQ/1axo76RDFZ1TAiGynSgzii/GgcuuQzYpTlnzMso
      QA8eJ48w8M5Zq5OPAYVqsZyh3V8atHuzEvnq+SAjwi6BGSlbVW20LP3thkFJ/SwO
      a7F3B/EuVkAXS7rjSk4PqyZOtasDCbwCNh7Y3dHVYXk8gqvWIGmzohxvXrn5Jw3Z
      2lXxQ0ffuZ0ncic7vtnByIBPyzXWiXm5lCf3WuVopdJTAZKer6Xl5K04PRGAEgJN
      9YBMWbWT16RK+JjZOSYHubITGW2uoDQLtW2FC+fbKt74uEJ5PIH6D7OHvpiK7t6n
      51aQodKq+++RuOuYM3hDwwHkqE4=
      =+Rxr
      -----END PGP MESSAGE-----

# Uncomment and update username/password to enable HTTP basic auth
# Password must be GPG encrypted.
# http_auth:
#   username: |-
#    -----BEGIN PGP MESSAGE-----
#    -----END PGP MESSAGE-----

# Private environment variables. Must be GPG encrypted.
# secrets:
#   "DB_PASSWORD": |-
#     -----BEGIN PGP MESSAGE-----
#     -----END PGP MESSAGE-----
#   "SECRET_KEY": |-
#     -----BEGIN PGP MESSAGE-----
#     -----END PGP MESSAGE-----

# Private deploy key. Must be GPG encrypted.
# github_deploy_key: |-
#    -----BEGIN PGP MESSAGE-----
#    -----END PGP MESSAGE-----

# Uncomment and update ssl_key and ssl_cert to enabled signed SSL
# Must be GPG encrypted.
# {% if 'balancer' in grains['roles'] %}
# ssl_key: |
# -----BEGIN PGP MESSAGE-----
# -----END PGP MESSAGE-----
#
# ssl_cert: |
# -----BEGIN PGP MESSAGE-----
# -----END PGP MESSAGE-----
# {% endif %}
