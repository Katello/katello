#
# Makefile for PO merging and MO generation
#

POTFILE = katello-disconnected.pot
POFILES = $(shell find . -name '*.po')
MOFILES = $(patsubst %.po,%.mo,$(POFILES))

%.mo: %.po
	msgfmt -o $@ $<

# Generate MO files from PO files
all-mo: $(MOFILES)

# Merge PO files
update-po:
	for f in $(shell find ./ -name "*.po") ; do \
		msgmerge -N --backup=none -U $$f ${POTFILE} ; \
	done

# Unify duplicate translations
uniq-po:
	for f in $(shell find ./ -name "*.po") ; do \
		msguniq $$f -o $$f ; \
	done

# Remove all MO files
clean:
	find . -name "*.mo" -exec rm '{}' ';'
