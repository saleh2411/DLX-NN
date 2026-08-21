#!/usr/bin/env python3
"""
Q16.16 signed fixed-point helpers, shared by all softmax golden models so the
bit-level behaviour matches the hardware.

Layout: bit 31 sign, bits 30:16 integer, bits 15:0 fraction (scale 2^16).
Range [-32768.0, +32767.999985], resolution 2^-16.
Multiply convention: (a * b) >> 16, i.e. bits [47:16] of the 64-bit product.
"""

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
Q     = 16
SCALE = 1 << Q                              # 65536
MASK  = 0xFFFF_FFFF                          # 32-bit mask for hex display

INT32_MAX =  0x7FFF_FFFF                     #  2 147 483 647
INT32_MIN = -0x8000_0000                     # -2 147 483 648

ONE       = 1 << Q                           # 1.0 in Q16.16  = 0x0001_0000

# ---------------------------------------------------------------------------
# Conversion helpers
# ---------------------------------------------------------------------------

def to_q(value: float) -> int:
    """Convert a float to Q16.16 (signed 32-bit integer)."""
    return int(round(value * SCALE))


def from_q(q_val: int) -> float:
    """Convert a Q16.16 integer back to float."""
    return q_val / SCALE


def to_hex(q_val: int) -> str:
    """Return the unsigned 32-bit hex string for a (possibly negative) Q16.16 value."""
    return f"0x{q_val & MASK:08X}"

# ---------------------------------------------------------------------------
# Arithmetic helpers
# ---------------------------------------------------------------------------

def q_mul(a: int, b: int) -> int:
    """
    Q16.16 multiply: (a * b) >> 16.

    The 64-bit product is arithmetic-right-shifted by 16.  This matches the
    hardware extraction of bits [47:16] from a signed 64-bit product.
    """
    return (a * b) >> Q


def q_sat(value: int) -> int:
    """Saturate *value* to 32-bit signed range (hardware clamp)."""
    if value > INT32_MAX:
        return INT32_MAX
    if value < INT32_MIN:
        return INT32_MIN
    return value
