# Package management wrappers

The programs in this directory allow easing the installation of a list
of packages using specific package management facilities.

To create a new wrapper for a missing package manager, take inspiration
from the implementation wrapping `apt-get`:

```shell
#!/bin/sh
update_package_database() { $SUDO apt-get update          ; }
install_packages()        { $SUDO apt-get install -y "$@" ; }
. "$(dirname "$0")/generic.sh"
```

In brief:

- provide an `update_package_database` function to let the package
  manager update its dependencies database;
- provide an `install_packages` function, accepting the list of packages
  to be installed;
- *source* the `generic.sh` script in this directory.
