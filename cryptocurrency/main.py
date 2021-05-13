import binascii
import socket
import time

from struct import pack, unpack
from hashlib import sha256

"""
Example of bitcoin P2P communication (At TESTNET3)
"""

# Bitcoin Protocol
# https://developer.bitcoin.org/devguide/p2p_network.html
# https://en.bitcoin.it/wiki/Protocol_documentation

# Implementation Reference
# https://dev.to/alecbuda/introduction-to-the-bitcoin-network-protocol-using-python-and-tcp-sockets-1le6
# https://sourcegraph.com/github.com/btcsuite/btcd/-/blob/peer/peer.go

MAGIC_MAIN = 0xD9B4BEF9
MAGIC_TESTNET = 0xDAB5BFFA
MAGIC_TESTNET3 = 0x0709110B
MAGIC_SIGNET = 0x40CF030A
MAGIC_NAME_COIN = 0xFEB4BEF9


def double_sha256(message):
    return sha256(sha256(message).digest()).digest()


def create_message(magic, command, payload):
    checksum = double_sha256(payload)[0:4]
    return pack('L12sL4s', magic, command.encode(), len(payload), checksum) + payload


def create_message_verack():
    return bytearray.fromhex("0b11090776657261636b000000000000000000005df6e0e2")


def create_payload_getdata(tx_id):
    hash = bytearray.fromhex(tx_id)
    payload = pack('<bi32s', 1, 1, hash)
    return(payload)


class Buffer:
    def __init__(self, raw=None):
        self.bytes = raw if raw != None else bytes()
        self.read = 0

    def get(self):
        return self.bytes

    def write(self, raw):
        self.bytes = self.bytes + raw

    def write_le_int64(self, n):
        self.write(pack("<q", n))

    def write_le_int32(self, n):
        self.write(pack("<i", n))

    def write_le_int16(self, n):
        self.write(pack("<h", n))

    def write_be_int64(self, n):
        self.write(pack(">q", n))

    def write_be_uint64(self, n):
        self.write(pack(">Q", n))

    def write_be_int32(self, n):
        self.write(pack(">i", n))

    def write_be_int16(self, n):
        self.write(pack(">h", n))

    def write_byte(self, n):
        self.write(pack("B", n))

    def read_has_more(self):
        return len(self.bytes) > self.read

    def read_bytes(self, size):
        data = self.bytes[self.read:self.read + size]
        self.read += size
        return data

    def read_be_uint64(self):
        return unpack(">Q", self.read_bytes(8))

    def read_le_int32(self):
        return unpack("<i", self.read_bytes(4))


def msg_version(peer_ip):
    b = Buffer()
    # Protocol version
    b.write_le_int32(70002)
    # Service
    b.write_le_int64(1)
    # Epoch time
    b.write_le_int64(int(time.time()))

    # Receiving node
    b.write_le_int64(1)
    b.write(b'\x00' * 10 + b'\xff\xff' + b'\x7f\x00\x00\x01')
    b.write_be_int16(18333)

    # Transmitting node
    b.write_le_int64(1)
    b.write(b'\x00' * 10 + b'\xff\xff' + socket.inet_aton(peer_ip))
    b.write_be_int16(18333)

    # Nonce
    b.write_le_int64(0)

    # User agent
    b.write_byte(0)

    b.write_le_int32(0)
    b.write_byte(1)

    return b.get()


buffer = b''


def read_message(read, command):
    global buffer
    start_of_message = None
    size_of_payload = None
    while True:
        buffer += read(1024)
        if start_of_message == None:
            if len(buffer) > 4:
                for i in range(0, len(buffer) - 4):
                    magic, = unpack("<i", buffer[i:i+4])
                    if magic == MAGIC_TESTNET3:
                        start_of_message = i
                        break
                    else:
                        print(f"{i} -> {i + 1} Not found magic")
                        print(buffer)
                        exit(0)

        if start_of_message != None:
                while len(buffer) > start_of_message + 20 and size_of_payload == None:
                    peer_command = buffer[start_of_message + 4:start_of_message+16].decode('utf-8').strip("\x00")
                    size_of_payload, = unpack(
                        "<i", buffer[start_of_message+16:start_of_message+20])
                    if peer_command != command:
                        print(f"Skip {peer_command} != {command}")
                        start_of_message += size_of_payload + 24
                        size_of_payload = None

        if start_of_message != None and size_of_payload != None:
            if start_of_message + 24 + size_of_payload < len(buffer):
                response = buffer[start_of_message:start_of_message +
                                  24+size_of_payload]
                buffer = buffer[start_of_message+24+size_of_payload:]
                return response


if __name__ == '__main__':
    test_nodes = socket.getaddrinfo(
        "seed.tbtc.petertodd.org", 18333, family=socket.AF_INET, proto=socket.IPPROTO_TCP)
    for i in test_nodes:
        (family, type, proto, canonname, sockaddr) = i
        try:
            s = socket.socket(family, type)
            s.settimeout(0.5)
            s.connect(sockaddr)
            buffer = b""
            
            s.settimeout(5)

            magic_value = 0x0709110B
            tx_id = "fc57704eff327aecfadb2cf3774edc919ba69aba624b836461ce2be9c00a0c20"
            null_string = "\x00"

            peer_ip_address, port = sockaddr
            version_message = create_message(
                magic_value, 'version', msg_version(peer_ip_address))

            getdata_payload = create_payload_getdata(tx_id)
            getdata_message = create_message(
                magic_value, 'getdata', getdata_payload)

            s.send(version_message)
            reply = read_message(s.recv, "version")
            print(f"Request: {binascii.hexlify(version_message)}")
            print(
                f"Response: {binascii.hexlify(reply)} {reply[4:16].decode('utf-8').strip(null_string)}")
            print()

            verack_message = create_message_verack()
            s.send(verack_message)
            reply = read_message(s.recv, "verack")
            print(f"Request: {binascii.hexlify(verack_message)}")
            print(
                f"Response: {binascii.hexlify(reply)} {reply[4:16].decode('utf-8').strip(null_string)}")
            print()

            s.send(getdata_message)
            reply = read_message(s.recv, "alert")
            print(f"Request: {binascii.hexlify(getdata_message)}")
            print(f"Response: {binascii.hexlify(reply)} {reply[4:16].decode('utf-8').strip(null_string)}")

            s.close()
            exit(0)
        except socket.timeout as e:
            print(f"something's wrong with {sockaddr}. Exception is {e}")
        finally:
            s.close()
