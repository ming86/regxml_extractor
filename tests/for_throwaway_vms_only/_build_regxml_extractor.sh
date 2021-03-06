#!/bin/bash

# NB: This script modifies your bashrc without remorse.  It is only meant for testing on a throwaway VM that has a network connection and git installed.
#
# This script is not meant to be called directly.  Call via one of the similarly-named scripts, appropriate to the distro you are testing.

if [ "x$INSTALL_DEPS" == "x" ]; then
  echo "This script is not meant to be called directly.  Use the appropriate build_on....sh script for your distro." >&2
  exit 1
fi

#One-liner c/o http://stackoverflow.com/a/246128/1207160
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

set -e
set -x

pushd "$SCRIPTDIR/../.."

#Ensure shell environment can support local builds, by augmenting ~/.bashrc for this and future shells.
function _env_variables_need_augments {
  test $(printf "$PATH\n$LIBRARY_PATH\n$LD_LIBRARY_PATH\n$C_INCLUDE_PATH\n$CPLUS_INCLUDE_PATH\n" | grep "$HOME/local" | wc -l) -ne 5;
}
if _env_variables_need_augments ; then
  cat deps/bashrc >>~/.bashrc
  source ~/.bashrc
  if _env_variables_need_augments ; then
    set +x
    echo "Error: ~/local did not appear in some of your PATHs, so this test will fail.  Modify your environment (e.g. with \`. "$SCRIPTDIR/../../deps/bashrc"\`) and re-run."
    exit 1
  fi
fi

#Install dependent packages
sudo "deps/$INSTALL_DEPS"

#Fetch and build unpackaged dependent software sources
git submodule init
git submodule update
deps/build_submodules.sh local

#Build RegXML Extractor
./bootstrap.sh
./configure --prefix=$HOME/local
make
make check
make distcheck
make install

#Run post-install tests
regxml_extractor.sh -h
hivexml deps/hivex/images/minimal
hivexml deps/hivex/images/large

#Done.
popd
set +x
echo "Done."
