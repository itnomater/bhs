# Bash Helper System

The Bash Helper System is the set of bash helper scripts that make writing bash scripts easier.
See [full documentation](https://itnomater.github.io/bhs) for more details.

# Licence

All BHS code is available under GNU General Public License v3.0.


# How to install

## Get the code

```bash
git clone https://github.com/itnomater/bhs ~/.scripts
```

## Set environment variables

```bash
export SHELL_ROOTDIR=${HOME}/.scripts       # If you install the BHS in different directory, set the proper path.
export SHELL_CONFDIR=${SHELL_ROOTDIR}/conf  # In your environment, this directory should be outside the repository.
export SHELL_LIBDIR=${SHELL_ROOTDIR}/lib
export SHELL_LANGDIR=${SHELL_ROOTDIR}/lang
export SHELL_BINDIR=${SHELL_ROOTDIR}/bin
export SHELL_BOOTSTRAP=${SHELL_LIBDIR}/core.inc.sh
```

You can put the above code in your shell config file.

# How to use

To use the BHS, you need to include the bootstrap library in your bash script:\
`. ${SHELL_BOOTSTRAP}`. And now, you can load any other libraries.

```bash
. ${SHELL_BOOTSTRAP}        # Initialize BHS.
lib conf                    # Load conf library 

...
```

# Some examples

## Configuration files
```bash
# #!/bin/bash
. ${SHELL_BOOTSTRAP}
lib conf

# cat /path/to/data.conf.ini
# [app]
# name = BHS
# version = 3.14
# 
# [database]
# host = localhost
# port = 3306
# user = foo
# pass = secret

conf_load '/path/to/data'   # Load the configuration file.
conf_get 'database:host'    # Print the configuration variable.
```

## Command line options
```bash
#!/bin/bash                 
. ${SHELL_BOOTSTRAP}
lib cmdline "$@"

opt_is 'f' && echo 'Foo'            # If the 'f' command line option is present print 'Foo'.
opt_is 'b' && echo $(opt_get 'b')   # If the 'b' command line option is present print its value.
```

## Printing text
```bash
#!/bin/bash
. ${SHELL_BOOTSTRAP}        # Initialize BHS.
lib echo3                   # Load echo3 library.

textln -m "Red Alert!" -c white -b red  # Print the message using colors.
```

## Generating random numbers, calculating probability
```bash
#!/bin/bash
. ${SHELL_BOOTSTRAP}        # Initialize BHS.
lib rand                    # Load rand library.

rand_prob 50 && echo 'ok'   # It prints 'ok' message with 50% probability.
```

See [full documentation](https://itnomater.github.io/bhs) for more examples.

