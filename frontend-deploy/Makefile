REGISTRY_NAME={自身のリポジトリ名}

.PHONY: build up down
build:
	docker compose -f compose.preview.yaml build
up:
	docker compose -f compose.preview.yaml up --build
down:
	docker compose -f compose.preview.yaml down
push:
	docker tag frontend-deploy-frontend:latest $(REGISTRY_NAME)/frontend-deploy:latest
	docker push $(REGISTRY_NAME)/frontend-deploy:latest
