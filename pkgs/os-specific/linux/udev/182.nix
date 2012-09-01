{ stdenv, fetchurl, gperf, pkgconfig, glib, acl
, libusb, usbutils, pciutils, libuuid, kmod }:

assert stdenv ? glibc;

stdenv.mkDerivation rec {
  name = "udev-182";

  src = fetchurl {
    url = "mirror://kernel/linux/utils/kernel/hotplug/${name}.tar.bz2";
    sha256 = "a0638858c5d3447e6b61409e488df65239343a81ccb258a89046c83841dd7890";
  };

  buildInputs = [ gperf pkgconfig glib acl libusb usbutils libuuid kmod ];

  configureFlags =
    ''
      --with-pci-ids-path=${pciutils}/share/pci.ids
      --enable-udev_acl --enable-edd
      --disable-introspection --libexecdir=$(out)/lib/udev
      --with-firmware-path=/root/test-firmware:/var/run/current-system/firmware
    '';

  # Workaround for the Linux kernel headers being too old.
  NIX_CFLAGS_COMPILE = "-DBTN_TRIGGER_HAPPY=0x2c0";

  postInstall =
    ''
    '';

  patches = stdenv.lib.optional stdenv.isArm ./pre-accept4-kernel.patch;

  meta = {
    homepage = http://www.kernel.org/pub/linux/utils/kernel/hotplug/udev.html;
    description = "Udev manages the /dev filesystem";
  };
}
