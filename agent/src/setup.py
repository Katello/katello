#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU Lesser General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (LGPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of LGPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/lgpl-2.0.txt.
#
# Jeff Ortel <jortel@redhat.com>
#

from platform import python_version
from setuptools import setup, find_packages


major, minor, micro = python_version().split('.')

if major != '2' or minor not in ['4', '5', '6', '7']:
    raise Exception('unsupported version of python')

requires = [
]

setup(
    name='katello-agent',
    version='0.1',
    description='Katello Agent',
    author='Jeff Ortel',
    author_email='jortel@redhat.com',
    url='',
    license='GPLv2+',
    packages=find_packages(),
    scripts = [
    ],
    include_package_data=False,
    data_files=[],
    classifiers=[
        'License :: OSI Approved :: GNU General Puclic License (GPL)',
        'Programming Language :: Python',
        'Operating System :: POSIX',
        'Topic :: Content Management and Delivery',
        'Topic :: Software Development :: Libraries :: Python Modules',
        'Intended Audience :: Developers',
        'Development Status :: 3 - Alpha',
    ],
    install_requires=requires,
)

