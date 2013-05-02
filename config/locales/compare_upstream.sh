#!/bin/bash
#
# To run this you need rspec and i18n-spec gems installed
#
KATELLO_DIR=$(pwd)
UPSTEAM_CLONE=$(mktemp -d -q)
echo Cloning rails-i18n
git clone git://github.com/svenfuchs/rails-i18n.git "$UPSTEAM_CLONE"
for FILE in *yml; do
  echo -n "Comparing $FILE ... "
  if [ -f "$UPSTEAM_CLONE/rails/locale/$FILE" ]; then
    pushd "$UPSTEAM_CLONE" >/dev/null
    upstream=$(rake i18n-spec:completeness rails/locale/en.yml "rails/locale/$FILE" | grep MISSING | wc -l)
    katello=$(rake i18n-spec:completeness rails/locale/en.yml "$KATELLO_DIR/$FILE" | grep MISSING | wc -l)
    popd >/dev/null
    echo "missing strings: upstream:$upstream katello:$katello"
  else
    echo missing upstream
  fi
done
rm -rf "$UPSTEAM_CLONE"
