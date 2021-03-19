# arguments
AWS_ACCOUNT=
STAGING=
VERSION=$(git tag describe --abbrev=0 || echo 0.0.0)

REGISTRY=${AWS_ACCOUNT}.dkr.ecr.ap-northeast-1.amazonaws.com/tm/${STAGING}

.PHONY: all
all: nginx django

.PHONY: nginx
nginx:
	docker build \
		-t ${REGISTRY}/nginx:${VERSION} \
		-t ${REGISTRY}/nginx:latest \
		docker/nginx

	docker push ${REGISTRY}/nginx:${VERSION}
	docker push ${REGISTRY}/nginx:latest

.PHONY: django
django:
	docker build \
		-t ${REGISTRY}/django:${VERSION} \
		-t ${REGISTRY}/django:latest \
		src

	docker push ${REGISTRY}/django:${VERSION}
	docker push ${REGISTRY}/django:latest
