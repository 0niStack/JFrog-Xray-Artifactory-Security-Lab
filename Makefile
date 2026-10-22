.PHONY: setup up down xray bootstrap site-up site-down scan clean
setup:
	./scripts/setup.sh
up:
	docker compose up -d
down:
	docker compose down
xray:
	./xray/install-xray.sh
bootstrap:
	./scripts/bootstrap-xray.sh
site-up:
	docker compose -f sample-site/docker-compose.yml up -d --build
site-down:
	docker compose -f sample-site/docker-compose.yml down
scan:
	./scripts/scan.sh
clean:
	docker compose down -v
	-cd xray/installer && docker compose -p xray down -v
