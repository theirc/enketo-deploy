environment: local

domain: enketo-vagrant.rescue.org

enketo:
  name: "Human-readable name for this service, e.g. KoBoCat or IRC Enketo"

support_email:  "email@some_domain"

# FIXME: will need two redis server instances on vagrant for Enketo
# to fully work, but our deploy setup doesn't arrange for that.
# See docs/vagrant.rst.
redis:
  main:
     host: ""
     port: "6379"
     password: "password of main redis server/database"
  cache:
     host: ""
     port: "6379"
     password: "password of cache redis server/database"

secrets:
  enketo_api_key: "API key for the kobo or Ona server to use when accessing this server"
  enketo_encryption_key: "random password-like string, never change after initial deploy"
