
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/assert.sh
shelduck import ../hoid.sh


init_dir() {
	set -- "target/$1"
	rm -rf "$1"
	mkdir -p "$1"
	cd "$1"
}

test_image_load() {
	assert_ok ssh "$HOID_TARGET" echo hello from remote target

	hoid command sudo docker image rm --force hello-world
	assert_error ssh_docker_save 

	
	x=$(mktemp -d)
	docker image save --output "$x/hello-world.tar.gz" hello-world:latest
	hoid --become true docker image load --input "$x/hello-world.tar.gz"

	assert_ok ssh_docker_save
}

ssh_docker_save() {
	hoid command rm    -rf ./test_docker_image_load
	hoid command mkdir -p  ./test_docker_image_load
	hoid buffer flush
	ssh "$HOID_TARGET" 'sudo docker image save --output ./test_docker_image_load/hello-world.tar hello-world:latest'
}

test_image_save() {
	true
}