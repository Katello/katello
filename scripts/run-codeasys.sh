#!/bin/bash

# prepare dirs
mkdir -p reports/xref/{rails,cli,js} 2>/dev/null

# install missing dependencies
which roodi >/dev/null || gem install roodi
which flog >/dev/null || gem install flog
which flay >/dev/null || gem install flay
which haml >/dev/null || gem install haml

echo Checking for pylint
which pylint >/dev/null || yum -y install pylint
which spacewalk-pylint >/dev/null || yum -y install spacewalk-pylint

# run in text
PYTHONPATH=cli/src/ pylint katello --rcfile=/etc/spacewalk-pylint.rc --additional-builtins=_
echo Pylint text return code: $RESCODE
# run with HTML output
PYTHONPATH=cli/src/ pylint --rcfile=/etc/spacewalk-pylint.rc --additional-builtins=_ katello -f html >reports/pylint-cli.html
RESCODE=$?
echo Pylint html return code: $RESCODE
[ $(($RESCODE & 3)) -ne 0 ] && echo Pylint errors! && exit 1

#check ruby syntax of all .rb files
echo "Checking Ruby syntax"
find -type f -name \*.rb | xargs -t -n1 ruby -c >/dev/null
[ $? -ne 0 ] && echo Syntax errors! && exit 1

#check the syntax of all .haml files
echo "Checking HAML syntax"
#find -type f -name \*.haml | xargs -t -n1 haml -c >/dev/null
ruby scripts/test/check_haml.rb
[ $? -ne 0 ] && echo Syntax errors! && exit 1

# generate routes in HTML
#pushd src
#bundle install --path=vendor
#TEXT=1 bundle exec rake pretty_routes --trace
#bundle exec rake pretty_routes --trace
#mv routes.{html,txt} ../reports
#popd

# ruby checkstyle
echo Running roodi
roodi "src/app/**/*.rb" "src/lib/**/*.rb" > reports/roodi.txt
echo Running flog
find src/app src/lib -name \*.rb | xargs flog > reports/flog.txt
echo Running flay
find src/app src/lib -name \*.rb | xargs flay > reports/flay.txt

echo Checking for source-highlight
which source-highlight >/dev/null || yum -y install source-highlight

# require_dependency
echo Checking for require_dependency
echo "Following require statements should be require_dependency:" > reports/require_dependency.txt
find src/app src/lib -name \*.rb | xargs grep -E '^require\s' | grep -vE "'(rubygems|rest_client|net/ldap|openssl|cgi|oauth|pp|pathname|tempfile)'" >> reports/require_dependency.txt

# xrefs
echo Generating xrefs for rails
pushd reports/xref/rails
find ../../../src/app ../../../src/lib -name \*.rb | while read i; do cp "$i" "./$(echo $i | md5sum | cut -c1-6)_$(basename $i)"; done
ctags -R .
source-highlight -s ruby -f xhtml --title="Katello Rails Code" --gen-references=postdoc -n *.rb
popd

echo Generating xrefs for cli
pushd reports/xref/cli
find ../../../cli/src -name \*.py | while read i; do cp "$i" "./$(echo $i | md5sum | cut -c1-6)_$(basename $i)"; done
ctags -R .
source-highlight -s python -f xhtml --title="Katello CLI Code" --gen-references=postdoc -n *.py
popd

echo Generating xrefs for js
pushd reports/xref/js
find ../../../src/public/javascripts -name \*.js -not -name \*jquery\* | while read i; do cp "$i" "./$(echo $i | md5sum | cut -c1-6)_$(basename $i)"; done
ctags -R .
source-highlight -s javascript -f xhtml --title="Katello JS Code" --gen-references=postdoc -n *.js
popd
