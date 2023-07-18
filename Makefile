PROJECT_NAME=svcwatchdog
REPOSITORY_NAME=svcwatchdog
REGISTRY_NAME=ghcr.io/jrmanes

# Go
.PHYONY: run build test test_cover get docs
run:
	go run ./cmd/main.go

run-config:
	go run ./cmd/main.go --config-file=./config-test.yaml

build:
	go build -o ./bin/${PROJECT_NAME} ./cmd/main.go

test:
	go test ./... -v .

test_cover:
	go test ./... -v -coverprofile cover.out
	go tool cover -func ./cover.out | grep total | awk '{print $3}'

get:
	go get ./...

docs:
	godoc -http=:6060

# Docker
docker_build:
	docker build -f Dockerfile -t ${PROJECT_NAME} -t ${PROJECT_NAME}:latest .

docker_build_local_push:
	#GOOS=linux go build -o ./svcwatchdog ./cmd/main.go
	docker build  -f Dockerfile -t ${PROJECT_NAME} .
	docker tag ${PROJECT_NAME}:latest localhost:5000/${REPOSITORY_NAME}:latest
	docker push localhost:5000/${REPOSITORY_NAME}:latest

docker_build_local_push_gh:
	GOOS=linux go build -o ./svcwatchdog ./cmd/main.go
	docker build  -f Dockerfile -t ${PROJECT_NAME} .
	docker tag ${REGISTRY_NAME}:latest ${REGISTRY_NAME}/${PROJECT_NAME}:latest
	docker push ${REGISTRY_NAME}/${PROJECT_NAME}:latest

docker_run:
	docker run -p 8080:8080 ${PROJECT_NAME}:latest

kubectl_apply:
	kubectl delete -f ./deployment/deployment.yaml ;\
	kubectl apply -f ./deployment/deployment.yaml

kubectl_deploy: docker_build_local_push kubectl_apply
