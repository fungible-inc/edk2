#!/bin/bash -e

who_am_i=$(id -un)
MK_OPTS="-f doc.mk arg_user=$who_am_i"
ALL_IMGS=''
PUSH=''
img_list=
doc_file_list=

usage () {
	echo "usage: $0 [-v] [-p] -a|image ..."
	echo "       $0 -c"
	echo "where, "
	echo "       -v     verbose"
	echo "       -c     clean the workspace"
	echo "       -p     clean and push after building image(s)"
	echo "       -a     build all images"
	echo "       image  one or more image name"
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
	echo $img_list
	echo $doc_file_list
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
			mkdir -p $usr
		else
			img_list="$img_list $img"
			doc_file_list="$doc_file_list Dockerfile.${img}"
		fi
	done
	echo $img_list
	echo $doc_file_list
}

# main

while getopts :vcap arg
do
	case $arg in
	p) PUSH=true
		make $MK_OPTS clean
		;;
	v) export _FUN_DOC_DEBUG=1
		set -x
		;;
	a) ALL_IMGS=true
		;;
	c) make $MK_OPTS clean
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
	[[ $cli_imgs ]] && echo "-a if given so ignoring command line images: $cli_imgs"
	get_all_imgs
else
	[[ ! $cli_imgs ]] && echo "option -a or at least one image arg is required" && usage 1
	process_cli_imgs
fi

make $MK_OPTS ACTION=prepare $img_list
make $MK_OPTS ACTION=build $img_list

if [[ $PUSH == 'true' ]]
then
	built_imgs=$(cat push_images)
	for img in $built_imgs
	do
		fun_docker.sh -a push -i $img 
	done
fi
