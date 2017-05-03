#!/bin/bash

# Vars
SRPMURL="http://vault.centos.org/centos/7/updates/Source/SPackages/bash-4.2.46-21.el7_3.src.rpm"
CUSTOMPREFIX="_bauer" # bash-4.2.46-21.el7.centos_bauer.x86_64.rpm
SYSLOG_FACILITY="LOG_LOCAL1"
SYSLOG_LEVEL="LOG_DEBUG"
#

rm -rf /root/rpmbuild
rpm -i "${SRPMURL}"
rpmbuild -bp /root/rpmbuild/SPECS/bash.spec
cp -ra /root/rpmbuild/BUILD/bash-4.2 /root/rpmbuild/BUILD/bash-4.2-original

# Configure syslog settings
sed -ri 's/\/\* #define SYSLOG_HISTORY \*\//#define SYSLOG_HISTORY/' /root/rpmbuild/BUILD/bash-4.2/config-top.h
sed -ri "s/define SYSLOG_FACILITY LOG_USER/define SYSLOG_FACILITY ${SYSLOG_FACILITY}/" /root/rpmbuild/BUILD/bash-4.2/config-top.h
sed -ri "s/define SYSLOG_LEVEL LOG_INFO/define SYSLOG_LEVEL ${SYSLOG_LEVEL}/" /root/rpmbuild/BUILD/bash-4.2/config-top.h

# Creating patch
cd /root/rpmbuild/BUILD
diff -Npru bash-4.2-original bash-4.2 > /root/rpmbuild/SOURCES/bash_history_syslog.patch

# Apply patch in bash.spec file
sed -ri '/^BuildRequires: texinfo bison/ i Patch999: bash_history_syslog.patch\n' /root/rpmbuild/SPECS/bash.spec
sed -ri '/^echo %\{version\} > _distribution/ i %patch999 -p1 -b .history_syslog\n' /root/rpmbuild/SPECS/bash.spec

# Adding Custom prefix
sed -ri "/^Release:/ s/\$/${CUSTOMPREFIX}/" /root/rpmbuild/SPECS/bash.spec

# Build time
rpmbuild -ba /root/rpmbuild/SPECS/bash.spec
