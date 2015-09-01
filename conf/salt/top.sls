base:
  '*':
    - base
    - sudo
    - sshd
    - sshd.github
    - locale.utf8
    - project.devs
  'environment:local':
    - match: grain
    - vagrant.user
  'roles:salt-master':
    - match: grain
    - salt.master
  'roles:enketo':
    - match: grain
    - nginx
    - nginx.cert
    - enketo
