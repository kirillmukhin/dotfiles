#!/bin/bash


backup_dir="$PWD/backup"
cfg_dir_vim="$HOME/"
cfg_vim="$cfg_nvim_dir/.vimrc"
src_vim="$PWD/vimrc"
cfg_dir_nvim="$HOME/.config/nvim/"
cfg_nvim="$cfg_nvim_dir/init.vim"
src_nvim="$PWD/vimrc"
cfg_dir_p10k="$HOME"
cfg_p10k="$cfg_p10k_dir/.p10k.zsh"
src_p10k="$PWD/p10k.zsh"
cfg_dir_zshrc="$HOME"
cfg_zshrc="$cfg_zshrc_dir/.zshrc"
src_zshrc="$PWD/zshrc"

cfg_dir=""
cfg=""
src=""

check_command()
{
	local command="$1"


	echo ""
	echo "-- -- -- -- -- -- -- -- -- -- -- --"
	echo "--  Cheking $command installation(s)"
	echo "-- -- -- -- -- -- -- -- -- -- -- --"
	echo ""

	if [[ "$command" == "vim" ]]; then
		echo "[!] Checking: vim"
		cfg_dir=$cfg_dir_vim
		cfg=$cfg_vim
		src=$src_vim
		echo "cfg: $cfg"
		echo "if [[ -f '$cfg' ]]"
		if [[ (-f $cfg) || (-L $cfg) ]]; then
			echo "[+] cfg exists"
			if [[ -L $cfg ]]; then
				echo "-L"
			fi
		else
			echo "[-] cfg does not exist"
		fi
	elif [[ "$command" == "nvim" ]]; then
		echo "[!] Checking: nvim"
		cfg_dir=$cfg_dir_nvim
		cfg=$cfg_nvim
		src=$src_nvim
	elif [[ "$command" == "p10k" ]]; then
		if [[ -x "$(command -v vim)" ]] || [[ -x "$(command -v nvim)" ]]; then
			echo "[!] Checking: p10k"
			cfg_dir=$cfg_dir_p10k
			cfg=$cfg_p10k
			src=$src_p10k
			return 0
		else
			echo "[✖] [ERROR] Won't install ($command), since neither (vim) nor (nvim) were found!"
			return 1
		fi
	elif [[ "$command" == "zsh" ]]; then
		echo "[!] Checking: zsh"
		cfg_dir=$cfg_dir_zshrc
		cfg=$cfg_zshrc
		src=$src_zshrc
	else
		echo "[✖] [ERROR] Unrecognised command: $command"
		return 1
	fi

	if [[ -x "$(command -v $command)" ]]; then # Check if command exist and is executable
		echo "[✔] Command ($command) was found and is executable."
	else
		echo "[✖] Command ($command) was NOT found. Skipping..."
		return 1
	fi

	return 0
}

check_source()
{
	local src="$1"

	echo ""
	echo "-- -- -- -- -- -- -- --"
	echo "--  Cheking sources  --"
	echo "-- -- -- -- -- -- -- --"
	echo ""
	if [[ ! -f $src ]]; then
		echo "[✖] [ERROR]: [$src] - does not exist!"
		echo "[!] (Run this script from the folder with the source file)"
		return 1
	else
		echo "[✔] Source file ($src) was found."
	fi

	return 0
}


create_backup()
{
	local src="$1"
	local cfg="$2"
	local backup_name='backup_'$(basename $1)

	echo ""
	echo "-- -- -- -- -- -- -- --"
	echo "--  Creating backup  --"
	echo "-- -- -- -- -- -- -- --"
	echo ""
	echo "[!] Backing up ($cfg)"
	if [[ ! -d $backup_dir ]]; then
		echo "[!] Folder ($backup_dir) not found, creating now..."
		mkdir $backup_dir
	elif [[ -f $backup_dir/$backup_name ]]; then
		echo "[!] Backup file [$backup_name] already exists."
		backup_suffix=1
		while [[ -f $backup_dir/$backup_name'_'$backup_suffix ]]; do
			((backup_suffix++))
		done
		backup_name=$backup_name'_'$backup_suffix # add a suffix with number that hasn't been taken yet by another file
		echo "[!] Saving new backup as [$backup_name]."
	fi
	cp $cfg $backup_dir/$backup_name # Creating backup
	echo "[!] Backup file ($backup_dir/$backup_name) has been created"
}


check_existing_config()
{
	#local src="$1"
	#local cfg="$2"
	#local cdf_dir="$3"
	local backup_name=""

	echo ""
	echo "-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --"
	echo "--    Checking the existing configuration    --"
	echo "-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --"
	echo ""
	if [[ (-f $cfg) || (-L $cfg) ]]; then #check if file exists and is a regular file '-f' or a symbolic link (-L)
		echo "[✔] ($cfg) is already present"
		if cmp -s $cfg $src; then
			echo "[✔] ($cfg) contents is the same as in our source file ($src)"
			if [[ -L $cfg ]]; then
				echo "[✔] ($cfg) is a symbolik link."
				if [[ "$(readlink -f $cfg)" == "$src" ]]; then # if config file points to our source
					echo "[✔] Symlink points to our source file."
					echo "[!] No further actions required."
					return 1
				else
					echo "[✖] Symlink does NOT point to our source file!"
				fi
			else
				echo "[✖] ($home) is NOT a symbolic link!"
			fi
		else
			echo "[✖] ($cfg) contents differs from the source file ($src)!"
		fi
		create_backup "$src" "$cfg"
	else
		echo "[✖] ($cfg) is NOT present!"
		echo "[!] Proceesing to create one..."
		mkdir $cfg_dir
		touch $cfg
	fi

	return 0
}

create_symlink()
{
	#local src="$1"
	#local cfg="$2"

	echo ""
	echo "-- -- -- -- -- -- -- -- -- --"
	echo "--    Creating symlinks    --"
	echo "-- -- -- -- -- -- -- -- -- --"
	echo ""
	echo "[✔] [$src] found, ready to create symlink."
	if [[ (-f $cfg) || (-L $cfg) ]]; then
		ln -sf $src $cfg # force to override existing symlink if it's present
	else
		ln -s $src $cfg
	fi
	if [[ (-L $cfg) ]]; then # if file exists and a symlink
		echo "[✔] ($cfg) symlink was successfully created!"
	else
		echo "[✖] ($cfg) failed to create a symlink!"
	fi
}


run_installation()
{
	local command="$1"

	echo ""
	echo "======================================================================="
	echo "==  Running installation for $command"
	echo "======================================================================="
	echo ""
	check_command "$command"
	if [[ $? -eq 0 ]]; then
		check_source "$src"
		if [[ $? -eq 0 ]]; then
			check_existing_config "$src" "$cfg" "$cfg_dir"
			if [[ $? -eq 0 ]]; then
				create_symlink "$src" "$cfg"
			fi
		fi
	fi
}

run_installation "vim"
run_installation "nvim"
run_installation "p10k"
run_installation "zsh"
