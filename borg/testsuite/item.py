import pytest

from ..item import Item
from ..helpers import StableDict


def test_item_empty():
    item = Item()

    assert item.as_dict() == {}

    assert 'path' not in item
    with pytest.raises(ValueError):
        'invalid-key' in item
    with pytest.raises(TypeError):
        b'path' in item
    with pytest.raises(TypeError):
        42 in item

    assert item.get('mode') is None
    assert item.get('mode', 0o666) == 0o666
    with pytest.raises(ValueError):
        item.get('invalid-key')
    with pytest.raises(TypeError):
        item.get(b'mode')
    with pytest.raises(TypeError):
        item.get(42)

    with pytest.raises(AttributeError):
        item.path

    with pytest.raises(AttributeError):
        del item.path


def test_item_from_dict():
    # does not matter whether we get str or bytes keys
    item = Item({b'path': b'/a/b/c', b'mode': 0o666})
    assert item.path == '/a/b/c'
    assert item.mode == 0o666
    assert 'path' in item

    item = Item({'path': b'/a/b/c', 'mode': 0o666})
    assert item.path == '/a/b/c'
    assert item.mode == 0o666
    assert 'mode' in item


def test_item_from_kw():
    item = Item(path=b'/a/b/c', mode=0o666)
    assert item.path == '/a/b/c'
    assert item.mode == 0o666


def test_item_int_property():
    item = Item()
    item.mode = 0o666
    assert item.mode == 0o666
    assert item.as_dict() == {'mode': 0o666}
    del item.mode
    assert item.as_dict() == {}
    with pytest.raises(TypeError):
        item.mode = "invalid"


def test_item_bigint_property():
    item = Item()
    small, big = 42, 2 ** 65
    item.atime = small
    assert item.atime == small
    assert item.as_dict() == {'atime': small}
    item.atime = big
    assert item.atime == big
    assert item.as_dict() == {'atime': b'\0' * 8 + b'\x02'}


def test_item_user_group_none():
    item = Item()
    item.user = None
    assert item.user is None
    item.group = None
    assert item.group is None


def test_item_se_str_property():
    # start simple
    item = Item()
    item.path = '/a/b/c'
    assert item.path == '/a/b/c'
    assert item.as_dict() == {'path': b'/a/b/c'}
    del item.path
    assert item.as_dict() == {}
    with pytest.raises(TypeError):
        item.path = 42

    # non-utf-8 path, needing surrogate-escaping for latin-1 u-umlaut
    item = Item({'path': b'/a/\xfc/c'})
    assert item.path == '/a/\udcfc/c'  # getting a surrogate-escaped representation
    assert item.as_dict() == {'path': b'/a/\xfc/c'}
    del item.path
    assert 'path' not in item
    item.path = '/a/\udcfc/c'  # setting using a surrogate-escaped representation
    assert item.as_dict() == {'path': b'/a/\xfc/c'}


def test_item_list_property():
    item = Item()
    item.chunks = []
    assert item.chunks == []
    item.chunks.append(0)
    assert item.chunks == [0]
    item.chunks.append(1)
    assert item.chunks == [0, 1]
    assert item.as_dict() == {'chunks': [0, 1]}


def test_item_dict_property():
    item = Item()
    item.xattrs = StableDict()
    assert item.xattrs == StableDict()
    item.xattrs['foo'] = 'bar'
    assert item.xattrs['foo'] == 'bar'
    item.xattrs['bar'] = 'baz'
    assert item.xattrs == StableDict({'foo': 'bar', 'bar': 'baz'})
    assert item.as_dict() == {'xattrs': {'foo': 'bar', 'bar': 'baz'}}
