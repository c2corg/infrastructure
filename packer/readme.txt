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
