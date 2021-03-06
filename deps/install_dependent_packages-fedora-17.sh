#!/bin/bash

if [ ! -r /etc/fedora-release ]; then
  echo "This does not appear to be a Fedora machine." >&2
  exit 1
fi

set -e
set -x

#Below the 'automake' line are "devel" packages, but we'll break that out after the Hivex revisions are upstream.
sudo yum install \
  gcc \
  gcc-c++ \
  libxml2-devel \
  openssl-devel \
  python3 \
  python-dateutil \
  python-devel \
  automake \
  gettext-devel \
  libtool \
  ocaml
