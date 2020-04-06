#!/bin/zsh
docker build -t jaysnee/terraform-test:0.3 ./app
docker push jaysnee/terraform-test:0.3