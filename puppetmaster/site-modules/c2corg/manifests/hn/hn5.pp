/* PowerEdge 1850 */
class c2corg::hn::hn5 inherits c2corg::hn {
  #include hardware::raid::mega

  augeas { "enable console on serial port":
    context => "/files/etc/inittab/T0/",
    changes => [
      "set runlevels 12345",
      "set action respawn",
      "set process '/sbin/getty -L ttyS0 115200 vt100'"
    ],
    notify  => Exec["refresh init"],
  }

}
