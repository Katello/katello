#!/bin/sh

script_dir_link=$(dirname "$(readlink "$0")")
if [[ $script_dir_link == "." ]]; then
    script_dir=$(dirname "$0")
else
    script_dir=$script_dir_link
fi

export PYTHONPATH=$script_dir/../../cli/src

KAT=$script_dir/../../cli/bin/katello
DATA_DIR=$script_dir/test_data
KAT_USER="admin"
KAT_PASSWORD="admin"
CMD="$KAT -u $KAT_USER -p $KAT_PASSWORD"



if [ "$1" == "-l" ]; then
  printf "Available test data sets:\n"
  echo "--------------------------------------------------"
  
  cd $DATA_DIR
  for f in *; do
    printf " - %s:\n" ${f%.sh}
    
    cnt=`. ./$f -i | wc -l`
    i=1
    while [ $i -le $cnt ]; do
      printf "    "
      . ./$f -i | head -n $i | tail -n 1
      let i++
    done
    printf "\n"
  done
  cd - > /dev/null
  
  echo "--------------------------------------------------"
  printf "usage: kat-fill <list_of_datasets>\n"
  exit
fi


for i in $*; do
    printf "Filling Katello with test data set [ $i ] ...\n"
    . $DATA_DIR/$i.sh 
done