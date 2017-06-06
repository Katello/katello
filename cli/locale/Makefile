
SRC_DIR = ../src/katello
POFILES = $(shell find . -name '*.po')
MOFILES = $(patsubst %.po,%.mo,$(POFILES))
POXFILES = $(patsubst %.po,%.pox,$(POFILES))

.PHONY: POTFILES.in


%.mo: %.po
	msgfmt -o $@ $<

all-mo: $(MOFILES)

# Check for malformed strings
# TODO - enable endwhitespace, endpunc, puncspacing, options filters
%.pox: %.po
	msgfmt -c $<
	pofilter --nofuzzy -t variables -t blank -t urls -t emails -t long -t newlines \
		-t printf -t validchars --gnome $< > $@
	! grep -q msgid $@

check: $(POXFILES)

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

clean:
	rm -f POTFILES.in messages.mo
	find . \( -name "*.mo" -o -name "*.pox" \) -exec rm -f '{}' ';'
