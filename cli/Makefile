SRC_DIR     = src/katello
SHELL := /bin/bash
PREFIX ?=
SYSCONF ?= etc
PYTHON_DIR ?= /usr/lib/python2.7/site-packages
BASE_NAME ?= katello
INSTALL_MODULE = katello
PKGNAME = client
CODE_DIR = ${PREFIX}${PYTHON_DIR}/${INSTALL_MODULE}/${PKGNAME}
BIN_DIR = ${PREFIX}/usr/bin
MAN_DIR = ${PREFIX}/usr/share/man
VERSION = $(shell echo `grep ^Version: $(PKGNAME).spec | awk '{ print $$2 }'`)
OS = $(shell lsb_release -i | awk '{ print $$3 }' | awk -F. '{ print $$1}')
OS_VERSION = $(shell lsb_release -r | awk '{ print $$2 }' | awk -F. '{ print $$1}')


clean:
	rm -rf po/build
	rm -rf man/build

install: compile-man compile-po
	install -d ${PREFIX}/usr/share/locale/
	install -d ${BIN_DIR}
	install -d ${CODE_DIR}
	install -d ${PREFIX}/etc/${BASE_NAME}
	install -d ${CODE_DIR}/api
	install -d ${CODE_DIR}/cli
	install -d ${CODE_DIR}/core
	install -d ${CODE_DIR}/utils
	install -pm 0644 bin/${BASE_NAME} ${PREFIX}/usr/bin/${BASE_NAME}
	install -pm 0644 bin/${BASE_NAME}-debug-certificates ${BIN_DIR}/${BASE_NAME}-debug-certificates
	install -pm 0644 etc/client.conf ${PREFIX}/etc/${BASE_NAME}/client.conf
	install -pm 0644 src/${BASE_NAME}/client/*.py ${CODE_DIR}
	install -pm 0644 src/${BASE_NAME}/client/api/*.py ${CODE_DIR}/api/
	install -pm 0644 src/${BASE_NAME}/client/cli/*.py ${CODE_DIR}/cli/
	install -pm 0644 src/${BASE_NAME}/client/core/*.py ${CODE_DIR}/core/
	install -pm 0644 src/${BASE_NAME}/client/utils/*.py ${CODE_DIR}/utils/
	install -d -m 0755 ${MAN_DIR}/man1
	install -m 0644 man/build/${BASE_NAME}.1* ${MAN_DIR}/man1
	install -m 0644 man/build/${BASE_NAME}-debug-certificates.1* ${MAN_DIR}/man1

	cp -R po/build/* ${PREFIX}/usr/share/locale/

	# several scripts are executable
	chmod 755 ${CODE_DIR}/main.py

po/POTFILES.in:
	# generate the POTFILES.in file expected by intltool. it wants one
	# file per line, but we're lazy.
	find ${SRC_DIR}/ -name "*.py" > po/POTFILES.in

.PHONY: po/POTFILES.in test cover

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

# Compile translations
compile-po:
	for lang in $(basename $(notdir $(wildcard po/*.po))) ; do \
		echo $$lang ; \
		mkdir -p po/build/$$lang/LC_MESSAGES/ ; \
		msgfmt -c --statistics -o po/build/$$lang/LC_MESSAGES/katello.mo po/$$lang.po ; \
	done

compile-man:
	PYTHONPATH=src python src/katello/client/utils/usage.py >katello-usage.txt
	mkdir -p man/build
	cp man/katello.pod man/build/katello.pod
	cp man/katello-debug-certificates.pod man/build/katello-debug-certificates.pod
	sed -e '/^THE_USAGE/{r katello-usage.txt' -e 'd}' man/build/katello.pod |\
		sed -e 's/THE_VERSION/%{version}/g' |\
		/usr/bin/pod2man --name=katello -c "Katello Reference" --section=1 --release=%{version} - man/build/katello.1
	sed -e 's/THE_VERSION/%{version}/g' man/build/katello-debug-certificates.pod |\
	/usr/bin/pod2man --name=katello -c "Katello Reference" --section=1 --release=%{version} - man/build/katello-debug-certificates.1
	rm katello-usage.txt
cover:
	nosetests --with-coverage --cover-package=katello --cover-html --cover-inclusive .

test:
	cd test && nosetests
