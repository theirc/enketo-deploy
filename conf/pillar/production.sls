#!yaml|gpg

environment: production

domain: enketo.rescue.org

enketo:
  name: "IRC Enketo Production"

# Note: Redis on AWS Elasticache controls access without using the Redis
# passwords, so we don't need to set passwords here.
# http://docs.aws.amazon.com/AmazonElastiCache/latest/UserGuide/GettingStarted.AuthorizeAccess.html
redis:
  main:
     host: "enketo-prd-main.vlkx2j.0001.euc1.cache.amazonaws.com"
     port: "6379"
  cache:
     host: "enketo-prd-cache.vlkx2j.0001.euc1.cache.amazonaws.com"
     port: "6379"


# Addtional public environment variables to set for the project
env:
  FOO: BAR

secrets:
  enketo_api_key: |-
      -----BEGIN PGP MESSAGE-----
      Version: GnuPG v1
      Comment: GPGTools - http://gpgtools.org

      hQEMA5N61hssx77SAQf/TLTyaAQ75IGLue0RUT1DDZhx2Lhluic9VkKNitqOvoEm
      mM3TA+ujvH9VkES3L15bw2ZBeTklgAJwD0lsjTEBjYaoF8koSX22f+6T9AMiI4E2
      rUwrp8hBngT1Xt5nqhoczuPegCjmumRND7NCXuQDQzG6043ek1E6l+09wYxMS37N
      xbYUD2QRQxxpP3aHb0iezoveq3Hkp557KRm/XmvRKgDwLRGXpRkNtry5SHFbPtQ/
      /XaOxiXxUUZQl24kMludgyddwv9kKXZNSLkShkakdnAt2oeZyzxzCeSZzRF6h1Tv
      fDO8w0FykvuPRpL2IVbS3DuewCkcMPC9NWAwb/j7RNJLAVXGrucyE9mEAzC5+3Rg
      0nq63P4v/IXdWFd7uiFR2ojJ5c6r6qw/vulLSOpe8DvplvWrkLPF0RhwjiyQH5qw
      cP+/eVnNRkJ8PX/r
      =MLNQ
      -----END PGP MESSAGE-----

  "enketo_encryption_key": |-
      -----BEGIN PGP MESSAGE-----
      Version: GnuPG v1
      Comment: GPGTools - http://gpgtools.org

      hQEMA5N61hssx77SAQf+Mfn4WxqK0y5jPEh24K5eSePjuiz9NPHEpSOmmDM4r46U
      NaEdOtZAo5Xtb2sikjkMahQFcxYeC4qmoPLqYMc2gBKBQzrGD09fLBxIyG0tYfCS
      RG6FA++K9ACxD/nc4/Tl8q04ahGJ/GQWhab040E6AzePOWq3Ssb4ABpy7D1hTFzy
      N52SA5OcD5CDnIU2iGkIgby5EBN0vLXrm8WYixkbPEQePMutWucgg2ojAT2Od5HV
      UQpux6txR313QhfhoAyHdKjUwJ6Gu2+eaasWzEnoj2w6QHO2H+i/R89qdAOdj5hB
      K/7OElw1uzFdTgC+UIpeNXqaLxK0RxIknDKBsa8lYdJfAUSOpc9iTfCcMN/GrfrI
      T2qWjF7tvIMmaC1L1S0VNjPLQ9roF20EOv60vZTKKC35KFrCAf7hUiQrxic/Kf8f
      QcbONtpVUrbmhBk3VqjumJR77NELYEn2jvT56+NxVoA=
      =5A3A
      -----END PGP MESSAGE-----

# Uncomment and update username/password to enable HTTP basic auth
# Password must be GPG encrypted.
# http_auth:
#   username: |-
#    -----BEGIN PGP MESSAGE-----
#    -----END PGP MESSAGE-----

# Private environment variables.
# Must be GPG encrypted.
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

# Uncomment and update ssl_key and ssl_cert to enabled signed SSL/
# Must be GPG encrypted.
# {% if 'balancer' in grains['roles'] %}
# ssl_key: |-
#    -----BEGIN PGP MESSAGE-----
#    -----END PGP MESSAGE-----
#
# ssl_cert: |-
#    -----BEGIN PGP MESSAGE-----
#    -----END PGP MESSAGE-----
# {% endif %}
