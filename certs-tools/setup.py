from distutils.core import setup

setup(name='katello-certs-tools',
      version='1.6',
      description='Python modules used for Katello SSL tooling',
      author='Tomas Lestach',
      author_email='tlestach@redhat.com',
      url='https://fedorahosted.org/katello/',
      packages=['certs'],
      scripts=['rhn-bootstrap', 'rhn-ssl-tool', 'rhn-sudo-ssl-tool'],
      data_files=[('share/katello/certs', ['sign.sh', 'gen-rpm.sh']),
                ('/var/www/html/pub/bootstrap/', ['certs/client_config_update.py']),
                ('share/man/man1', ['rhn-bootstrap.1', 'rhn-ssl-tool.1'])]
)
