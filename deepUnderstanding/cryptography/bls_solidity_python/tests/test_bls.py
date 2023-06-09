from brownie import TestBLS, accounts

from py_ecc.optimized_bn128 import *
from eth_hash.auto import keccak
from typing import Tuple
from eth_utils import encode_hex

# used for helped aggregation
def get_public_key_G1(secret_key: int) -> Tuple[FQ, FQ, FQ]:
    return multiply(G1, secret_key)


def get_public_key(secret_key: int) -> Tuple[FQ2, FQ2, FQ2]:
    return multiply(G2, secret_key)


def sign(message: Tuple[FQ, FQ, FQ], secret_key: int):
    return multiply(message, secret_key)


def aggregate_signatures(signatures: list[Tuple[FQ, FQ, FQ]]) -> Tuple[FQ, FQ, FQ]:
    res = signatures[0]
    for signature in signatures[1:]:
        res = add(res, signature)
    return res


def aggregate_public_keys(pubkeys: list[Tuple[FQ2, FQ2, FQ2]]) -> Tuple[FQ2, FQ2, FQ2]:
    res = pubkeys[0]
    for pubkey in pubkeys[1:]:
        res = add(res, pubkey)
    return res


# used for helped aggregation
def aggregate_public_keys_G1(pubkeys: list[Tuple[FQ, FQ, FQ]]) -> Tuple[FQ, FQ, FQ]:
    res = pubkeys[0]
    for pubkey in pubkeys[1:]:
        res = add(res, pubkey)
    return res


def hash_to_point(data: str):
    return map_to_point(keccak(data))


def map_to_point(x):
    pass


def sqrt(x_sqaure: int) -> Tuple[int, bool]:
    pass


def parse_solc_G1(solc_G1: Tuple[int, int]):
    x, y = solc_G1
    return FQ(x), FQ(y), FQ(1)


def format_G1(g1_element: Tuple[FQ, FQ, FQ]) -> Tuple[FQ, FQ]:
    x, y = normalize(g1_element)
    return (str(x), str(y))


def format_G2(g2_element: Tuple[FQ2, FQ2, FQ2]) -> Tuple[FQ2, FQ2]:
    x, y = normalize(g2_element)
    x1, x2 = x.coeffs
    y1, y2 = y.coeffs
    return x1, x2, y1, y2


def test_main():
    test_bls = accounts[0].deploy(TestBLS)

    secret_key = 123

    public_key = get_public_key(secret_key)
    data = encode_hex("fooooo")
    message_solc = tuple(test_bls.hashToPoint(data))
    message = parse_solc_G1(message_solc)
    sig = sign(message, secret_key)
    message_solc_2 = format_G1(message)
    assert message_solc_2 == message_solc
    pubkey_solc = format_G2(public_key)
    sig_solc = format_G1(sig)

    assert test_bls.verifySingle(sig_solc, pubkey_solc, message_solc_2)


def test_g2_subgroup_check():
    valid_G2 = multiply(G2, 5)
    assert is_on_curve(valid_G2, b2)

    # TODO: how do you create invalid G2?
    test_bls = accounts[0].deploy(TestBLS)

    assert test_bls.isOnSubgroupG2Naive(format_G2(valid_G2))

    gasCost = test_bls.isOnSubgroupG2NaiveGasCost(format_G2(valid_G2))
    print("G2 subgroup check naive", gasCost)

    assert test_bls.isOnSubgroupG2DLZZ(format_G2(valid_G2))

    gasCost = test_bls.isOnSubgroupG2DLZZGasCost(format_G2(valid_G2))
    print("G2 subgroup check DLZZ", gasCost)


def test_aggregation():
    test_bls = accounts[0].deploy(TestBLS)

    secret_key1 = 123
    secret_key2 = 456

    public_key1 = get_public_key(secret_key1)
    public_key1_solc = format_G2(public_key1)
    public_key2 = get_public_key(secret_key2)
    public_key2_solc = format_G2(public_key2)
    agg_public_key = aggregate_public_keys([public_key1, public_key2])
    agg_pubkey_solc = format_G2(agg_public_key)

    data = encode_hex("fooooo")
    message_solc = tuple(test_bls.hashToPoint(data))
    message = parse_solc_G1(message_solc)

    sig1 = sign(message, secret_key1)
    sig2 = sign(message, secret_key2)
    agg_sig = aggregate_signatures([sig1, sig2])
    agg_sig_solc = format_G1(agg_sig)

    # verifyMultiple is safer than verifySignle as it takes individual
    # public keys as arguments and aggregates them on chain,
    # preventing the rouge key attack.
    assert test_bls.verifyMultiple(
        agg_sig_solc, [public_key1_solc, public_key2_solc], [message_solc, message_solc]
    )

    # using verifySignle just to test aggregate_public_keys
    assert test_bls.verifySingle(agg_sig_solc, agg_pubkey_solc, message_solc)


# Helped aggregation : https://geometry.xyz/notebook/Optimized-BLS-multisignatures-on-EVM
# Making verification of multisignatures efficient
# each signer submits two public keys(in G1&G2) corresponding to their secret key
def test_helped_aggregation():
    test_bls = accounts[0].deploy(TestBLS)

    valid_G1 = multiply(G1, 5)
    assert is_on_curve(valid_G1, b)
    valid_G2 = multiply(G2, 5)
    assert is_on_curve(valid_G2, b2)

    data = encode_hex("fooooo")
    message_solc = tuple(test_bls.hashToPoint(data))
    message = parse_solc_G1(message_solc)

    secret_key1 = 123
    secret_key2 = 456

    sig1 = sign(message, secret_key1)
    sig1_solc = format_G1(sig1)
    sig2 = sign(message, secret_key2)
    sig2_solc = format_G1(sig2)
    agg_sig = aggregate_signatures([sig1, sig2])
    agg_sig_solc = format_G1(agg_sig)

    public_key1G1 = get_public_key_G1(secret_key1)
    public_key1G1_solc = format_G1(public_key1G1)
    public_key1G2 = get_public_key(secret_key1)
    public_key1G2_solc = format_G2(public_key1G2)
    assert test_bls.verifyHelpedAggregationPublicKeys(
        public_key1G1_solc, public_key1G2_solc
    )
    assert test_bls.verifyHelpedAggregationPublicKeysRec(
        public_key1G1_solc, public_key1G2_solc, data, sig1_solc
    )

    public_key2G1 = get_public_key_G1(secret_key2)
    public_key2G1_solc = format_G1(public_key2G1)
    public_key2G2 = get_public_key(secret_key2)
    public_key2G2_solc = format_G2(public_key2G2)
    assert test_bls.verifyHelpedAggregationPublicKeys(
        public_key2G1_solc, public_key2G2_solc
    )
    assert test_bls.verifyHelpedAggregationPublicKeysRec(
        public_key2G1_solc, public_key2G2_solc, data, sig2_solc
    )

    agg_public_key_G1 = aggregate_public_keys_G1([public_key1G1, public_key2G1])
    agg_pubkey_G1_solc = format_G1(agg_public_key_G1)

    agg_public_key_G2 = aggregate_public_keys([public_key1G2, public_key2G2])
    agg_pubkey_G2_solc = format_G2(agg_public_key_G2)

    assert test_bls.verifyHelpedAggregationPublicKeysMultiple(
        agg_pubkey_G1_solc, [public_key1G2_solc, public_key2G2_solc]
    )
    assert test_bls.verifyHelpedAggregationPublicKeysRec(
        agg_pubkey_G1_solc, agg_pubkey_G2_solc, data, agg_sig_solc
    )
