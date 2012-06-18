SRC_DIR     = src/katello

po/POTFILES.in:
	# generate the POTFILES.in file expected by intltool. it wants one
	# file per line, but we're lazy.
	find ${SRC_DIR}/ -name "*.py" > po/POTFILES.in

.PHONY: po/POTFILES.in

gettext: po/POTFILES.in
	# Extract strings from our source files. any comments on the line above
	# the string marked for translation beginning with "translators" will be
	# included in the pot file.
	cd po && \
	intltool-update --pot -g keys

update-po:
	for f in $(shell find po/ -name "*.po") ; do \
		msgmerge -N --backup=none -U $$f po/keys.pot ; \
	done

uniq-po:
	for f in $(shell find po/ -name "*.po") ; do \
		msguniq $$f -o $$f ; \
	done

cover:
	nosetests --with-coverage --cover-package=katello --cover-html --cover-inclusive .

test:
	cd test && nosetests
