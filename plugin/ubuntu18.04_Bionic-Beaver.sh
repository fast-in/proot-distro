pretty_name="Ubuntu 18.04 LTS (Bionic Beaver)"
distro="ubuntu18.04-bionic"
distro_rootfs="$rootfs_place/$distro-rootfs"
tarball="$cache/$distro.tar.gz"

case "$(uname -m 2>/dev/null)" in
	aarch64|arm64) archurl=arm64;;
	armhf|armv7|arm) archurl=armhf;;
	i*86|x86) archurl=i386;;
	x86_64|amd64) archurl=amd64;;
	ppc64le) archurl=ppc64le;;
	powerpc) archurl=powerpc;;
	*) echo 1>&2 "Unknown architecture"; exit 1
esac

cat > "$temp/install.sh" << EOM
#!$(command -v bash) -

if ! [ -f '$tarball' -a -r '$tarball' ]; then
	echo -e "[*] Installing \e[0;93m$pretty_name\e[m..."
	curl --location --insecure --fail \
	     --output "$tarball" \
	     --url "http://cdimage.ubuntu.com/ubuntu-base/releases/18.04/release/ubuntu-base-18.04.5-base-$archurl.tar.gz"
	echo
fi

echo "[*] Extracting rootfs..."
mkdir "$distro_rootfs" 2>/dev/null

proot --root-id tar -xzf '$tarball' -C '$distro_rootfs' -v
cat > "$distro_rootfs/etc/resolv.conf" << EOF
nameserver 1.0.0.1
nameserver 1.1.1.1
nameserver 1.1.1.2
nameserver 8.8.4.4
nameserver 8.8.8.8
EOF
echo "127.0.0.1	localhost" >"$distro_rootfs/etc/hosts"
EOM


