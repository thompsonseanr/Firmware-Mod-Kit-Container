# Firmware Mod Kit 

> **Links:**  
> [Firmware Mod Kit Git](https://github.com/rampageX/firmware-mod-kit)  
> [Dockerhub Focal by Tag](https://hub.docker.com/_/ubuntu/tags?name=focal)  
> [podman-volume-create](https://docs.podman.io/en/v2.0.6/markdown/podman-volume-create.1.html)  
> [Manage Container Storage with Podman Volumes](https://www.geeksforgeeks.org/devops/manage-storage-with-podman-volumes/)  
> [Running Processes In A Podman Container](https://www.nas.nasa.gov/hecc/support/kb/running-processes-in-a-podman-container_696.html)  


## Podman and Ubuntu Focal

### Pull Container Image:

```
podman pull ubuntu:focal
```

### Create podman volume:

```
podman volume create <VOLUME_NAME>
```

### List volumes:

```
podman volume ls
```

### Start container with volume and bind mount

- add flag to remove created container after stopping: `--rm`  
- run detached: `-d`

```
podman run -it -d --mount type=bind,source=<HOST_DIRECTORY>,target=/<GUEST_DIRECTORY_TARGET> -v <VOLUME_NAME>:/<GUEST_DIRECTORY_TARGET> --name <CONTAINER_NAME> <IMAGE_ID_OR_NAME>
```

**Example:**
```
podman run -it -d --rm --mount type=bind,source=/home/<USER>/podman_mnt/data,target=/shared_data -v ubuntu-focal-vol:/home/ --name ubuntu_focal b7bab04fd9aa
```

### Enter Container:

```
podman exec -it <CONTAINER_ID_OR_NAME> <SHELL_ENV>
```

**Example: (running bash instead of sh)**

```
podman exec -it 8506dff92bfe /bin/bash
```

### For Ubuntu:

```
apt-get update
```

Dependencies:

```
apt-get install git build-essential zlib1g-dev liblzma-dev python3-magic autoconf python-is-python3 zip unzip vim binwalk lzop cramfsswap tree 
```

Show list of user-installed packages:

```
apt-mark showmanual
```

Install suggested packages:

```
sudo apt-get install --install-suggests <PACKAGE_NAME>
```

Install Python packages:

```
pip install python-lzo crcmod zstandard ubi_reader
```

### Clone firmware-mod-kit (created in /home):

```
git clone https://github.com/rampageX/firmware-mod-kit.git
```

### Create podman commit to save image snapshot of state of container:

- add flag to save volumes: `--include-volumes`

```
podman commit -p <CONTAINER_ID_OR_NAME> <NEW_CONTAINER_ID_OR_NAME>:<TAG>
```

**Example:**

```
podman commit --include-volumes -p ubuntu_focal focal_firmware
```

### Start container:

```
podman run -it -d --rm <CONTAINER_ID_OR_NAME>
```

### Stop container:

```
podman stop <CONTAINER_ID_OR_NAME>
```

# Dockerfile

### Build image without caching:   

```
podman build --no-cache -t <NEW_IMAGE_NAME> .
```
