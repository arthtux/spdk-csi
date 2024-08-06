#!/bin/bash -e

KUBE_VERSION=${KUBE_VERSION:-v1.30.0}
MINIKUBE_VERSION=${MINIKUBE_VERSION:-v1.33.1}
MINIKUBE_DRIVER=${MINIKUBE_DRIVER:-docker}

detectArch() {
	case "$(arch)" in
	"x86_64" | "amd64")
		MINIKUBE_ARCH="amd64"
		;;
	"aarch64" | "arm64")
		MINIKUBE_ARCH="arm64"
		;;
	*)
		echo "Couldn't translate 'uname -m' output to an available arch."
		echo "Try setting ARCH environment variable to your system arch:"
		echo "amd64, x86_64, aarch64"
		exit 1
		;;
	esac
}

function install_minikube() {
	if ! command -v minikube &> /dev/null; then
		if [ -z "${arch}" ]; then
			detectArch
		fi
		echo "=== installing minikube-${MINIKUBE_VERSION} ==="
		if [[ "$(uname)" == "Darwin" ]]; then
			echo "=== downloading minikube-${MINIKUBE_VERSION} for Darwin"
			curl -sLo /tmp/minikube-darwin-"${MINIKUBE_ARCH}"-"${MINIKUBE_VERSION}" https://storage.googleapis.com/minikube/releases/"${MINIKUBE_VERSION}"/minikube-darwin-"${MINIKUBE_ARCH}"
			sudo install /tmp/minikube-darwin-"${MINIKUBE_ARCH}"-"${MINIKUBE_VERSION}" /usr/local/bin/minikube
			rm -rf minikube-darwin-arm64
			echo "Minikube install successful restart your terminal or reload your environment for see the minikube command"
		elif [[ "$(uname)" == "Linux" ]]; then
			echo "=== Downloading minikube-${MINIKUBE_VERSION} for Linux"
			curl -sLo /usr/local/bin/minikube https://storage.googleapis.com/minikube/releases/"${MINIKUBE_VERSION}"/minikube-linux-"${MINIKUBE_ARCH}" && chmod +x /usr/local/bin/minikube
			echo "Minikube install successful"
		else
			echo "Unsupported operating system"
			exit 1
		fi
		echo "Minikube is installed with the version ${MINIKUBE_VERSION}"
	elif [[ "$(minikube version | awk '{print $3; exit;}')" != "${MINIKUBE_VERSION}" ]]; then
		echo "Minikube version is not ${MINIKUBE_VERSION}"
		echo "please remove minikube first"
		exit 1
	else
		echo "Minikube is all ready installed on the system"
	fi
}

check_minikube() {
	if ! command -v minikube &> /dev/null; then
		echo "minikube is not installed run befort ${0} install"
		exit 1
	fi
}

case "$1" in
	install)
		install_minikube
		;;
	start)
		echo "=== starting minikube ==="
		check_minikube
		CHANGE_MINIKUBE_NONE_USER=true minikube start -b kubeadm --kubernetes-version="${KUBE_VERSION}" --vm-driver="${MINIKUBE_DRIVER}"
		;;
	status)
		echo "=== minikube status ==="
		check_minikube
		minikube status
		;;
	stop)
		echo "=== stopping minikube ==="
		check_minikube
		minikube stop
		;;
	delete)
		echo "=== deleting minikube ==="
		check_minikube
		minikube delete
		;;
	uninstall)
		echo "=== uninstalling minikube ==="
		check_minikube
		minikube delete
		sudo rm -rf /usr/local/bin/minikube
		;;
	*)
		echo "$0 [install|start|status|stop|delete|uninstall]"
		;;
esac
