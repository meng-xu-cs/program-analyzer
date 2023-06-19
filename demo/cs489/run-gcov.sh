#!/bin/bash -e

# sanity check
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path-to-package-directory>"
    exit 1
fi

# configuration
PKG=$(readlink -f $1)
WKS=output-gcov
CMD=$(cat <<END
    rm -rf ${WKS} && mkdir ${WKS} &&
    gcc -fprofile-arcs -ftest-coverage -g main.c -o ${WKS}/main &&
    for t in input/*; do ${WKS}/main < "\$t"; done &&
    gcov -o ${WKS} -n main.c
END
)

# entrypoint
docker run \
    --tty --interactive \
    --volume ${PKG}:/test \
    --workdir /test \
    --rm gcov \
    bash -c "${CMD}"
