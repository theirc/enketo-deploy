{% set user = "enketo" %}
{% set home = "/home/enketo" %}
{% set repo_dir = home + "/enketo-express" %}
{% set enketo_version = pillar['enketo']['express_version'] %}
{% set domain = pillar['domain'] %}

# The enketo install instructions suggest this; should we?
#    Let Ubuntu automatically install security updates (select "Yes" when asked):
#    sudo dpkg-reconfigure -plow unattended-upgrades

# Adds the nodesource apt repo and does an apt update, if we haven't
# done that already.
add_node_repo:
  cmd.run:
    - name: curl -sL https://deb.nodesource.com/setup_0.10 | bash -
    - creates: /etc/apt/sources.list.d/nodesource.list

# Now we can install nodejs (and other dependencies)
enketo_prereq_packages:
  pkg.latest:
    - pkgs:
      - git
      - nginx
      - htop
      - build-essential
      - checkinstall
      - nodejs
    - require:
      - cmd: add_node_repo

# And install some npm/node packages
node_packages:
  cmd.run:
    - name: npm install -g grunt-cli bower node-gyp
    - require:
      - pkg: enketo_prereq_packages

enketo_user:
  user.present:
    - name: {{ user }}
    - home: {{ home }}
    - shell: /bin/bash

enketo_code:
  gitrepo.pin:
    - repo: https://github.com/enketo/enketo-express.git
    - dir: {{ repo_dir }}
    - user: {{ user }}
    - rev: {{ enketo_version }}
    - submodules: true
    - require:
      - user: enketo_user

# Bower install for enketo
enketo_bower:
  cmd.run:
    - name: bower install
    - cwd: {{ repo_dir }}
    - user: {{ user }}
    - require:
      - gitrepo: enketo_code

# Clean npm cache (why?  install instructions say to do that here)
npm_cache_clear:
  cmd.run:
    - name: npm cache clean
    - cwd: {{ repo_dir }}
    - require:
      - cmd: enketo_bower

# More node installs
enketo_npm:
  cmd.run:
    - name: npm install
    - cwd: {{ repo_dir }}
    - user: {{ user }}
    - require:
      - cmd: npm_cache_clear

# Enketo configuration
# https://github.com/enketo/enketo-express/blob/master/config/README.md
enketo_config:
  file.managed:
    - name: {{ repo_dir }}/config/config.json
    - source: salt://enketo/config.json.j2
    - user: {{ user }}
    - template: jinja
    - require:
      - gitrepo: enketo_code

# Build
enketo_build:
  cmd.run:
    - name: grunt
    - user: {{ user }}
    - cwd: {{ repo_dir }}
    - require:
      - file: enketo_config
      - cmd: enketo_npm
    - watch:
      - file: enketo_config

# Have upstart keep us running
upstart_conf:
  file.managed:
    - name: /etc/init/enketo.conf
    - source: salt://enketo/enketo.upstart.conf.j2
    - template: jinja
    - user: root
    - mode: 0644
    - context:
        user: {{ user }}
        repo_dir: {{ repo_dir }}

enketo_service:
  service.running:
    - name: enketo
    - reload: True
    - require:
      - file: upstart_conf
      - file: enketo_config
    - watch:
      - file: upstart_conf
      - file: enketo_config

# Add nginx proxy in front
nginx_ssl_dir:
  file.directory:
    - name: /etc/nginx/ssl
    - user: root
    - mode: 700

enketo_certificate:
  cmd.run:
    - name: /var/lib/nginx/generate-cert.sh {{ domain }}
    - cwd: /etc/nginx/ssl
    - creates: /etc/nginx/ssl/{{ domain }}.key
    - user: root

# This will take some time, probably... many minutes.
dhe_param:
  cmd.run:
    - name: openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
    - cwd: /etc/nginx/ssl
    - creates: /etc/nginx/ssl/dhparam.pem
    - user: root

enketo_nginx:
  file.managed:
   - name: /etc/nginx/sites-enabled/enketo
   - source: salt://enketo/enketo_nginx.conf.j2
   - template: jinja
   - context:
       domain: {{ domain }}
       cert_file: /etc/nginx/ssl/{{ domain }}.crt
       key_file: /etc/nginx/ssl/{{ domain }}.key
       dhe_param_file: /etc/nginx/ssl/dhparam.pem
   - require:
     - service: enketo_service
     - service: nginx
     - cmd: enketo_certificate
     - cmd: dhe_param

enketo_reload_nginx:
  cmd.run:
    - onchanges:
      - file: enketo_nginx
    - name: service nginx reload
    - user: root

# Allow incoming traffic on 443 and 80
app_allow_80:
  ufw.allow:
    - name: '80'
    - enabled: true
    - require:
      - pkg: ufw

app_allow_443:
  ufw.allow:
    - name: '443'
    - enabled: true
    - require:
      - pkg: ufw
