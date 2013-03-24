Basic reminder howto build/update these vagrant boxes:

 - install rvm
 - $ rvm gemset use veewee
 - $ gem install veewee
 - edit stuff in definitions/ folder
 - $ vagrant basebox build 'debian-<distname>-<arch>-c2corg'
 - $ vagrant basebox validate 'debian-<distname>-<arch>-c2corg'
 - $ vagrant basebox export 'debian-<distname>-<arch>-c2corg'
 - try spinning up a vagrant instance using the new box + provisoning with
   puppet:
   - $ vagrant box add 'debian-<distname>-<arch>-c2corg' 'debian-<distname>-<arch>-c2corg.box'
   - $ cd ..
   - $ vagrant up --provision
 - update MD5SUMS
 - upload box(es) + MD5SUMS to pkg server
