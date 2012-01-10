#!/bin/bash

# ./create_dummy_package.sh
# Builds empty package that only copies text file with the build and install time 
# to root folder.
#
# Takes 3 parameters:
#  - name of the package
#  - destination directory
#  - required packages
#
# Requirements before first execution:
#  - install packages: rpmdevtools, rpmlint
#  - run: rpmdev-setuptree
#

RPMBUILD_HOME=~/rpmbuild

printHelp() {
    printf "Takes 5 params:\n"
    printf " - name of the package\n"
    printf " - version\n"
    printf " - release\n"
    printf " - required packages\n"
    printf " - destination directory\n"
    printf "\nExample:\n"
    printf " ./create_dummy_package.sh walrus 0.3 8 \"elephant cheetah\" ~/ \n"
    printf "\n"
}


if [ $# -lt 5 ]; then
    printHelp
    exit
fi

NAME=$1
VERSION=$2
RELEASE=$3
REQUIRES=$4
DEST=$5
RAND=`date | md5sum | cut -c1-6`
TMPDIR="/var/tmp/dummy_package_$RAND"


# create tmp dir
mkdir $TMPDIR/
echo $TMPDIR

# create spec file from template
cp ./files/dummy.spec.tpl $TMPDIR/$NAME.spec
sed -i "s/###NAME###/$NAME/g" $TMPDIR/$NAME.spec
sed -i "s/###VERSION###/$VERSION/g" $TMPDIR/$NAME.spec
sed -i "s/###RELEASE###/$RELEASE/g" $TMPDIR/$NAME.spec

REQUIRES=`echo "$REQUIRES" | sed -e "s/\"//g" -e "s/,/ /g"`
echo $REQUIRES
for r in $REQUIRES; do
    sed -i "s/###REQUIRES###/Requires: $r\n###REQUIRES###/" $TMPDIR/$NAME.spec
done
sed -i "s/###REQUIRES###//g" $TMPDIR/$NAME.spec

# create file to package
mkdir $TMPDIR/tmp/
date +"Package build time:   %T %m-%d-%Y" > $TMPDIR/tmp/$NAME.txt

# create sources tar.gz
cd $TMPDIR/
tar -pczf $NAME.tar.gz ./tmp/$NAME.txt
cd - > /dev/null
cp $TMPDIR/$NAME.tar.gz $RPMBUILD_HOME/SOURCES/


# build the package
rpmbuild -ba $TMPDIR/$NAME.spec

# move the package to the destination folder
cp $RPMBUILD_HOME/RPMS/noarch/$NAME-$VERSION-$RELEASE.noarch.rpm $DEST

# cleanup tmp directory
#rm -rf $TMPDIR
