# openwsman-debian
This repository contains the code which builds openwsman for our Debian containers

This also builds packages for sblim-sfcc since libcimcclient0-dev is a build-time dependency for openwsman.

To execute, simply run `do_build.sh`

If you have not already, `docker pull debian:11.3-slim`

When finished, the files will be in artifacts, and the directory will be usable as a Debian repository.

To use the repo generated by this script, put this in a Debian source file

```deb [trusted=yes] https://<CI Server URL>/job/<Path to Job>/lastSuccessfulBuild/artifact/artifacts/ ./```
