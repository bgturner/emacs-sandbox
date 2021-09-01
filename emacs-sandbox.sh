#!/bin/bash

usage() {
    printf "Usage: emacs-sandbox.sh <sandbox-slug>" 1>&2;
    exit 1;
}

if [ $# -eq 0 ]; then
    usage 
    exit 1
fi

SLUG="$1"
EMACS_QA_FOLDER="${HOME}/.emacs.${SLUG}.d"
EMACS_QA_INIT="${EMACS_QA_FOLDER}/init.el"


create_sandbox() {
    mkdir $EMACS_QA_FOLDER && touch $EMACS_QA_INIT && (cat << EOF 
;; Use our custom Emacs directory
(setq user-emacs-directory "~/.emacs.${SLUG}.d/")

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

if [ ! -d $EMACS_QA_FOLDER ]; then
    create_sandbox
fi

emacs -q -l $EMACS_QA_INIT $EMACS_QA_INIT

