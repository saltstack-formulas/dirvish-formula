{% from "dirvish/map.jinja" import dirvish %}

{% set banks = salt['pillar.get']('dirvish:banks', ['/srv/dirvish']) %}

# Helper macros to locate vaults
{%- macro find_vault(vault) -%}
{%- for bank in banks -%}
{%- set vault_dir = bank + '/' + vault -%}
{%- if salt['file.directory_exists'](vault_dir) -%}
{{ vault_dir }}
{%- endif -%}
{%- endfor -%}
{%- endmacro -%}

{%- macro get_vault_path(vault) -%}
{%- set vault_dir = find_vault(vault) -%}
{%- set default_vault_dir = banks[0] + '/' + vault -%}
{{ vault_dir|default(default_vault_dir, true) }}
{%- endmacro -%}

# The states
dirvish_package:
  pkg.installed:
    - name: {{ dirvish.package }}

dirvish_master.conf:
  file.managed:
    - name: {{ dirvish.master_config }}
    - source: salt://dirvish/files/master.conf
    - template: jinja
    - context:
        banks: {{ banks }}
    - require:
      - pkg: dirvish_package

# Loop over all vaults (and their branches) to set them up
{% for vault in salt['pillar.get']('dirvish:vaults', {}) %}
{% set vault_path = get_vault_path(vault) %}
dirvish_vault_{{ vault }}_directory:
  file.directory:
    - name: {{ vault_path }}/dirvish
    - user: root
    - group: root
    - dir_mode: 755
    - makedirs: True

{% for branch in salt['pillar.get']('dirvish:vaults:' + vault, {}) %}
{% set pillar_prefix = 'dirvish:vaults:' + vault + ':' + branch %}
dirvish_vault_{{ vault }}_branch_{{ branch }}_config:
  file.managed:
    - name: {{ vault_path }}/dirvish/{{ branch }}.conf
    - user: root
    - group: root
    - mode: 644
    - source: salt://dirvish/files/vault.conf
    - template: jinja
    - context:
        pillar_prefix: {{ pillar_prefix }}
    - require:
      - file: dirvish_vault_{{ vault }}_directory
      - file: dirvish_master.conf

dirvish_vault_{{ vault }}_branch_{{ branch }}_init:
  cmd.run:
    - name: dirvish --vault {{ vault }}:{{ branch }} --image init-{{ branch }} --init
    - user: root
    - group: root
    - creates: {{ vault_path }}/dirvish/{{ branch }}.hist
    - require:
      - file: dirvish_vault_{{ vault }}_branch_{{ branch }}_config
{% endfor %}
{% endfor %}
