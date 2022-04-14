#!/usr/bin/env sh

printf 'Waiting for GitLab container to become healthy'

until test -n "$(sudo docker ps --quiet --filter label=gitlab-microservices-bumper/owned --filter health=healthy)"; do
  printf '.'
  sleep 5
done

echo
echo 'GitLab is healthy'

# Print the version, since it is useful debugging information.
curl --silent --show-error --header "Authorization: Bearer ACCTEST1234567890123" "http://localhost:8000/api/v4/version"
echo
