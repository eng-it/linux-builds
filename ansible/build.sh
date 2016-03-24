#!/usr/bin/env bash
dest="/ad/eng/support/software/linux/opt/64/ansible-latest"
miniconda="https://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh"

if [ ! -e $(basename $miniconda) ]
then
	wget "$miniconda"
fi

if [ ! -e "$dest" ]
then
	bash $(basename $miniconda) -b -p "$dest"
fi

"$dest/bin/conda" update --all
"$dest/bin/conda" install -y pip
"$dest/bin/pip" install ansible

# Separate bin directory for ansible commands, so you can have them in your path
# without messing with your python commands.
if [ ! -e "$dset/ansible-bin" ]
then
	mkdir "$dest/ansible-bin"
fi
ln -s ../bin/ansible           "$dest/ansible-bin/"
ln -s ../bin/ansible-doc       "$dest/ansible-bin/"
ln -s ../bin/ansible-galaxy    "$dest/ansible-bin/"
ln -s ../bin/ansible-playbook  "$dest/ansible-bin/"
ln -s ../bin/ansible-pull      "$dest/ansible-bin/"
ln -s ../bin/ansible-vault     "$dest/ansible-bin/"

# Custom ansible config and environment script.  The add_ansible.sh script is
# now superseded by the ansible shell module.
cp ansible.cfg "$dest"
cp add_ansible.sh "$dest"

# TODO note that we have to manually change the shebang for each ansible
# script linked above, to use /ad/eng/opt/ instead of /ad/eng/support/...
