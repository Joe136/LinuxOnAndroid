#!/system/bin/sh
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

#  TODO Install anything here

echo "  Installing root-scripts ..."
# install custom root-scripts in $mnt/root/scripts
mkdir -p "$mnt/root/scripts"
chmod 750 "$mnt/root/scripts"
cp -f "ssh.sh" "$mnt/root/scripts/ssh.sh"
cp -f "vnc.sh"* "$mnt/root/scripts/vnc.sh"

# TODO Generate for network

chmod 750 "$mnt/root/scripts/ssh.sh"
chmod 750 "$mnt/root/scripts/vnc.sh"
#chmod 750 "$mnt/root/scripts/network.sh"


for d in */.install.sh; do
  cd "$d"
  sh "$d/.install.sh"
  cd - > /dev/null
done
