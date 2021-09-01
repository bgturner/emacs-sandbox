#!/bin/bash

usage() {
    printf "Usage: emacs-sandbox.sh [-h|[-n name]]
       h    Print this help.
       n    Name of the environment to load.
" 1>&2;
    exit 1;
}

NAME="sandbox"

create_sandbox() {
    mkdir $EMACS_QA_FOLDER && touch $EMACS_QA_INIT && (cat << EOF 
;; Use our custom Emacs directory
(setq user-emacs-directory "~/.emacs.${NAME}.d/")

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

while getopts ':hn:' option; do
    case $option in
	h) # Display help
	    usage
	    exit;;
	n) # Name option
	    NAME=$OPTARG;;
	\?) # Invalid Option
	    echo "Invalid option"
	    exit;;
    esac
done

EMACS_QA_FOLDER="${HOME}/.emacs.${NAME}.d"
EMACS_QA_INIT="${EMACS_QA_FOLDER}/init.el"

if [ ! -d $EMACS_QA_FOLDER ]; then
    create_sandbox
fi

emacs -q -l $EMACS_QA_INIT $EMACS_QA_INIT

