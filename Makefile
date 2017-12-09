build:
	docker build -t ffmpeg --file Dockerfile.ffmpeg .
	docker build -t itstommy/diana .

dev_rtmp:
	docker run --rm \
		--name rtmp \
		-p 1935:1935 \
		-v ${PWD}/web/views:/var/www/html \
		-v ${PWD}/config/nginx.conf:/etc/nginx/nginx.conf \
		-p 80:80 \
		-ti ffmpeg

shell_rtmp:
	docker exec -ti rtmp bash



test_api:
	docker run --rm \
		--name diana_api \
		--env-file ${PWD}/.env \
		-e "MIX_ENV=test" \
		-v ${PWD}:/var/www/diana \
		-ti itstommy/diana mix test

dev_api:
	docker run --rm \
		--name diana_api \
		--env-file ${PWD}/.env \
		-v ${PWD}:/var/www/diana \
		-p 3000:3000 \
		-p 3001:3001 \
		-ti itstommy/diana mix run --no-halt
