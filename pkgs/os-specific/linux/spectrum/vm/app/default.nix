{ runCommand, writeScript, writeText, makeRootfs
, busybox, execline, linux_vm, jq, iproute
}:

runCommand "vm-app" rec {
  linux = linux_vm;

  login = writeScript "login" ''
    #! ${execline}/bin/execlineb -s0
    unexport !
    ${busybox}/bin/login -p -f root $@
  '';

  rootfs = makeRootfs {
    rcServices.ok-all = {
      type = writeText "ok-all-type" ''
        bundle
      '';
      contents = writeText "ok-all-contents" ''
        net
      '';
    };

    rcServices.net = {
      type = writeText "net-type" ''
        oneshot
      '';
      up = writeText "net-up" ''
        backtick -i LOCAL_IP {
          pipeline { ip -j link show eth0 }
          pipeline { jq -r ".[0].address | split(\":\") | .[3:6] | \"0x\" + .[]" }
          xargs printf "100.%d.%d.%d"
        }
        importas -iu LOCAL_IP LOCAL_IP

        backtick -i REMOTE_IP {
          jq -jn --arg localip $LOCAL_IP
            "$localip | split(\".\") | .[3] |= tonumber - 1 | join(\".\")"
        }
        importas -iu REMOTE_IP REMOTE_IP

        if { ip address add ''${LOCAL_IP}/31 dev eth0 }
        if { ip link set eth0 up }
        ip route add default via $REMOTE_IP
      '';
    };

    services.getty.run = writeScript "getty-run" ''
      #! ${execline}/bin/execlineb -P
      ${busybox}/bin/getty -i -n -l ${login} 38400 ttyS0
    '';

    path = [ iproute jq ];
  };

  inherit (rootfs) squashfs;
  vmID = 0;
} ''
  mkdir $out
  echo "$vmID" > $out/vm-id
  ln -s $linux/bzImage $out/kernel
  ln -s $squashfs $out/squashfs
''
