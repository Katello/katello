from distutils.core import setup
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

requires = (
    "kerberos",
    "M2Crypto",
    "iniparse",
    "simplejson",
    "dateutil"
)

def data_files():
    data_files = [(os.path.join('share', 'locale', lang, 'LC_MESSAGES'),
                    [os.path.join('locale', lang, 'katello-cli.po')]) 
                        for lang in os.listdir('locale') if os.path.isdir('locale/' + lang)]
    data_files.extend([
        ('etc/katello-cli', ['etc/client.conf']),
        ('etc/katello-cli', ['requirements.pip'])
    ])

    return data_files

setup(
    name        = "katello-cli",
    version     = "1.4.1",
    description = "Command line interface for the Katello System's Management Project.",
    home_page   = "http://www.katello.org",
    license     = "GPL",
    packages    = packages,
    package_dir = { "katello" : "src/katello" },
    scripts     = ['bin/katello'],
    data_files  = data_files(),
    requires    = requires
)
