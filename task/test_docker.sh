
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/assert.sh
shelduck import ../hoid.sh



test_image_load() {
	assert_ok ssh "$HOID_TARGET" echo hello from remote target

	hoid command sudo docker image pull hello-world
	hoid command sudo docker image rm --force hello-world
	assert_error ssh_docker_save

	
	x=$(mktemp -d)
	docker image pull hello-world:latest
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
	_test_image_save__tmp=$(mktemp -d)
	
	
	docker image rm --force hello-world
	assert_error docker image save --output "$_test_image_save__tmp/image1.tar" hello-world:latest

	hoid --become true command docker image pull hello-world
	hoid --become true docker image save --output "$_test_image_save__tmp/saved.tar.gz" hello-world:latest
	docker image load --input "$_test_image_save__tmp/saved.tar.gz"

	assert_ok docker image save --output "$_test_image_save__tmp/image2.tar" hello-world:latest


	rm -rf "$_test_image_save__tmp"
	unset _test_image_save__tmp
}