# ssdadd

**ssdadd** is a bash script to add missing disks in the HDDTemp database. To clone the repository and run the program
    git clone https://github.com/noegodinho/ssdadd
    cd ssdadd
    sudo ./ssdadd.sh device [HDDTemp_database]
which `device` is the /dev path of the disk and, optionally, is possible to include the HDDTemp database if previously known.

It should work in any linux version, but it was only tested in a Ubuntu system.

Table of Contents
=================

* [How this works?](#how-this-works)
* [Version Changelog](#version-changelog)

# How this works?
**ssdadd** uses smartctl to obtain your disk model and to obtain the S.M.A.R.T ID which shows the disk's temperature. 
Also, checks the HDDTemp database, to verify if your disk is not in the database and, if obtains the necessary information successfully, adds the disk.

# Version Changelog
* **Version 0.1**:
    * Obtains disk information and S.M.A.R.T ID temperature
    * Verifies previous disk information on the database
    * Adds the correct information to obtain the correct temperature
