Basic reminder howto build/update these vagrant boxes:

 - install packer (www.packer.io)
 - edit template(s) or files in scripts/ folder
 - $ packer build debian-<distname>-<arch>-c2corg.json
 - try spinning up a vagrant instance using the new box + provisoning with
   puppet:
   - $ vagrant box add --name  debian-<distname>-<arch>-c2corg packer_virtualbox-iso_virtualbox.box
   - $ cd ..
   - $ vagrant up --provision
 - update MD5SUMS
 - upload box(es) + MD5SUMS to pkg server


 And how to generate a complete dev environment:
 - add more memory in Vagrantfile
 - $ vagrant up --provision # with c2corg::dev::env::symfony class
 - restore database:
   - rsync datadir from replica
   - $ vagrant provision
   - copy postgresql.conf & recovery.conf from replica
   - $ sysctl kernel.shmall=2097152; sysctl kernel.shmmax=4131987456
   - start & stop postgresql
   - reset replica settings & restart postgresql
 - $ vagrant provision
 - apply anonymize.sql
 - $ rm -fr /srv/www/camptocamp.org
 - $ dd if=/dev/zero of=EMPTY bs=1M; rm -f EMPTY
 - $ vagrant halt
 - $ vagrant package
 - test:
   - vagrant box add --name c2corg-dev-environment package.box
   - git clone https://github.com/c2corg/vagrant-dev-environment.git
   - vagrant up, etc
 - update MD5SUMS
 - upload box(es) + MD5SUMS to pkg server
