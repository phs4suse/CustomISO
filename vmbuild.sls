isolinux_backup:
  file.copy:
    - name: /tmp/minicd/boot/x86_64/loader/isolinux.cfg
    - source: /tmp/minicd/boot/x86_64/loader/isolinux.template
    - force: True

host_replace:
  file.replace:
    - name: '/tmp/minicd/boot/x86_64/loader/isolinux.template'
    - pattern: 'customHost'
    - repl: {{ pillar['vmbuild']['hostname'] }}
    - require:
        - isolinux_backup

ip_replace:
  file.replace:
    - name: '/tmp/minicd/boot/x86_64/loader/isolinux.template'
    - pattern: 'customIp'
    - repl: {{ pillar['vmbuild']['ip'] }}
    - require:
        - isolinux_backup

gw_replace:
  file.replace:
    - name: '/tmp/minicd/boot/x86_64/loader/isolinux.template'
    - pattern: 'customGw'
    - repl: {{ pillar['vmbuild']['gw'] }}
    - require:
      - isolinux_backup

makeISO:
  cmd.run:
    - name: /usr/bin/mkisofs -o /data/{{ pillar['vmbuild']['hostname'] }}.iso -b boot/x86_64/loader/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table /tmp/minicd
    - require:
      - gw_replace

vm_build:
  cmd.run:
    - name: /usr/bin/virt-install --name {{ pillar['vmbuild']['hostname'] }} --os-type=Linux --os-variant=sle15sp4 --ram=2048 --vcpu=2 --disk path=/data/{{pillar['vmbuild']['hostname']}}.img,bus=virtio,size=16 --cdrom /data/{{ pillar['vmbuild']['hostname'] }}.iso --network bridge:br0
    - require:
      - makeISO
