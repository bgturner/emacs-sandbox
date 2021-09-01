#!/bin/bash

usage() {
    printf "Usage: emacs-sandbox.sh [-h|[-n name]|[-i config_name]]
       h    Print this help.
       n    Name of the environment to load.
       i    Include a configuration. Available configurations are:
       	    - melpa - Include configuration for melpa.
       	    - straight - Include configuration for straight.
	    - minimal-ui - Config for a simpler UI.
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

include_straight() {
    (cat <<EOF
;; Allow Straight to manage our packages
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

EOF
     ) >> $EMACS_QA_INIT
}

include_minimalui() {
    (cat <<EOF
;; Minimal UI
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(setq inhibit-startup-screen t)

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
	    straight)
		include_straight;;
	    minimal-ui)
		include_minimalui;;
	esac
    done
fi

emacs -q -l $EMACS_QA_INIT $EMACS_QA_INIT

