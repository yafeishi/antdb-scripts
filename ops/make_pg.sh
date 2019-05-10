#!/bin/bash



version=pg$1
echo "version is ${version}"
source ${HOME}/.${version}
pg_ctl stop 
appdir=${HOME}/app/${version}
builddir=${HOME}/soft_src/build/${version}
srcdir=${HOME}/soft_src/${version}

confopts="  --with-perl --with-python --with-openssl --with-pam --with-ldap --with-libxml --with-libxslt --enable-thread-safety --enable-cassert --enable-debug --enable-depend "
cflags=CFLAGS="-O0 -ggdb3  "

function CleanDir()
{
        for d in "$@"
        do
                if [ -e $d ]
                then
                        rm -rf $d/* || exit 1
                else
                        mkdir -p $d || exit 1
                fi
        done
}

function ConfigMake()
{
        needconfig=$2

        if [ "x$needconfig" = "xyes" ]; then
                CleanDir $appdir $builddir && \
                 cd $builddir && $srcdir/configure --prefix=$appdir $confopts "$cflags"   && gmake install-world-contrib-recurse >make.out || exit 1
        else
                cd $builddir && make install-world-contrib-recurse >make.out || exit 1
        fi
}

ConfigMake $@