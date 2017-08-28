build:
	# Compile the ffmpeg executable
	docker build -t ffmpeg --file Dockerfile.ffmpeg .
	@ docker run -td --rm --name ffmpeg ffmpeg
	@ docker cp ffmpeg:/usr/bin/ffmpeg $(shell pwd)/tmp
	docker stop ffmpeg
	cp $(shell pwd)/tmp/ffmpeg $(shell pwd)/bin/

	# Compile the Dockerfile and copy the ffmpeg executable
	docker build -t itstommy/diana .
	@ rm $(shell pwd)/bin/ffmpeg
