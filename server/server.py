import socket

def run():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(('127.0.0.1', 3001))

    bucket = list()

    while True:
        buf = 2048
        data, _ = sock.recvfrom(buf)
        print('---> Received ({}) {}'.format(type(data), data))

if __name__ == '__main__':
    run()
