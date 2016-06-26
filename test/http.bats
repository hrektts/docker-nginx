#!/usr/bin/env bats

@test "initialize" {
    run docker run --label bats-type="test" --name bats-nginx -p 80:80 -d \
        hrektts/nginx:bats
    [ "${status}" -eq 0 ]
    until curl --head localhost
    do
        sleep 1
    done
}

@test "check http server" {
    run curl --head localhost
    [ -n "$(echo ${output} | grep 'HTTP/1.1 200 OK')" ]
}

@test "cleanup" {
    CIDS=$(docker ps -q --filter "label=bats-type")
    if [ ${#CIDS[@]} -gt 0 ]; then
        run docker stop ${CIDS[@]}
        run docker rm ${CIDS[@]}
    fi
}