REPO_USER=ntnbhat
APP_NAME=validator
BIN=./bin/AdmissionWebhook
MAIN_GO=./main.go
GO111MODULE=on
GO=${CIFLAGS} GO111MODULE=on go


build-linux:
	@echo "==> Building..."
	@echo "Local build" > version.txt
	@echo `hostname` >> version.txt
	@echo `date` >> version.txt
	@echo ${VERSION} >> version.txt
	cat version.txt
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 ${GO} build -o ${BIN}


docker-build: build-linux
	@echo "Docker Build"
	docker build -t ${REPO_USER}/${APP_NAME}:${VERSION} .
	@echo "Build complete"

push: docker-build
	docker push ${REPO_USER}/${APP_NAME}:${VERSION}
	@echo "Pushed"

