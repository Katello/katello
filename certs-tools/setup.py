from distutils.core import setup

setup(name='katello-certs-tools',
      version='1.4.1',
      description='Python modules used for Katello SSL tooling',
      author='Tomas Lestach',
      author_email='tlestach@redhat.com',
      url='https://fedorahosted.org/katello/',
      packages=['certs'],
      scripts=['katello-ssl-tool', 'katello-sudo-ssl-tool'],
      data_files=[('share/katello/certs', ['sign.sh', 'gen-rpm.sh']),
                        ('share/man/man1', ['katello-ssl-tool.1'])]
)
