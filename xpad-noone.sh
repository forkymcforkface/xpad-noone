#!/bin/bash
set -euo pipefail

PKG="xpad-noone"
VER="1.0"
SRC="/usr/src/${PKG}-${VER}"
MODLOAD_CONF="/etc/modules-load.d/${PKG}.conf"

usage() {
  echo "Usage: $0 -install | -update | -uninstall"
  echo
  echo "Examples:"
  echo "  $0 -install     # fresh install of ${PKG} ${VER}"
  echo "  $0 -update      # rebuild and reinstall from current repo"
  echo "  $0 -uninstall   # remove module and DKMS package"
  exit 1
}

install_pkg() {
  echo ">> Installing ${PKG} ${VER}"
  sudo modprobe -r "${PKG}" || true
  sudo dkms remove -m "${PKG}" -v "${VER}" --all || true
  sudo rm -rf "${SRC}"
  sudo cp -r "$(pwd)" "${SRC}"
  ( cd "${SRC}" && sudo dkms install -m "${PKG}" -v "${VER}" )
  echo "${PKG}" | sudo tee "${MODLOAD_CONF}" >/dev/null
  sudo depmod -a
  sudo modprobe "${PKG}"
  echo ">> Done. ${PKG} ${VER} installed and auto-load enabled."
}

update_pkg() {
  echo ">> Updating ${PKG} ${VER}"
  sudo modprobe -r "${PKG}" || true
  ( cd "${SRC}" 2>/dev/null && sudo dkms remove -m "${PKG}" -v "${VER}" --all ) || true
  sudo rm -rf "${SRC}"
  sudo cp -r "$(pwd)" "${SRC}"
  ( cd "${SRC}" && sudo dkms install -m "${PKG}" -v "${VER}" )
  echo "${PKG}" | sudo tee "${MODLOAD_CONF}" >/dev/null
  sudo depmod -a
  sudo modprobe "${PKG}"
  echo ">> Done. ${PKG} ${VER} updated."
}

uninstall_pkg() {
  echo ">> Uninstalling ${PKG} ${VER}"
  sudo modprobe -r "${PKG}" || true
  sudo dkms remove -m "${PKG}" -v "${VER}" --all || true
  sudo rm -rf "${SRC}"
  sudo rm -f "${MODLOAD_CONF}"
  sudo depmod -a
  echo ">> Done. ${PKG} ${VER} removed."
}

case "${1:-}" in
  -install)   install_pkg ;;
  -update)    update_pkg ;;
  -uninstall) uninstall_pkg ;;
  *)          usage ;;
esac
