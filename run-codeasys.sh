#!/bin/bash

# prepare dirs
mkdir -p reports/xref/{rails,cli,js} 2>/dev/null

# generate routes in HTML
pushd src
TEXT=1 rake pretty_routes
rake pretty_routes
mv routes.{html,txt} ../reports
popd

# install gems
which roodi flog flay >/dev/null || gem install roodi flog flay

# ruby checkstyle
echo Running roodi
roodi "src/app/**/*.rb" "src/lib/**/*.rb" > reports/roodi.txt
echo Running flog
find src/app src/lib -name \*.rb | xargs flog > reports/flog.txt
echo Running flay
find src/app src/lib -name \*.rb | xargs flay > reports/flay.txt

echo Checking for source-highlight
which source-highlight >/dev/null || (echo "Need: yum -y install source-highlight" && exit 1)

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
