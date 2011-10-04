#!/bin/bash
COVERAGE_DIR=system-test-coverage
AGGREGATE_FILE=system-test-coverage.data
TEST_SCRIPT=../cli/test-system/cli-system-test
PID=$$
RAILS_ENV=production

function get_ruby_processes() {
  echo `ps -f --ppid $PID | grep ruby | grep script | awk '{print $2}'`
}

function rails_running() {
  [ `echo $(get_ruby_processes) | wc -w ` -eq 2 ]
  return $?
}

function before_exit(){
  echo Stopping ruby
  echo Computing coverage
  ruby_proc=$(get_ruby_processes)
  if [[ -n $ruby_proc ]]; then
    kill -2 $ruby_proc
  fi
  ruby_proc=$(get_ruby_processes)
  if [[ -n $ruby_proc ]]; then
    wait $ruby_proc
  fi
}

echo Executing server
cd src/
bundle exec rcov  ./script/rails --rails -x /gems/,config/boot.rb -o $COVERAGE_DIR -- s -e $RAILS_ENV >/dev/null &
./script/delayed_job run RAILS_ENV=$RAILS_ENV >/dev/null &

sleep 15
if ! rails_running; then
  echo rails is not running
  before_exit
  exit 2
fi
until $TEST_SCRIPT --ping &>/dev/null ; do
  if rails_running; then
    echo waiting for rails to start
    sleep 10
  else
    echo rails is not running
    before_exit
    exit 2
  fi
done

echo "Running tests"
$TEST_SCRIPT "all"

before_exit


