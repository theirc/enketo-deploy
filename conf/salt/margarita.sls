git-install:
  pkg.installed:
    - name: git-core

margarita:
  gitrepo.pin:
    - repo: https://github.com/caktus/margarita.git
    - dir: /srv/margarita
    - user: root
    - rev: {{ pillar['margarita_version'] }}
    - require:
      - pkg: git-install
