build:
	docker build -t ffmpeg --file Dockerfile.ffmpeg .
	docker build -t itstommy/diana .
