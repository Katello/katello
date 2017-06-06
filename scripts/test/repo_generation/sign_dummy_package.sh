
#!/bin/bash
if [ $# -eq 0 ]; then
  echo "Script for generating signing dummy package"
  echo "takes list of packages to sign"
  exit
fi

KEY_NAME="Dummy Packages Generator"
KEY_FILE=RPM-GPG-KEY-dummy-packages-generator-private
GPG_BIN=`which gpg 2>/dev/null`
if [ -z $GPG_BIN ]; then
  echo "GPG is not installed - skipping."
  exit 1
fi

if [ -z $GPG_BIN ]; then
  echo "GPG is not installed - skipping."
  exit 1
fi

if ! which rpmsign &>/dev/null; then
  echo "rpm-sign is not installed - skipping."
  exit 2
fi

if ! gpg --list-keys | grep "$KEY_NAME" &>/dev/null; then
  echo "Importing gpg key for $KEY_NAME"
  $GPG_BIN --import $KEY_FILE
fi

# backup .rpmmacros
mv ~/.rpmmacros ~/.rpmmacros.dummy_bak &>/dev/null

cat <<RPMMACROS > ~/.rpmmacros
%_signature gpg
%_gpg_name $KEY_NAME
%__gpg $GPG_BIN
RPMMACROS

echo "Signing $@"

echo "On password press enter - empty password."

rpm --resign "$@"

# use origin .rpmmacros
rm ~/.rpmmacros
mv ~/.rpmmacros.dummy_bak ~/.rpmmacros &>/dev/null
