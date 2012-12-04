echo 'Updating CLI Translations'
tx pull -a -f -r katello.cli && git commit -a -m 'Translations - Download translations from Transifex for katello-cli.';
git status -s -u | perl -ne 's/^\?\? // and print' | while read i ; do if perl -000 -ne 'BEGIN { $e = 1 } /msgid ".*"\nmsgstr (".*"\n|""\n".*")/ and $e = 0; END { exit $e }' $i ; then echo $i ; fi ; done | xargs git add ; git commit -m 'Translations - New translations from Transifex for katello-cli.' . 

echo 'Updating Server Translations'
tx pull -a -f -r katello.katello && git commit -a -m 'Translations - Download translations from Transifex for katello.';
git status -s -u | perl -ne 's/^\?\? // and print' | while read i ; do if perl -000 -ne 'BEGIN { $e = 1 } /msgid ".*"\nmsgstr (".*"\n|""\n".*")/ and $e = 0; END { exit $e }' $i ; then echo $i ; fi ; done | xargs git add ; git commit -m 'Translations - New translations from Transifex for katello.' .

echo 'Refreshing CLI .po files from source'
cd cli/po && make gettext && make update-po && git commit -a -m 'Translations - Update .po and POTFILES.in files for katello-cli.';
cd ../../

echo 'Refreshing CLI .po files from source'
cd src && rake 'gettext:find' && git commit -a -m 'Translations - Update .po and .pot files for katello.';
