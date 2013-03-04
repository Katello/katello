from setuptools import setup
import os

packages = [
    "katello", 
    "katello.client", 
    "katello.client.api", 
    "katello.client.cli", 
    "katello.client.core", 
    "katello.client.lib", 
    "katello.client.lib.ui",
    "katello.client.lib.utils"
]

install_requires = [
    "kerberos",
    "M2Crypto",
    "iniparse",
    "simplejson",
    "python-dateutil"
]

data_files = [(os.path.join('share', 'locale', lang, 'LC_MESSAGES'),
                [os.path.join('locale', lang, lang + '.po')]) 
                    for lang in os.listdir('locale') if os.path.isdir(lang)]

data_files.extend([
    ('/etc/katello', ['etc/client.conf'])
])

setup(
    name            = "katello-cli",
    version         = "1.3",
    description     = "Command line interface for the Katello System's Management Project.",
    home_page       = "http://www.katello.org",
    license         = "GPL",
    packages        = packages,
    package_dir     = { "katello" : "src/katello" },
    scripts         = ['bin/katello'],
    data_files      = data_files,
    install_requires= install_requires
)
