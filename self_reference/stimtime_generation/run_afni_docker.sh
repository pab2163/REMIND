xhost + ${Parks}

docker run --rm -ti                    \
    --user=`id -u`                     \
    --platform linux/amd64             \
    -v /tmp/.X11-unix:/tmp/.X11-unix   \
    -e DISPLAY=host.docker.internal:0  \
    -v /Volumes/AUERBACHLAB/:/opt/home               \
    afni/afni_make_build
