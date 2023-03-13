# Get the (root) directory where Makefile is located
#   - "-P" option of cd
#      Enter the physical directory directly without following symbolic links
#  - $MAKEFILE_LIST:
#    - https://ftp.gnu.org/old-gnu/Manuals/make-3.80/html_node/make_17.html
#  - lastword:
#    - Extract the last word of names.
#    - https://www.gnu.org/software/make/manual/html_node/Quick-Reference.html
ROOT_DIR := $(shell cd -P $(dir $(lastword $(MAKEFILE_LIST))) ; pwd)

USER_HOME_DIR	:= ~
VIM_DIR			:= .vim
VIM_DIR_FOLDERS	:= 'autoload' 'backup' 'plugged' 'tmp' 'undo'
VIMRC			:= .vimrc

# - Phony Targets:
#   - "A phony target is one that is not really the name of a file"
#   - https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html
PHONY: all clean help install targets
.DEFAULT_GOAL := all

all: clean install

clean:
	@echo "################################################################################"
	@echo "Delete $(ROOT_DIR)/$(VIM_DIR) ..."
	@rm -rf $(ROOT_DIR)/$(VIM_DIR)
	@echo "Delete symlinks ..."
	@rm -rf $(USER_HOME_DIR)/$(VIM_DIR)
	@rm -rf $(USER_HOME_DIR)/$(VIMRC)

debug:
	@echo "ROOT_DIR: $(ROOT_DIR)"
	@echo "USER_HOME_DIR: $(USER_HOME_DIR)"
	@echo "VIM_DIR: $(VIM_DIR)"
	@echo "VIM_DIR_FOLDERS: $(VIM_DIR_FOLDERS)"
	@echo "VIMRC: $(VIMRC)"
	@echo "MAKEFILE_LIST: $(MAKEFILE_LIST)"
	@echo "lastword MAKEFILE_LIST: $(lastword $(MAKEFILE_LIST))"
	@echo "dir lastword MAKEFILE_LIST: $(dir $(lastword $(MAKEFILE_LIST)))"

# Gruvbox is required because it is define in .vimrc. But whereas the other
# plugins are not required at executing the "PlugInstall" command, the "gruvbox"
# plugin blocks the command execution if it isn't available. Therefore it will
# downloaded "manually" directly from github.
install:
	@echo "################################################################################"
	@echo "Prepare .vim folder structure ..."
	@mkdir -p -m 750 $(addprefix $(ROOT_DIR)/$(VIM_DIR)/,$(VIM_DIR_FOLDERS))
	@echo "Download plug.vim ..."
	@curl -sfLo $(ROOT_DIR)/$(VIM_DIR)/autoload/plug.vim \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	@if [ ! -d $(ROOT_DIR)/$(VIM_DIR)/plugged/gruvbox ]; then \
		echo "Download gruvbox ..."; \
		git clone --quiet https://github.com/morhetz/gruvbox $(ROOT_DIR)/$(VIM_DIR)/plugged/gruvbox ;\
	fi
	@echo "Install plugins and filetypes ..."
	@cp -r $(ROOT_DIR)/ftplugin $(ROOT_DIR)/$(VIM_DIR)
	@vim +'PlugInstall --sync' +'qall'
	ln -sf $(ROOT_DIR)/$(VIM_DIR) $(USER_HOME_DIR)/$(VIM_DIR)
	ln -sf $(ROOT_DIR)/$(VIMRC) $(USER_HOME_DIR)/$(VIMRC)


help targets: help-common

help-common:
	@echo "################################################################################"
	@echo "# ______________________________________________________________________________"
	@echo "# List of important targets:"
	@echo "# --------------------------"
	@echo "# > all          - Run clean and install"
	@echo "# > clean        - Remove: $(USER_HOME_DIR)/$(VIM_DIR) (with its complete vim history)"
	@echo "#                  and delete symlinks"
	@echo "# > install      - Create $(USER_HOME_DIR)/$(VIM_DIR) and its subfolders:"
	@echo "#                  $(VIM_DIR_FOLDERS)"
	@echo "#                - Create appropriate symlinks to"
	@echo "#                    $(USER_HOME_DIR)/$(VIMRC)"
	@echo "#                    $(USER_HOME_DIR)/$(VIM_DIR)"
	@echo "#                - Installs vim plugins"
	@echo "# > help         - this target list (default target)"
	@echo "# > targets      - this target list (default target)"
