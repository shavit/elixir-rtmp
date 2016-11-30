import socket
import signal
import sys

bucket = bytearray()

def user_signals(signal, frame):
    print('---> Terminating')
    with open('tmp/README.md', 'wb') as f:
        f.write(bucket)
    sys.exit(0)

def run():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(('127.0.0.1', 3001))

    while True:
        buf = 20480
        data, _ = sock.recvfrom(buf)
        print('---> Received ({}) {}'.format(type(data), len(data)))
        for d in data:
            bucket.append(d)

if __name__ == '__main__':
    signal.signal(signal.SIGINT, user_signals)
    run()
