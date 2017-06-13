#!/bin/bash
# transform to copy files between hetero file system (especially different file name length)
# v0.1

PROGRAM_NAME=`basename $0`
R="__RENAME_FILENAMES"
F="__RENAME_FAILED"

to_short () {
    ROOT_PWD=`pwd`
    if [ -f ${R} -o -f ${F} ]; then
        echo "${PROGRAM_NAME}: ${ROOT_PWD}: already be renamed!"
        return 2
    fi
    find . -type d | tail -r | while read -r D; do
    #find . -type d -print0 | while IFS= read -r -d '' D; do 
    	cd "${D}"
    	rm -f ${R}
    	ls -i > ${R}
    	while read -r L; do
    		S=`echo "${L}" | sed -e "s/^[ \t]+//g" | cut -f1 -d' '`
    		O=`echo "${L}" | sed -e "s/^[ \t]+//g" | cut -f2- -d' '`
    		if [ "${O}" != "${R}" ]; then
    			mv "${O}" "${S}"
    		fi
    	done < <(cat ${R})
    	cd "${ROOT_PWD}"
    done
}

to_original () {
    ROOT_PWD=`pwd`
    if [ -f ${F} ]; then
        echo "${PROGRAM_NAME}: ${ROOT_PWD}: there is rename-failed files!"
        return 3
    fi
    if [ ! -f ${R} ]; then
        echo "${PROGRAM_NAME}: ${ROOT_PWD}: no information to be renamed!"
        return 4
    fi
    find . -type d | tail -r | while read -r D; do
    	cd "${D}"
        ERR=0
    	while read -r L; do
    		S=`echo "${L}" | sed -e "s/^[ \t]+//g" | cut -f1 -d' '`
    		O=`echo "${L}" | sed -e "s/^[ \t]+//g" | cut -f2- -d' '`
    		if [ "${O}" != "${R}" ]; then
    			mv "${S}" "${O}"
                if [ "$?" != 0 ]; then
                    ERR=1
                fi
    		fi
    	done < <(cat ${R})
        if [ "${ERR}" == 0 ]; then
            rm -f ${R}
        else
            mv ${R} ${F}
        fi
    	cd "${ROOT_PWD}"
    done
}

usage () {
    echo "${PROGRAM_NAME}: [-s|--short]" "[-o|--original]"
}

while [ "$1" != "" ]; do
	case $1 in
		-s | --short )      to_short
                            ;;
        -o | --original )	to_original
                            ;;
        -h | --help )       usage
                            exit
                            ;;
        * )                 usage
                            exit 1
    esac
    shift
done

