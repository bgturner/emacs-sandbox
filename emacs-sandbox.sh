#!/bin/bash

usage() {
    printf "Usage: emacs-sandbox.sh [-h|[-n name]|[-i config_name]]
       h    Print this help.
       n    Name of the environment to load.
       i    Include a configuration. Available configurations are:
       	    - melpa - Include configuration for melpa.
" 1>&2;
    exit 1;
}

NAME="sandbox"

create_sandbox() {
    mkdir $EMACS_QA_FOLDER && touch $EMACS_QA_INIT && (cat << EOF 
;; Use our custom Emacs directory
(setq user-emacs-directory "~/.emacs.${NAME}.d/")

EOF
	 ) >> $EMACS_QA_INIT
}

include_melpa() {
    (cat << EOF
;; Include Melpa so we can install packages with:
;;
;;    M-x package-install
;;
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives
	     '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

EOF
	 ) >> $EMACS_QA_INIT
}

while getopts ':hn:i:' option; do
    case $option in
	h) # Display help
	    usage
	    exit;;
	n) # Name option
	    NAME=$OPTARG;;
	i) # Include configuration options
	    INC+=("$OPTARG");;
	\?) # Invalid Option
	    echo "Invalid option"
	    exit;;
    esac
done
shift $((OPTIND -1))

EMACS_QA_FOLDER="${HOME}/.emacs.${NAME}.d"
EMACS_QA_INIT="${EMACS_QA_FOLDER}/init.el"

if [ ! -d $EMACS_QA_FOLDER ]; then
    create_sandbox

    # Iterate through the configurations to include.
    for config in "${INC[@]}"; do
	case $config in
	    melpa)
		include_melpa;;
	esac
    done
fi

emacs -q -l $EMACS_QA_INIT $EMACS_QA_INIT

