import os
import socket

videos = []
client = socket.socket()
client.connect((socket.gethostbyname('localhost'), 3000))

# Append the video files paths into array
def load_videos():
    base_dir = os.path.dirname(os.path.realpath(__file__))
    videos_dir = os.path.join(base_dir, 'videos')
    for video in os.listdir(videos_dir):
        if video.lower().endswith('.mp4'):
            videos.append(os.path.join(videos_dir, video))
    pass

def main():
    load_videos()

    # Read the first video in bytes
    with open(videos[0], 'rb') as f:
        i = 0
        while True:
            buf = f.read(24)
            # Check for EOF
            if buf == '':
                break

            # Stream the data using the socket
            client.send(buf)

            i += 1
            print('---> Reading from buffer {}'.format(i))

    pass

# If running as the main script and not loaded as a module
if __name__ == '__main__':
    print('---> Starting main script')
    main()
