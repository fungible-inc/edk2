#!/bin/bash
#set -x

if [ -z ${WORKSPACE+x} ]; then
    echo "WORKSPACE is not set"
    exit -1
fi
DOCKERBUILDLOC=`dirname "$BASH_SOURCE"`/ws
mkdir -p $DOCKERBUILDLOC

TARBALL_FILENAME="dpc_snapshot.tar"

usage() {
    echo " ./prepare_run_cclinux.sh"
    echo "                          --prepare"
    echo "                          --cleanup"
    echo "                          --update <linux user name>"
    echo "                          --help"
    exit 0
}
prepare() {
    if [ ! -d $WORKSPACE/Integration ]; then 
	git clone git@github.com:fungible-inc/Integration.git
    fi
    cp -r $WORKSPACE/Integration/tools/dpcsh_interactive_client $DOCKERBUILDLOC
    if [ ! -d $WORKSPACE/FunControlPlane ]; then 
	git clone git@github.com:fungible-inc/FunControlPlane.git
    fi
    cp -r $WORKSPACE/FunControlPlane/networking/tools/dpcsh/ $DOCKERBUILDLOC
    #cp -r $WORKSPACE/FunControlPlane/networking/tools/nmtf/ $DOCKERBUILDLOC
    rm -rf $DOCKERBUILDLOC/dpcsh/build  $DOCKERBUILDLOC/dpcsh/dist
}

create_tar_ball() {
    cd $DOCKERBUILDLOC
    tar cvf $TARBALL_FILENAME *
}

cleanup() {
    rm -rf $DOCKERBUILDLOC
}

upload_tar_ball() {
    cd $DOCKERBUILDLOC
    prebuilt_loc="@server15:/project/users/doc/jenkins/sandbox/frr"
    scp $TARBALL_FILENAME $1${prebuilt_loc}
}


while test $# -gt 0
do
    case "$1" in	    
	--prepare)
	    prepare
	    create_tar_ball
	    exit 0
	    ;;
	--cleanup)
	    cleanup
	    exit 0
	    ;;
	--upload)
	    upload_tar_ball $2
	    exit 0
	    ;;
	--help)
	    usage
	    ;;
        *) echo "argument $1"
	   usage
           ;;	
    esac
    shift
done

usage
	
