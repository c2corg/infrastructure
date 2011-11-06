/* ProLiant DL360 G4 */
class c2corg::hn::hn1 inherits c2corg::hn {

  exec { "Increase swap metadata space for huge swap": # see #722
    command => 'sed -i -r "/\/boot\/kfreebsd/ a \\\tset kFreeBSD.kern.maxswzone=187406484" /boot/grub/grub.cfg',
    unless  => "grep 'kFreeBSD.kern.maxswzone' /boot/grub/grub.cfg",
  }

}
