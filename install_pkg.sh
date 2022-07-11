#! /bin/bash

update_cmd=NULL
install_cmd=NULL

manual_packagemanager ()
{
	echo "[ATTENTION] Script failed to determine current OS and/or package manager"
	echo "Please, enter the installation command for your package manager"
	echo "(e.g. 'apt-get install','pacman -Syu' or 'pkg install')"
	read -p "Installation command:" install_cmd
}

find_pkgman()
{
	# If some packages need to be installed,
	# we need to determine package manager, used by the system
	os="$(uname -o)"
	# If OS is GNU/Linux
	if [ "$os" == "GNU/Linux" ]; then
		echo "Detected OS: GNU/Linux"
		# different distributions will have differend package managers
		# https://unix.stackexchange.com/questions/46081/identifying-the-system-package-manager
		declare -A osInfo;
		osInfo[/etc/redhat-release]=yum
		osInfo[/etc/arch-release]=pacman
		osInfo[/etc/gentoo-release]=emerge
		osInfo[/etc/SuSE-release]=zypp
		osInfo[/etc/debian_version]=apt-get
		osInfo[/etc/alpine-release]=apk
		for f in ${!osInfo[@]}
		do
			if [[ -f $f ]];then
			echo Package manager: ${osInfo[$f]}
				install_cmd=${osInfo[$f]}
			fi
		done
		# Each package manager could have different options for installing the package
		if [ "$install_cmd" == "pacman" ]; then
			if [[ -x "$(command -v pacman)" ]]; then
				# pacman command was found
				update_cmd='sudo pacman -Suy'
				install_cmd='sudo pacman -Syu'
			else
				echo "[ERROR] pacman command was not found"
				manual_packagemanager
			fi
		elif [ "$install_cmd" == "apt-get" ]; then
			if [[ -x "$(command -v apt)" ]]; then
				update_cmd='sudo apt update && apt upgrade'
				install_cmd='sudo apt install'
			elif [[ -x "$(command -v apt-get)" ]]; then
				update_cmd='sudo apt-get update && apt-get upgrade'
				install_cmd='sudo apt-get install'
			else
				echo "[ERROR] neither apt nor apt-get commands were not found"
				manual_packagemanager
			fi
		else
			echo "[ERROR] valid package manager was not detected!"
			manual_packagemanager
		fi
		echo "install_cmd: $install_cmd"
	# If OS is Android
	elif [ "$os" == "Android" ]; then
		echo "Detected OS: Android"
		if [[ -x "$(command -v pkg)" ]]; then
			update_cmd='pkg upgrade'
			install_cmd='pkg install'
		else
			echo "[ERROR] pkg command was not found"
			manual_packagemanager
		fi
	#elif osver="FreeBSD"; then
	#	echo "FreeBSD is not supported yet by this script"
	#elif [[ osver="Cygwin" || osver="MS/Windows" ]]; then
	#	echo "Windows is not supported yet by this script"
	#elif osver="Darwin"; then
	#	echo "Mac is not supported yet by this script"
	else
		# Fallback if detected OS didn't match any of predetermened choices
		manual_packagemanager
	fi
}

# Check if the app is already installed
install_check()
{
	local prog="$1"
	if [[ -x "$(command -v $prog)" ]]; then
		echo "$prog is already installed"
	else
		echo "$prog is not installed"
		echo "Installing $prog ..."
		$install_cmd $prog
	fi
}

find_pkgman
if [ "$install_cmd" != "NULL" ]; then
	install_check "nvim"
	install_check "zsh"
	install_check "man"
	install_check "curl"
	install_check "perl"
	install_check "git"
	install_check "gawk" # alternatively - `nawk`, `mawk` - is a no-no.
	install_check "openssh"
	install_check "nodejs" # for coc
	install_check "bat"
	install_check "exa"
fi


if [ "$SHELL"=~^zsh ]; then
	echo "ZSH is the active shell already"
else
	echo "ZSH is not the active shell"
	echo "Attempting to switch default shell..."
	if [[ ( -x "$(command -v chsh)" ) && ( -x "$(command -v which)" ) ]]; then
		sudo chsh --shell $(which zsh)
	else
		echo "[ERROR] Couldn't set zsh as a default shell"
		echo "Please change system's shell manually"
	fi
fi


#search="pacman -Ss"
#pack="vimivedie"
#echo "test search: $search $pack"
#if [[ $($search $pack) ]]; then
#	echo "found $pack"
#else
#	echo "not found $pack"
#fi
