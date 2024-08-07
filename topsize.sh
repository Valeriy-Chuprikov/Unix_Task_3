#!/bin/bash

N=999999999999999
minsize=1
s_small=0
format="-b"
sep=0
directory=()
error_was=0

check_dashed_directory () {
	if [[ -z $(find "./$1" -type d 2> /dev/null) ]]
	then
		echo "Каталог ./$1 не существует или у вас нет к нему доступа" >&2
	    	error_was=1
	else
		directory+=("./$1")
	fi 
}

for arg in "$@"
do
	if [[ $s_small = 1 ]]
	then
		minsize=$arg
		s_small=0
		continue
	fi

	case "$arg" in
		--)
			if [[ $sep = 0 ]]
			then
				sep=1
			else
				check_dashed_directory "$arg"
			fi
			;;
			
		--help)
			if [[ $sep = 0 ]]
			then
				echo "topsize.sh [--help] [-h] [-N] [-s minsize] [--] [dir...]"
				echo "Команда выводит список отсортированных по убыванию размеров файлов заданных каталогов в dir..., если они не заданы, то поиск ведётся в текущем каталоге"
				echo "--help - получение справки о работе программы"
				echo "-h - вывод размера в соответствующих единицах измерения: байты, килобайты и т.д."
				echo "-N - вывод информации об N файлах, где N -неотрицательное целое число"
				echo "-s minsize - вывод файлов, размер которых больше, чем minsize байт, где minsize - неотрицательное целое число"
				echo "dir... - список папок, в которых нужно искать файлы"
                		exit 0
			else
				check_dashed_directory "$arg"
			fi
			;;
			
		-h)
			if [[ $sep = 0 ]]
			then
				format+="h"
			else
				check_dashed_directory "$arg"
			fi
			;;

		-s)
			if [[ $sep = 0 ]]
			then
				s_small=1
			else
				check_dashed_directory "$arg"
			fi
			;;

		-*)
			if [[ $sep = 0 ]]
			then
				if ! [[ "${arg:1}" =~ ^[0-9]+$ ]]
	       			then
                    			echo "Опции $arg не существует" >&2
                    			error_was=1
                		else
                   			N="${arg:1}"
                		fi
			else
				check_dashed_directory "$arg"
			fi
			;;

		*)
			if [[ -z $(find "$arg" -type d 2> /dev/null) ]]
	    		then
				echo "Каталог $arg не существует или у вас нет к нему доступа" >&2
	    			error_was=1
	    		else
				directory+=("$arg")
	    		fi 
			;;

	esac
done

if [[ $error_was = 1 ]]
then
	exit 1
fi

if [[ ! directory ]]
then 
    directory=(".")
fi

find "${directory[@]}" -type f -size +"$minsize"c -exec du "$format" {} + | sort -rh | head -n "$N"



