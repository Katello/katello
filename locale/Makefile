#
# Makefile for PO merging and MO generation. More info in the README.
#
# make all-mo (default) - generate MO files
# make check - check translations using translate-tool
# make tx-update - download and merge translations from Transifex
# make clean - clean everything
#
DOMAIN = $(shell ruby -rrubygems -e 'puts Gem::Specification::load(Dir.glob("../*.gemspec")[0]).name')
VERSION = $(shell ruby -rrubygems -e 'puts Gem::Specification::load(Dir.glob("../*.gemspec")[0]).version')
POTFILE = $(DOMAIN).pot
MOFILE = $(DOMAIN).mo
POFILES = $(shell find . -name '$(DOMAIN).po')
MOFILES = $(patsubst %.po,%.mo,$(POFILES))
POXFILES = $(patsubst %.po,%.pox,$(POFILES))
EDITFILES = $(patsubst %.po,%.edit.po,$(POFILES))
JSFILES = $(shell find ../app/assets/javascripts/*/locale -name '$(DOMAIN).js')

%.mo: %.po
	mkdir -p $(shell dirname $@)/LC_MESSAGES
	msgfmt -o $(shell dirname $@)/LC_MESSAGES/$(MOFILE) $<

# Generate MO files from PO files
all-mo: $(MOFILES)

# Check for malformed strings
%.pox: %.po
	msgfmt -c $<
	pofilter --nofuzzy -t variables -t blank -t urls -t emails -t long -t newlines \
		-t endwhitespace -t endpunc -t puncspacing -t options -t printf -t validchars --gnome $< > $@
	cat $@
	! grep -q msgid $@

%.edit.po: %.po.time_stamp
	touch $@

# gettext will trash the .edit.po file if the time stamp doesn't exist or is older than the po file
%.po.time_stamp: %.po
	touch --reference $< $@

# Prevent make from treating this as an intermediate file to be cleaned up
.PRECIOUS: %.po.time_stamp

check: $(POXFILES)

# Unify duplicate translations
uniq-po:
	for f in $(shell find ./ -name "*.po") ; do \
		msguniq $$f -o $$f ; \
	done

tx-pull: $(EDITFILES)
	# Initialize new languages
	cd .. && tx pull -f --all --minimum-perc 50
	# Force update all existing languages
	cd .. && tx pull -f --minimum-perc 0
	for f in $(EDITFILES) ; do \
		sed -i 's/^\("Project-Id-Version: \).*$$/\1$(DOMAIN) $(VERSION)\\n"/' $$f; \
	done

tx-update: tx-pull
	@echo
	@echo Run rake plugin:gettext[$(DOMAIN)] from the Foreman installation
	@echo then run rake plugin:po_to_json[$(DOMAIN)] from the Foreman installation
	@echo then run make -C locale mo-files to finish
	@echo

mo-files: $(MOFILES)
	git add $(POFILES) $(POTFILE) $(JSFILES) ../locale/*/LC_MESSAGES
	git commit -m "i18n - pulling from tx"
	@echo
	@echo Changes commited!
	@echo
