{% set cfg = opts['ms_project'] %}
{% set scfg = salt['mc_utils.json_dump'](opts['ms_project']) %}
{% set pkgssettings = salt['mc_pkgs.settings']() %}
{% if grains['os_family'] in ['Debian'] %}
{% set dist = pkgssettings.udist %}
{% endif %}
{% if grains['os'] in ['Debian'] %}
{% set dist = pkgssettings.ubuntu_lts %}
{% endif %}
install-pkgs:
  cmd.run: 
    - name: |
            apt-key add - << EOF
            -----BEGIN PGP PUBLIC KEY BLOCK-----
            Version: GnuPG v1.4.10 (GNU/Linux)
            
            mQGiBEv++B4RBACR8PCXpBRByIPMY2DxbqUP8LfVNRfgg7X2P4Z0e+zeYHujB0hJ
            P6vOW/QmeYSuDzFVH3oOJsC+kaTExf2Rl0/Bm3X4GRkw6XJME/3HR7P0rNCCvqgD
            QYOlhmP4qYEi0z6q9WslhqeYzilB/opsQTR/11zUjw5TGp1P/4rcCa0/6wCg87c/
            BOP6XR64zQBD5rBcCzNeL0cD/iFE97JFAYIRHOiYjpgq0/pZ/PoMrULpiyq6+BPo
            8YdcuRYdFYDC5Ghmmk0VDIf5knDdsSIA5+tJTHTiKpuHZ7JKx3aJ/HzuAHlG3RaV
            eLTl0HvkxWis/ORsjyvztlVtbHy0vVVRaWriVq76MicpdIqY1tcRvmm38j7X+Ois
            mcO1A/wNYgJyr0pHvj52T2iosKUHu2TFqVf9sWV0n+kFI1g/aG4oHWbevcrsnbtW
            +3t80BNbWAA5zlN6Bdv1MRrFJzogyJK5ao1/Y2uF4wvD64EEKgA91riHKnOSuKo2
            wCccja/CqLovaAN6dvNQ5OapuH+xuc+4IsPxPNCOUQ4TL0V6vbQ9Qml0bEJlZSBu
            aWdodGx5IGJ1aWxkcyAuZGVicyBzaWduaW5nIGtleSA8YnVpbGRkQGJpdGxiZWUu
            b3JnPohgBBMRAgAgAhsDBgsJCAcDAgQVAggDBBYCAwECHgECF4AFAk/B55cACgkQ
            lO6h8sflBDZMOgCfc+ayGdn90HWe8hDm+xiUcjnQgeEAn1Y0iF3Tu9a+kcPq1L83
            4Izk4INeiEYEEBECAAYFAkv++0YACgkQeYWXmuMwQFExdQCdHbhFwQJ44HUdjxPZ
            lPOt3iH9MZ8AoKm88QvS4dCuYmMt9KZ6oDKyCD5l
            =LQ+N
            -----END PGP PUBLIC KEY BLOCK-----
            EOF;
            if [ ! -e /etc/apt/sources.list.d/bitlbee.list ];then
              echo 'deb http://code.bitlbee.org/debian/devel/{{dist}}/amd64 ./'>/etc/apt/sources.list.d/bitlbee.list
            fi
  pkg.latest:
    - require:
      - cmd: install-pkgs
    - pkgs:
      - irssi
      - libglib2.0-dev
      - irssi-scripts 
      - irssi-plugin-otr
      - bitlbee
      - build-essential  
      - m4 
      - libtool 
      - pkg-config 
      - autoconf 
      - gettext 
      - bzip2 
      - groff 
      - man-db 
      - automake 
      - libsigc++-2.0-dev 
      - bitlbee-dev
      - libgcrypt11-dev
      - libcrypto++-dev

instpkgc:
  cmd.run:
    - name: wget https://launchpad.net/ubuntu/+source/pkg-config/0.28-1ubuntu1/+build/6035402/+files/pkg-config_0.28-1ubuntu1_amd64.deb && dpkg -i pkg-config_0.28-1ubuntu1_amd64.deb
    - onlyif: test "x$(pkg-config --version)" -lt "x0.6.28"
bitsteam-a:
  mc_git.latest:
    - name: "https://github.com/jgeboski/bitlbee-steam.git"
    - target: {{cfg.project_root}}/s
    - rev: v1.1.1
    - require:
      - cmd: instpkgc
      - pkg: install-pkgs
  cmd.run:
    - name: cd {{cfg.project_root}}/s && autoreconf -ifv
    - use_vt: true
    - unless: test -e {{cfg.project_root}}/s/configure
    - require:
      - mc_git: bitsteam-a
bitsteam-b:
  cmd.run:
    - name: cd {{cfg.project_root}}/s && ./configure && make && make install
    - require:
      - mc_git: bitsteam-a


{% for i in [
'/etc/default/bitlbee',
'/etc/bitlbee/bitlbee.conf',
]%}
config{{i}}:
  file.managed:
    - source: salt://makina-projects/{{cfg.name}}/files{{i}}
      service: bitlbee
    - template: jinja
    - name: {{i}}
    - mode: 755
    - user: root
    - group: root
    - watch:
      - cmd: bitsteam-b
    - watch_in:
      - service: bitlbee
    - defaults:
        cfg: |
             {{scfg}}
{% endfor%}

bitlbee:
  service.running:
    - names: [bitlbee]
    - enable: true



