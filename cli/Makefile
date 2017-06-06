SRC_DIR     = src/katello

.PHONY: test cover

cover:
	nosetests --with-coverage --cover-package=katello --cover-html --cover-inclusive .

test:
	cd test && nosetests
