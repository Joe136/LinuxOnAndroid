#!/system/bin/sh
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

#  TODO Install anything here

echo "      Installing control-scripts ..."
# install custom root-scripts in $mnt/root/scripts
mkdir -p "$mnt/opt/android-scripts"
chmod 750 "$mnt/opt/android-scripts"
cp -f "ssh.sh" "$mnt/opt/android-scripts/ssh.sh"
cp -f "vnc.sh" "$mnt/opt/android-scripts/vnc.sh"

# TODO Generate for network

chmod 750 "$mnt/opt/android-scripts/ssh.sh"
chmod 750 "$mnt/opt/android-scripts/vnc.sh"
#chmod 750 "$mnt/opt/android-scripts/network.sh"


for d in */.install.sh; do
  cd "$d"
  sh "./.install.sh"
  cd - > /dev/null
done
