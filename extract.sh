IMAGE="dalehamel/livekernel:latest"
OUTPUT=live

rm -rf $OUTPUT
mkdir -p $OUTPUT
tmpdir=$(mktemp -d /tmp/livesys-snapXXXXXXX)

echo "Creating container from ${IMAGE}"
container=$(docker run -d ${IMAGE})

echo "Exporting ${container} to ${tmpdir}..."
docker export ${container} | sudo tar -C ${tmpdir} -xpf -

sudo cp ${tmpdir}/boot/vmlinuz* $OUTPUT/vmlinuz
sudo cp ${tmpdir}/boot/initrd* $OUTPUT/initrd.img

echo "Output is at ${OUTPUT}"
sudo chmod a+r ${OUTPUT}/*
sudo chown -R `whoami` ${OUTPUT}

echo "Cleaning up"
docker rm -f ${container}
sudo rm -rf ${tmpdir}
