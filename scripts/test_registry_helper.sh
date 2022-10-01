RUMMAGE_REGISTRY_IMAGE=registry:2
RUMMAGE_REGISTRY_VOLUME=rummage-test
RUMMAGE_REGISTRY_DIR=/var/lib/registry
RUMMAGE_REGISTRY_CONTAINER=rummage-test
RUMMAGE_TEST_IMAGE_1=alpine:latest
RUMMAGE_TEST_IMAGE_2=busybox:latest

rummage_pull_images () {
    docker pull $RUMMAGE_REGISTRY_IMAGE
    docker pull $RUMMAGE_TEST_IMAGE_1
    docker pull $RUMMAGE_TEST_IMAGE_2

    docker tag $RUMMAGE_TEST_IMAGE_1 localhost:5000/$RUMMAGE_TEST_IMAGE_1
    docker tag $RUMMAGE_TEST_IMAGE_2 localhost:5000/$RUMMAGE_TEST_IMAGE_2
}

rummage_create_volume () {
    # initial pull so that cid is guaranteed to be free of pull dialogue
    docker pull $RUMMAGE_REGISTRY_IMAGE

    local cid=$(docker run --rm -d -p 5000:5000 \
        -v $RUMMAGE_REGISTRY_VOLUME:$RUMMAGE_REGISTRY_DIR \
        $RUMMAGE_REGISTRY_IMAGE)

    docker push localhost:5000/$RUMMAGE_TEST_IMAGE_1
    docker push localhost:5000/$RUMMAGE_TEST_IMAGE_2

    docker stop $cid
}

rummage_run_test_registry () {
    docker run --rm -d -p 5000:5000 \
        --name $RUMMAGE_REGISTRY_CONTAINER \
        -v $RUMMAGE_REGISTRY_VOLUME:$RUMMAGE_REGISTRY_DIR \
        $RUMMAGE_REGISTRY_IMAGE
}

rummage_stop_test_registry () {
    docker stop $RUMMAGE_REGISTRY_CONTAINER
}

rummage_remove_test_images () {
    docker rmi localhost:5000/$RUMMAGE_TEST_IMAGE_1
    docker rmi localhost:5000/$RUMMAGE_TEST_IMAGE_2
    docker rmi $RUMMAGE_TEST_IMAGE_1
    docker rmi $RUMMAGE_TEST_IMAGE_2
}

rummage_prune_images () {
    rummage_remove_test_images
    docker rmi $RUMMAGE_REGISTRY_IMAGE
}

rummage_remove_volume () {
    docker volume rm $RUMMAGE_REGISTRY_VOLUME
}

rummage_dev_up () {
    rummage_pull_images
    rummage_create_volume
    rummage_remove_test_images
    rummage_run_test_registry
}

rummage_dev_down () {
    rummage_stop_test_registry
    rummage_prune_images
    rummage_remove_volume
}
