#!/bin/bash

__help_mtk_make() {
    cat << USAGE
SYNOPSIS:
$1 [-k|k|kernel] [-v|v|vendor] [-s|s|system] [-m|m|merge [split-build-script]]
$1 [-ak|ak|add-kernel config] [-av|av|add-vendor config] [-as|as|add-system config]
$1 [-l|l|list]

DESCRIPTION:
$1 is a helper script of MTK make.
The script would save your lastest lunch configs of sys, krnl
and vndr if you keep using these commands.
USAGE
}

# Assume user has sourced envsetup.sh
mtk-make() {
    local MERGE_CMD
    local CMD_LIST RET
    local SPLIT_BUILD MERGED_OUT_DIR
    local ARGV

    [ $# -eq 0 ] && {
        __help_mtk_make $FUNCNAME
        return 1
    }

    CMD_LIST=()
    while [ $# -ne 0 ]; do
        ARGV="$1"
        case "$ARGV" in
            ak|-ak|add-kernel)
                shift
                MTK_KERNEL_LUNCH="$1"
                lunch $MTK_KERNEL_LUNCH || {
                    __help_mtk_make
                    return 128
                }

                MTK_MAKE_KERNEL_OUT_DIR=$ANDROID_PRODUCT_OUT
                echo "kernel lunch added: $MTK_KERNEL_LUNCH"
                echo "kernel out added: $MTK_MAKE_KERNEL_OUT_DIR"
                ;;
            av|-av|add-vendor)
                shift
                MTK_VENDOR_LUNCH="$1"
                lunch $MTK_VENDOR_LUNCH || {
                    __help_mtk_make
                    return 128
                }

                MTK_MAKE_VENDOR_OUT_DIR=$ANDROID_PRODUCT_OUT
                echo "vendor lunch added: $MTK_VENDOR_LUNCH"
                echo "vendor out added: $MTK_MAKE_VENDOR_OUT_DIR"
                ;;
            as|-as|add-system)
                shift
                MTK_SYSTEM_LUNCH="$1"
                lunch $MTK_SYSTEM_LUNCH || {
                    __help_mtk_make
                    return 128
                }

                MTK_MAKE_SYSTEM_OUT_DIR=$ANDROID_PRODUCT_OUT
                echo "system lunch added: $MTK_SYSTEM_LUNCH"
                echo "system out added: $MTK_MAKE_SYSTEM_OUT_DIR"
                ;;
            k|-k|kernel)
                [ -z "$MTK_KERNEL_LUNCH" ] && {
                    echo "No cached kernel lunch" >&2
                    return 128
                }
                CMD_LIST+=("rm -rf $MTK_MAKE_KERNEL_OUT_DIR/obj/KERNEL_OBJ")
                CMD_LIST+=("lunch $MTK_KERNEL_LUNCH")
                CMD_LIST+=("make -j24 krn_images")
                ;;
            s|-s|system)
                [ -z "$MTK_SYSTEM_LUNCH" ] && {
                    echo "No cached system lunch" >&2
                    return 128
                }
                CMD_LIST+=("rm -rf $MTK_MAKE_SYSTEM_OUT_DIR/obj")
                CMD_LIST+=("lunch $MTK_SYSTEM_LUNCH")
                CMD_LIST+=("make -j24 sys_images")
                ;;
            v|-v|vendor)
                [ -z "$MTK_VENDOR_LUNCH" ] && {
                    echo "No cached vendor lunch" >&2
                    return 128
                }
                CMD_LIST+=("lunch $MTK_VENDOR_LUNCH")
                CMD_LIST+=("make -j24 vnd_images")
                ;;
            m|-m|merge)
                # SPLIT_BUILD=$MTK_MAKE_SYSTEM_OUT_DIR/images/split_build.py
                shift

                if [[ -f "$1" ]]; then
                    echo "set up split build script path: $1"
                    SPLIT_BUILD="$1"
                    shift
                else
                    SPLIT_BUILD="$MTK_MAKE_SYSTEM_OUT_DIR/images/split_build.py"
                fi

                MERGED_OUT_DIR=$MTK_MAKE_KERNEL_OUT_DIR/merged
                echo "========================================="
                echo "Make sure these pathes are correct or not"
                echo "split_build: $SPLIT_BUILD"
                echo "kernel: $MTK_MAKE_KERNEL_OUT_DIR"
                echo "vendor: $MTK_MAKE_VENDOR_OUT_DIR"
                echo "system: $MTK_MAKE_SYSTEM_OUT_DIR"
                echo "out: $MERGED_OUT_DIR"
                echo "========================================="
                MERGE_CMD="python $SPLIT_BUILD "
                MERGE_CMD+="--system-dir $MTK_MAKE_SYSTEM_OUT_DIR/images "
                MERGE_CMD+="--vendor-dir $MTK_MAKE_VENDOR_OUT_DIR/images "
                MERGE_CMD+="--kernel-dir $MTK_MAKE_KERNEL_OUT_DIR/images "
                MERGE_CMD+="--output-dir $MERGED_OUT_DIR"
                CMD_LIST+=("rm -rf $MERGED_OUT_DIR")
                CMD_LIST+=("$MERGE_CMD")
                continue
                ;;
            c*|-c*|clean)
                echo "-c | -c *) not support yet"
                echo "TODO: for clean purpose"
                return 0
                ;;
            l|-l|list)
                echo "List out dir:"
                echo "kernel: $MTK_MAKE_KERNEL_OUT_DIR"
                echo "vendor: $MTK_MAKE_VENDOR_OUT_DIR"
                echo "system: $MTK_MAKE_SYSTEM_OUT_DIR"
                echo "List lunch config:"
                echo "kernel: $MTK_KERNEL_LUNCH"
                echo "vendor: $MTK_VENDOR_LUNCH"
                echo "system: $MTK_SYSTEM_LUNCH"
                return 0
                ;;
            *)
                __help_mtk_make $FUNCNAME
                return 128
        esac
        shift
    done

    [ -z "${TARGET_PRODUCT}" ] && {
        echo "No lunch config?" >&2
        return 128
    }

    RET=''
    echo ${CMD_LIST[@]}
    for((i = 0; i < ${#CMD_LIST[@]}; i++)); do
        CMD=${CMD_LIST[$i]}
        echo "$CMD"
        $CMD || {
            RET=$?
            echo "failed at: $CMD" >&2
            return $RET
        }
    done

    return 0;
}
complete -F _lunch mtk-make
