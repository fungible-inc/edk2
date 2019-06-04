#!/bin/bash -e

who_am_i=$(id -un)
MK_OPTS="-f doc.mk arg_user=$who_am_i"
ALL_IMGS=''
_PUSH_IMAGE=''
img_list=
doc_file_list=

usage () {
	echo "usage: $0 [-v] [-p] -u|image ..."
	echo "       $0 -c"
	echo "where, "
	echo "       -v     verbose"
	echo "       -c     clean the workspace"
	echo "       -p     clean and push after building image(s)"
	echo "       -s     show all image names"
	echo "       image  one or more image name"
	# hidden option for automation
	# echo "       -a     build all main images and user wrappers for service account jenkins"
	exit $1
}

get_all_imgs () {
	local doc_file
	local img
	doc_file_list=$(ls Dockerfile*)
	[[ ! $doc_file_list ]] && echo "No Dockerfile found" && exit 1
	for doc_file in $doc_file_list
	do
		img=${doc_file#Dockerfile.*}
		if [[ $img =~ .usr ]]
		then
			img=${img%*.usr}
			img=$who_am_i/$img
		fi
		img_list="$img_list $img"
	done
}

process_cli_imgs () {
	local img
	local usr

	for img in $cli_imgs
	do
		if [[ $img =~ / ]] 
		then
			usr=${img%/*}
			img=${img#*/}
			[[ $usr != $who_am_i ]] && echo "You can only build for yourself, not $usr" && exit 1
			img_list="$img_list $usr/$img"
			doc_file_list="$doc_file_list Dockerfile.${img}.usr"
		else
			img_list="$img_list $img"
			doc_file_list="$doc_file_list Dockerfile.${img}"
		fi
	done
	echo $img_list
	echo $doc_file_list
}

# main

while getopts :vcaspt arg
do
	case $arg in
	p) # push image to registry
		_PUSH_IMAGE=true
		make $MK_OPTS clean
		;;
	v) # verbose
		export _FUN_DOC_DEBUG=1
		set -x
		;;
	s) # show image names
		get_all_imgs
		echo "Images: $img_list"
		exit 0
		;;
	a) # all images, main + headless
		ALL_IMGS=true
		;;
	c) # clean workspace
		make $MK_OPTS clean
		exit 0
		;;
	\?) usage 0
		;;
	esac
done
shift $((OPTIND -1))

cli_imgs=$*
if [[ $ALL_IMGS ]]
then
	[[ $cli_imgs ]] && echo "-a is given so ignoring command line images: $cli_imgs"
	get_all_imgs 
	echo "Images: $img_list"
else
	[[ ! $cli_imgs ]] && echo "At least one image arg is required, see $0 -s for image names" && usage 1
	process_cli_imgs
fi

/bin/rm -f *.log */*.log pushed
mkdir -p $who_am_i
export _PUSH_IMAGE
make $MK_OPTS ACTION=prepare $img_list
make $MK_OPTS ACTION=build $img_list
