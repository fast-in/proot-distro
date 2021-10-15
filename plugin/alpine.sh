
pretty_name="Alpine Linux"
distro="alpine"
distro_rootfs="$rootfs_place/$distro-rootfs"
tarball="$cache/$distro.tar.gz"

cat > "$temp/install.sh" << EOM
#!$(command -v bash)

if ! [ -f '$tarball' -a -r '$tarball' ]; then
	rm -r -f '$tarball' 2>/dev/null
	echo "[*] Installing $(echo $'\e[0;93m')$pretty_name$(echo $'\e[m')..."
	case '$(uname -m)' in
		aarch64|arm64) archurl=aarch64;;
		arm|armhf) archurl=armhf;;
		armv7) archurl=armv7;;
		ppc64le) archurl=ppc64le;;
		x86|i*86) archurl=x86;;
		amd64|x86_64) archurl=x86_64;;
		*) echo 1>&2 "Unknown Arcitecture"; exit 1
	esac

	url="https://dl-cdn.alpinelinux.org/alpine/v3.14/releases/\$archurl/alpine-minirootfs-3.14.2-\$archurl.tar.gz"
	curl -L -o '$tarball' "\$url"
	echo
fi
echo "[*] Extracting rootfs..."
mkdir '$distro_rootfs'

proot --root-id tar -xzf '$tarball' -C '$distro_rootfs' -v
cat > '$distro_rootfs/etc/resolv.conf' <<- EOF
nameserver 1.0.0.1
nameserver 1.1.1.1
nameserver 1.1.1.2
nameserver 8.8.4.4
nameserver 8.8.8.8
EOF
echo "127.0.0.1	localhost" >'$distro_rootfs/etc/hosts'

proot -0 -r '$distro_rootfs' -b /proc -b /dev -w / /usr/bin/env -i HOME=/var/tmp \
PATH=/usr/sbin:/usr/bin:/sbin:/bin \
MOZ_FAKE_NO_SANDBOX=1 LANG=C.UTF-8 /bin/sh -c "apk update; apk add --no-cache bash coreutils"

curl https://raw.githubusercontent.com/fast-in/proot-distro/main/etc/profile|tee '$distro_rootfs/etc/skel/.profile' 1> '$distro_rootfs/root/.profile'
curl https://raw.githubusercontent.com/fast-in/proot-distro/main/etc/bashrc|tee '$distro_rootfs/etc/skel/.bashrc' 1> '$distro_rootfs/root/.bashrc'
sed -i 's/\/bin\/ash/\/bin\/bash/g' '$distro_rootfs/etc/passwd'
EOM
