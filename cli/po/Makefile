
SRC_DIR     = ../src/katello
POFILES = $(shell ls *.po)
MOFILES = $(patsubst %.po,%.mo,$(POFILES))

.PHONY: POTFILES.in


%.mo: %.po
	msgfmt -o $@ $<

POTFILES.in:
	# Generate the POTFILES.in file expected by intltool. It wants one
	# file per line.
	find ${SRC_DIR}/ -name "*.py" | sed 's/^..\///g' > POTFILES.in


gettext: POTFILES.in
	# Extract strings from our source files. Any comments on the line above
	# the string marked for translation beginning with "translators" will be
	# included in the pot file.
	intltool-update --pot -g keys

update-po:
	for f in $(shell find ./ -name "*.po") ; do \
		msgmerge -N --backup=none -U $$f keys.pot ; \
	done

uniq-po:
	for f in $(shell find ./ -name "*.po") ; do \
		msguniq $$f -o $$f ; \
	done


all-mo: $(MOFILES)

clean:
	rm -f POTFILES.in *.mo
	rm -rf build

