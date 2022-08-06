# openwsman-debian
This repository contains the code which builds openwsman for our Debian containers

This also builds packages for sblim-sfcc since libcimcclient0-dev is a build-time dependency for openwsman.

To execute, simply run `do_build.sh`

If you have not already, `docker pull debian:11.3-slim`

When finished, the files will be in artifacts, and the directory will be usable as a Debian repository.

NOTE: This builds python3 bindings and *only* python3 bindings; python 3.9 to be precise. This is in contrast to the original package which only builds python2 bindings.

To use the repo generated by this script, put this in a Debian source file

```deb [trusted=yes] https://build.metify.io/job/PackageBuilds/job/openswman-debian/lastSuccessfulBuild/artifact/artifacts/debs/ ./```
