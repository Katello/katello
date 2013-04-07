#!/bin/bash


TAGS="katello-nightly-rhel6 katello-nightly-fedora18"
FEDORA_UPLOAD=1

pushd . >/dev/null
pushd `dirname $0`/.. >/dev/null

# say python to be nice to pipe
export PYTHONUNBUFFERED=1

echo 'Gathering data ...'
for tag in $TAGS; do
  rel-eng/koji-missing-builds.py $KOJI_MISSING_BUILD_BREW_ARG --no-extra $tag | \
    perl -lne '/^\s+(.+)-.+-.+$/ and print $1' \
    | xargs -I replacestring awk '{print $2}' rel-eng/packages/replacestring \
    | sed "s/$/ $tag/"
done \
    | perl -lane '$X{$F[0]} .= " $F[1]"; END { for (sort keys %X) { print "$_$X{$_}" } }' \
    | while read package_dir tags ; do
      LOCAL_FEDORA_UPLOAD=$FEDORA_UPLOAD
      pushd $package_dir >/dev/null
      srpm_name=$(basename  $(tito build --srpm |tail -n 1 | awk '{print $2}') | sed 's/\.[^.]*\.src\.rpm$//')
      srpm_test_name=$(basename  $(tito build --srpm --test |tail -n 1 | awk '{print $2}') | sed 's/\.[^.]*\.src\.rpm$//')
      first_tag=$(echo $tags |awk '{print $1}')
      package=$(rpm -q --qf '%{name}\n' --specfile *.spec 2> /dev/null | head -1)
      if koji -c ~/.koji/katello-config list-tagged $first_tag $package | grep -P "($srpm_name|$srpm_test_name)" >/dev/null; then
          LOCAL_FEDORA_UPLOAD=0 #echo Build already exist
      else
          echo Building package in path $package_dir for $tags
          ONLY_TAGS="$tags" ${TITO_PATH}tito release koji
      fi
      popd >/dev/null
    if [ "0$LOCAL_FEDORA_UPLOAD" -eq 1 ] ; then
      (
      echo Uploading tgz for path $package_dir
      cd $package_dir && LC_ALL=C ${TITO_PATH}tito build --tgz | \
      awk '/Wrote:.*tar.gz/ {print $2}' | \
      xargs -I packagepath scp packagepath fedorahosted.org:katello
      )
    fi
    done

echo 'Building packages from HEAD, which are not tagged ...'
for package in $( rel-eng/git-untagged-commits.pl  |grep HEAD | perl -pe 's/([-a-z]+)-.*/$1/' ); do
  echo "Checking package $package"
  pushd $(awk '{print $2}' < rel-eng/packages/$package) >/dev/null
  if git log --pretty=oneline --abbrev-commit . |head -n 1 |grep 'Automatic commit of package' ; then
     srpm_name=$(basename  $(tito build --srpm |tail -n 1 | awk '{print $2}') | sed 's/\.[^.]*\.src\.rpm$//')
     for tag in $TAGS; do
       koji -c ~/.koji/katello-config list-tagged $tag $package |grep $srpm_name >/dev/null \
            || ONLY_TAGS="$tag" ${TITO_PATH}tito release koji-head
     done
  else
     srpm_test_name=$(basename  $(tito build --srpm --test |tail -n 1 | awk '{print $2}') | sed 's/\.[^.]*\.src\.rpm$//')
     for tag in $TAGS; do
       koji -c ~/.koji/katello-config list-tagged $tag $package |grep $srpm_test_name >/dev/null \
            || ONLY_TAGS="$tag" ${TITO_PATH}tito release koji-head
     done
  fi
  popd >/dev/null
done

popd >/dev/null
