import logging
import sys
from distutils.core import setup
from os.path import dirname, realpath
from os import getenv

# add potential paths to the Signal_iQ repo, could just use an arg instead
curr_path = dirname(realpath(__file__))
sys.path.insert(0, '{}/../../'.format(curr_path))

from SignaliQ.client import Client
from SignaliQ.model.CloudProviderEvent import CloudProviderEvent
from SignaliQ.model.ProviderEventsUpdateMessage import ProviderEventsUpdateMessage
from SignaliQ.model.CloudVM import CloudVM
from SignaliQ.model.NetworkInterface import NetworkInterface

import py2exe

setup(console=['report_event.py'])