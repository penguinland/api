#!/bin/bash

if [ `whoami` == "root" ]; then
	echo "Please do not run this script directly as root. Use your normal development user account."
	exit 1
fi

if [ "`sudo whoami`x" != "rootx" ]; then
	echo "Cannot sudo to root. Please correct (install/configure sudo for your user) and try again."
	exit 1
fi

do_bullseye(){
	sudo bash <<-EOS
	# Basic tools
	apt-get update && apt-get install -y curl wget gpg sudo nano less git file fuse && apt-get clean

	# Backports repo
	echo "deb http://deb.debian.org/debian $(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)-backports main" > /etc/apt/sources.list.d/backports.list

	# Viam repo
	curl -s https://us-apt.pkg.dev/doc/repo-signing-key.gpg | gpg --yes --dearmor -o /usr/share/keyrings/viam-google.gpg
	echo "deb [signed-by=/usr/share/keyrings/viam-google.gpg] https://us-apt.pkg.dev/projects/static-file-server-310021 $(grep VERSION_CODENAME /etc/os-release | cut -d= -f2) main" > /etc/apt/sources.list.d/viam-google.list

	# Node repo
	curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --yes --dearmor -o /usr/share/keyrings/nodesource.gpg
	echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x $(grep VERSION_CODENAME /etc/os-release | cut -d= -f2) main" > /etc/apt/sources.list.d/nodesource.list

	# Install most things
	apt-get update && apt-get install -y build-essential nodejs libnlopt-dev libx264-dev libtensorflowlite-dev protobuf-compiler protoc-gen-grpc-web ffmpeg && apt-get clean

	# Install backports
	apt-get install -y -t $(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)-backports golang-go

	# Raspberry Pi support
	test "$(uname -m)" != "aarch64" || curl -fsSL https://archive.raspberrypi.org/debian/raspberrypi.gpg.key | gpg --yes --dearmor -o /usr/share/keyrings/raspberrypi.gpg
	test "$(uname -m)" != "aarch64" || echo "deb [signed-by=/usr/share/keyrings/raspberrypi.gpg] http://archive.raspberrypi.org/debian/ $(grep VERSION_CODENAME /etc/os-release | cut -d= -f2) main" > /etc/apt/sources.list.d/raspi.list
	test "$(uname -m)" != "aarch64" || ( apt-get update && apt-get install -y wiringpi libpigpio-dev && apt-get clean )
	EOS

	if [ $? -ne 0 ]; then
		echo "Package installation failed when running"
		exit 1
	fi

	cat > ~/.viamdevrc <<-EOS
	export GOPRIVATE=github.com/viamrobotics/*,go.viam.com/*
	EOS

	mod_profiles
}

do_linux(){
	if apt-get --version > /dev/null 2>&1; then
		# Debian/Ubuntu
		INSTALL_CMD="apt-get install --assume-yes build-essential procps curl file git"
	elif pacman --version > /dev/null 2>&1; then
		# Arch
		INSTALL_CMD="pacman -Sy --needed --noconfirm base-devel procps-ng curl git"
	elif yum --version > /dev/null 2>&1; then
		# Fedora/Redhat
		INSTALL_CMD="yum -y install procps-ng curl file git libxcrypt-compat && yum -y groupinstall 'Development Tools'"
	fi

	sudo bash -c "$INSTALL_CMD"

	if [ $? -ne 0 ]; then
		echo "Package installation failed when running:"
		echo "sudo bash -c \"$INSTALL_CMD\""
		exit 1
	fi

	cat > ~/.viamdevrc <<-EOS
	eval "\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
	export LIBRARY_PATH=/home/linuxbrew/.linuxbrew/lib
	export CGO_LDFLAGS=-L/home/linuxbrew/.linuxbrew/lib
	export CGO_CFLAGS=-I/home/linuxbrew/.linuxbrew/include
	export GOPRIVATE=github.com/viamrobotics/*,go.viam.com/*
	export CC=gcc-11
	export CXX=g++-11
	EOS

	do_brew
	mod_profiles
}


do_darwin(){
	if ! gcc --version >/dev/null 2>&1; then
		echo "Please finish the Xcode CLI tools installation then rerun this script."
		exit 1
	fi


	if [ "$(uname -m)" == "arm64" ]; then

		cat > ~/.viamdevrc <<-EOS
		eval "\$(/opt/homebrew/bin/brew shellenv)"
		export LIBRARY_PATH=/opt/homebrew/lib
		export CGO_LDFLAGS=-L/opt/homebrew/lib
		export CGO_CFLAGS=-I/opt/homebrew/include
		export GOPRIVATE=github.com/viamrobotics/*,go.viam.com/*
		EOS

	else # assuming x86_64, but untested

		cat > ~/.viamdevrc <<-EOS
		eval "\$(/usr/local/bin/brew shellenv)"
		export LIBRARY_PATH=/usr/local/lib
		export GOPRIVATE=github.com/viamrobotics/*,go.viam.com/*
		EOS

	fi

	do_brew
	mod_profiles
}

mod_profiles(){
	# Add dev environment variables to shells
	test -f ~/.bash_profile && ( grep -q viamdevrc ~/.bash_profile || echo "source ~/.viamdevrc" >> ~/.bash_profile )
	test -f ~/.bashrc && ( grep -q viamdevrc ~/.bashrc || echo "source ~/.viamdevrc" >> ~/.bashrc )
	test -f ~/.zprofile && ( grep -q viamdevrc ~/.zprofile || echo "source ~/.viamdevrc" >> ~/.zprofile )
	test -f ~/.zshrc && ( grep -q viamdevrc ~/.zshrc || echo "source ~/.viamdevrc" >> ~/.zshrc )

	# We have some private repos for now so exclude them from https in order to utilize SSH keys.
	git config --global --get-regexp url.ssh://git@github.com/viamrobotics > /dev/null
	if [ $? -ne 0 ]; then
		git config --global url.ssh://git@github.com/viamrobotics/rdk.insteadOf https://github.com/viamrobotics/rdk
		git config --global url.ssh://git@github.com/viamrobotics/api.insteadOf https://github.com/viamrobotics/api
	fi
	mkdir -p ~/.ssh
	grep -q github.com ~/.ssh/known_hosts || ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
}

do_brew(){
	# Install brew
	brew --version > /dev/null 2>&1 || bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || exit 1

	# Has to be after the install so the brew eval can run
	source ~/.viamdevrc

	brew bundle --file=- <<-EOS
	# viam tap
	tap  "viamrobotics/brews"

	# unpinned
	brew "nlopt"
	brew "x264"
	brew "protoc-gen-grpc-web"
	brew "pkg-config"
	brew "tensorflowlite"
	brew "ffmpeg"

	# pinned
	brew "gcc@11"
	brew "go@1.18"
	brew "node@18"
	brew "protobuf@3"

	EOS

	if [ $? -ne 0 ]; then
		exit 1
	fi

	brew unlink "gcc" "go" "node" "protobuf"
	brew link --overwrite "gcc@11" "go@1.18" "node@18" "protobuf@3" || exit 1

	echo "Brew installed software versions..."
	brew list --version
}

# Main install routine
if [ "$(uname)" == "Linux" ]; then
	if [ "$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)" == "bullseye" ]; then
		do_bullseye
	elif [ "$(uname -m)" == "x86_64" ]; then
		do_linux
	else
		echo -e "\033[41m""Native dev environment is only supported on Debian/Bullseye (x86_64 and aarch64), but brew-based support is avaialble for generic Linux/x86_64 and Darwin (MacOS).""\033[0m"
		exit 1
	fi
elif [ "$(uname)" == "Darwin" ]; then
	do_darwin
fi

echo -e "\033[0;32m""Dev environment setup is complete!""\033[0m"
echo -e "Don't forget to restart your shell, or execute: ""\033[41m""source ~/.viamdevrc""\033[0m"
exit 0
