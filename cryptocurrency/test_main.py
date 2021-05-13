from main import Buffer
import pytest


@pytest.fixture
def b():
    return Buffer()


def test_buffer_write_byte(b):
    b.write_byte(ord('T'))
    b.write_byte(ord('E'))
    b.write_byte(ord('S'))
    b.write_byte(ord('T'))
    assert b.get() == b'TEST'


def test_buffer_write_be_int(b):
    b.write_be_int64(1)
    b.write_be_int32(2)
    b.write_be_int16(3)
    assert b.get() == b'\x00\x00\x00\x00\x00\x00\x00\x01' + \
        b'\x00\x00\x00\x02' + b'\x00\x03'


def test_buffer_write_le_int(b):
    b.write_le_int64(1)
    b.write_le_int32(2)
    b.write_le_int16(3)
    assert b.get() == b'\x01\x00\x00\x00\x00\x00\x00\x00' + \
        b'\x02\x00\x00\x00' + b'\x03\x00'
