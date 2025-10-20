
#!/usr/bin/env python3
# build_emoji_plist_groups.py
# Generate the user's schema: [ { "title": "Group", "emojis": [ <string or [cluster]> ] }, ... ]
import argparse, plistlib, re
from collections import OrderedDict

GROUPS_ORDER = [
    "Smileys & People",
    "Animals & Nature",
    "Food & Drink",
    "Activities",
    "Travel & Places",
    "Objects",
    "Symbols",
    "Flags",
]

MAP_EMOJI_TEST_TO_UI = {
    "Smileys & Emotion": "Smileys & People",
    "People & Body": "Smileys & People",
    "Animals & Nature": "Animals & Nature",
    "Food & Drink": "Food & Drink",
    "Activities": "Activities",
    "Travel & Places": "Travel & Places",
    "Objects": "Objects",
    "Symbols": "Symbols",
    "Flags": "Flags",
}

# Skin tone modifiers
TONE_CHARS = [0x1F3FB, 0x1F3FC, 0x1F3FD, 0x1F3FE, 0x1F3FF]
TONE_SET = set(chr(cp) for cp in TONE_CHARS)

def strip_tones(s: str) -> str:
    return "".join(ch for ch in s if ch not in TONE_SET)

def parse_emoji_test(path):
    groups = OrderedDict((g, []) for g in GROUPS_ORDER)
    current = None
    with open(path, "r", encoding="utf-8") as fp:
        for line in fp:
            if line.startswith("# group:"):
                raw = line.split(":",1)[1].strip()
                mapped = MAP_EMOJI_TEST_TO_UI.get(raw, raw)
                current = mapped
                if current not in groups:
                    groups[current] = []
                continue
            if "; fully-qualified" in line and current is not None:
                after = line.split("#",1)[1].strip()
                emoji = after.split(" ",1)[0]
                groups[current].append(emoji)
    return groups

def cluster_tones_preserving_order(emojis):
    """
    Input: flat list of emojis in display order.
    Output: list where each element is either a string (no tones),
            or a list [base, base+tone1, base+tone2, ...] clustered together.
    """
    # Ordered map: base -> (first_index, ordered_unique_variants_list)
    base_map = OrderedDict()
    seen = set()
    for idx, e in enumerate(emojis):
        base = strip_tones(e)
        bucket = base_map.get(base)
        if bucket is None:
            base_map[base] = [idx, []]
            bucket = base_map[base]
        # append preserving order, unique
        if e not in bucket[1]:
            bucket[1].append(e)

    # Build output preserving the *first occurrence order* of base
    out = []
    for base, (first_idx, variants) in sorted(base_map.items(), key=lambda kv: kv[1][0]):
        # If variants contains tones or base repeats, we output a cluster array
        has_tone_variant = any(any(ch in TONE_SET for ch in v) for v in variants)
        if has_tone_variant:
            # Ensure base first, then tones in the order they appeared
            # If base not present in variants (rare), insert it at the front
            base_present = base in variants
            ordered = [base] + [v for v in variants if v != base]
            out.append(ordered)
        else:
            # No tones -> just a single string
            out.append(base)
    return out

def to_schema(groups):
    out = []
    for g in GROUPS_ORDER:
        raw = groups.get(g, [])
        grouped = cluster_tones_preserving_order(raw)
        out.append({"title": g, "emojis": grouped})
    # append any leftover groups not in predefined order
    for g, arr in groups.items():
        if g not in GROUPS_ORDER:
            grouped = cluster_tones_preserving_order(arr)
            out.append({"title": g, "emojis": grouped})
    return out

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--emoji-test", required=True, help="Path to emoji-test.txt (Unicode 15.1 / 16.0 etc.)")
    ap.add_argument("--out", required=True, help="Output plist path")
    args = ap.parse_args()

    groups = parse_emoji_test(args.emoji_test)
    plist = to_schema(groups)

    with open(args.out, "wb") as f:
        plistlib.dump(plist, f, sort_keys=False)
    total = sum(len(g['emojis']) for g in plist)
    print("Wrote", args.out, "groups:", len(plist), "top-level items:", total)

if __name__ == "__main__":
    main()
