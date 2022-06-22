# Create necessary directories and clone repository
cd ${DATA_DIR}
git clone https://github.com/NVIDIA/libnvidia-container.git
cd ${DATA_DIR}/libnvidia-container
git checkout v$LAT_V

# Patch nvc_ldcache.c and compile libnvidia-container
sed -i '/if (syscall(SYS_pivot_root, ".", ".") < 0)/,+1 d' ${DATA_DIR}/libnvidia-container/src/nvc_ldcache.c
sed -i '/if (umount2(".", MNT_DETACH) < 0)/,+1 d' ${DATA_DIR}/libnvidia-container/src/nvc_ldcache.c
make GO111MODULE=auto 2>/dev/null
mv ${DATA_DIR}/libnvidia-container/deps/src/elftoolchain-0.7.1/libelf/'name libelf.so.1' ${DATA_DIR}/libnvidia-container/deps/src/elftoolchain-0.7.1/libelf/libelf.so.1
if DESTDIR=${DATA_DIR}/libnvidia-container-$LAT_V make install prefix=/usr GO111MODULE=auto ; then
	:
else
	echo "---Can't compile libnvidia-container---"
	rm -R ${DATA_DIR}/libnvidia-container
	exit 0
fi

# Create daemon.json
mkdir -p ${DATA_DIR}/libnvidia-container-$LAT_V/etc/docker
tee ${DATA_DIR}/libnvidia-container-$LAT_V/etc/docker/daemon.json <<EOF
{
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
EOF
cd ${DATA_DIR}/libnvidia-container-$LAT_V
mkdir ${DATA_DIR}/v$LAT_V

# Create archive
tar cfvz ${DATA_DIR}/v$LAT_V/libnvidia-container-v$LAT_V.tar.gz *
