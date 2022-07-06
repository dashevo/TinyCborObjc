#!/usr/bin/env bash

# This script tries to find symbols that are not prefixed with the custom build
# setting OBJC_CBOR_MANGLING_PREFIX. See section "Mangling" in README.md for
# details.

set -Euo pipefail

nm -gUPA "$BUILT_PRODUCTS_DIR/libObjCCBOR.a" | cut -d ' ' -f 2 > "$TARGET_TEMP_DIR/ObjCCBOR-symbols.txt"
nm -gUPA "$BUILT_PRODUCTS_DIR/libtinycbor.a" | cut -d ' ' -f 2 > "$TARGET_TEMP_DIR/tinycbor-symbols.txt"

grep -vf "$TARGET_TEMP_DIR/tinycbor-symbols.txt" "$TARGET_TEMP_DIR/ObjCCBOR-symbols.txt" \
    | grep -v -E "___block_descriptor_" \
    | grep -v -E "___copy_helper_" \
    | grep -v -E "___covrec_" \
    | grep -v -E "___destroy_helper_" \
    > "$TARGET_TEMP_DIR/ObjCCBOR-relevant-symbols.txt" \
    ;

cat "$TARGET_TEMP_DIR/ObjCCBOR-relevant-symbols.txt" \
    | sed 's/__OBJC_LABEL_PROTOCOL_\$//' \
    | sed 's/__OBJC_PROTOCOL_\$//' \
    | sed 's/__OBJC_PROTOCOL_REFERENCE_\$//' \
    | sed 's/_OBJC_CLASS_\$//' \
    | sed 's/_OBJC_METACLASS_\$//' \
    | sed -E 's/^\_//' \
    | sort \
    | uniq \
    > "$TARGET_TEMP_DIR/ObjCCBOR-relevant-symbol-names.txt" \
    ;

cat "$TARGET_TEMP_DIR/ObjCCBOR-relevant-symbol-names.txt" \
    | grep -v -E "^$OBJC_CBOR_MANGLING_PREFIX" \
    > "$TARGET_TEMP_DIR/ObjCCBOR-unmangled-symbol-names.txt" \
    ;

if [ -s "$TARGET_TEMP_DIR/ObjCCBOR-unmangled-symbol-names.txt" ]; then
    echo "error: Unmangled symbols detected."
    echo ""
    echo "The following symbols seem not to be mangled. Please add them to the
SYMBOLS_TO_MANGLE array in Scripts/ObjCCBORGenerateManglingHeader.sh."
    echo ""

    cat "$TARGET_TEMP_DIR/ObjCCBOR-unmangled-symbol-names.txt"

    echo ""
    echo "If some of those are a false positive and should not be mangled, please
adapt Scripts/ObjCCBORAssertAllSymbolsAreMangled.sh and make sure to filter
them out."
    echo ""

    exit 1
fi
