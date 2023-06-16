# program-analyzer

If you run into issues on booting up the virtual machine (VM) for whatever
reasons, this repository contains an experimental solution for setting up the
environment using Docker.

## Bootstrap

After cloning this repository, initialize all submodules recursively:

```bash
git submodule update --init --recursive
```

Check that you have Docker properly installed and running. List existing Docker
images and make sure you don't have images tagged as
`gcov`, `afl`, `klee`, or `symcc`.

```bash
docker image ls
```

## Build dependencies

### GCOV

```bash
cd deps/gcov
docker build -t gcov .
```

### AFL++

```bash
cd deps/AFLplusplus
docker build -t afl .
```

### KLEE

```bash
cd deps/klee
docker build -t klee .
```

### SymCC

```bash
cd deps/symcc
docker build -t symcc-base .
docker run --name symcc-next \
    symcc-base \
    bash -c "sudo apt-get update -y && sudo apt-get install -y screen"
docker commit symcc-next symcc
docker rm symcc-next
```

If you are not running on a x86-64 platform (e.g., Apple silicon), please add
the `--platform linux/amd64` option to `docker` commands:

```bash
cd deps/symcc
docker build --platform linux/amd64 -t symcc-base .
docker run --platform linux/amd64 --name symcc-next \
    symcc-base \
    bash -c "sudo apt-get update -y && sudo apt-get install -y screen"
docker commit symcc-next symcc
docker rm symcc-next
```

If Docker fails to build due to Cargo index taking too long to update, try to
apply the `symcc-cargo-sparse-registry.patch` in the `deps/patch` directory
to the `symcc` repository:

```bash
cd deps/symcc
git apply ../patch/symcc-cargo-sparse-registry.patch
```

## Helper scripts

### Run GCOV

```bash
cd demo/cs489
./run-gcov.sh <path-to-package>
```

### Run AFL++

```bash
cd demo/cs489
./run-afl.sh <path-to-package>
```

### Run KLEE

```bash
cd demo/cs489
./run-klee.sh <path-to-package>
```

### Run SymCC

```bash
cd demo/cs489
./run-symcc.sh <path-to-package>
```

Sometimes SymCC will run into issues and does not respond to signals like
interrupt (`Ctrl + C`) and the terminal freezes. When this happens, you can find
the process via `docker ps`, locate the container id, and kill the container via
`docker kill <container-id>`.