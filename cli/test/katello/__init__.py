
from os.path import abspath, dirname

__path__.append(abspath(dirname(__file__)+'/../../src/katello'))

from katello.client.i18n import configure_i18n
configure_i18n()
