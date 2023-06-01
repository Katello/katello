#
# Makefile for PO merging and MO generation. More info in the README.
#
# make all-mo (default) - generate MO files
# make check - check translations using translate-tool
# make tx-update - download and merge translations from Transifex
# make clean - clean everything
#
DOMAIN = katello
VERSION = $(shell git describe --abbrev=0 --tags)
POTFILE = $(DOMAIN).pot
MOFILE = $(DOMAIN).mo
ACTIONFILE = action_names.rb
POFILES = $(shell find . -name '$(DOMAIN).po')
MOFILES = $(patsubst %.po,%.mo,$(POFILES))
POXFILES = $(patsubst %.po,%.pox,$(POFILES))
EDITFILES = $(patsubst %.po,%.edit.po,$(POFILES))

%.mo: %.po
	mkdir -p $(shell dirname $@)/LC_MESSAGES
	msgfmt -o $(shell dirname $@)/LC_MESSAGES/$(MOFILE) $<
	touch $(shell dirname $@)/LC_MESSAGES/$(MOFILE)

# Generate MO files from PO files
all-mo: $(MOFILES)

# Check for malformed strings
%.pox: %.po
	msgfmt -c $<
	pofilter --nofuzzy -t variables -t blank -t urls -t emails -t long -t newlines \
		-t endwhitespace -t endpunc -t puncspacing -t options -t printf -t validchars --gnome $< > $@
	cat $@
	! grep -q msgid $@

%.edit.po:
	touch $@

check: $(POXFILES)

# Unify duplicate translations
uniq-po:
	for f in $(shell find ./ -name "*.po") ; do \
		msguniq $$f -o $$f ; \
	done

tx-pull: $(EDITFILES)
	tx pull -f
	for f in $(EDITFILES) ; do \
		sed -i 's/^\("Project-Id-Version: \).*$$/\1$(DOMAIN) $(VERSION)\\n"/' $$f; \
	done

tx-update: tx-pull
	@echo
	@echo Run rake plugin:gettext[$(DOMAIN)] and rake plugin:po_to_json[$(DOMAIN)] from the Foreman installation, then make -C locale po-files to finish
	@echo

commit-translation-files: $(POFILES)
	git add $(POFILES) $(POTFILE) $(ACTIONFILE) ../app/assets/javascripts/katello/locale
	git commit -m "i18n - pulling from tx"
	@echo
	@echo Changes commited!
	@echo

# Workaround when rake task fails (https://github.com/ruby/rake/pull/182)
extract:
	rxgettext \
		--sort-output \
		--sort-by-msgid \
		--no-wrap \
		--no-location \
		-o ${DOMAIN}.pot \
		--package-name=${DOMAIN} \
		--package-version="${VERSION}" \
		--msgid-bugs-address=foreman-dev@googlegroups.com \
		--copyright-holder="Foreman developers" \
		--copyright-year=$(shell date +%Y) \
		$(shell find ../app -type f -name \*.rb -o -name \*.erb)
