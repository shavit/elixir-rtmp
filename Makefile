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
