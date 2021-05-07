#!/bin/bash

# MIT License
# -----------
# Copyright (c) 2021 Karl Liang
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

# set default lunch config here
MTK_KERNEL_LUNCH="vnd_qbert-userdebug"
MTK_VENDOR_LUNCH="vnd_qbert-userdebug"
MTK_SYSTEM_LUNCH="sys_mssi_t_64_ab_p-userdebug"

__help_mtk_make() {
    cat << USAGE
SYNOPSIS:

$1 [-k|k|kernel] [-v|v|vendor] [-s|s|system] [-m|m|merge [split-build-script]]
$1 [-ak|ak|add-kernel config] [-av|av|add-vendor config] [-as|as|add-system config]
$1 [-l|l|list]

DESCRIPTION:

    $1 is a helper script for MTK build system. The script provides many
functions, like changing lunch config automatically between different builds,
stopping at failed command once error occurred, replacing original make command
with more simple string and show the total comsumed time of make process

USAGE
}

__mtk_lunch() {
    local -u str
    local out config

    str="MTK_$1_LUNCH"
    config=${!str}
    lunch $config || return $?

    str="MTK_MAKE_$1_OUT_DIR"
    declare -g "$str=$ANDROID_PRODUCT_OUT"
    out=${!str}

    return 0
}

__merge_cmd() {
    local split_build merged_dir

    if [ "$MTK_MAKE_KERNEL_OUT_DIR" == "" ]; then
        __mtk_lunch kernel || return $?
    fi
    if [ "$MTK_MAKE_VENDOR_OUT_DIR" == "" ]; then
        __mtk_lunch vendor || return $?
    fi
    if [ "$MTK_MAKE_SYSTEM_OUT_DIR" == "" ]; then
        __mtk_lunch system || return $?
    fi

    split_build=${1:-$MTK_MAKE_SYSTEM_OUT_DIR/images/split_build.py}
    merged_dir=$MTK_MAKE_KERNEL_OUT_DIR/merged

    echo "========================================="
    echo "Make sure these pathes are correct"
    echo "split_build: $split_build"
    echo "kernel: $MTK_MAKE_KERNEL_OUT_DIR"
    echo "vendor: $MTK_MAKE_VENDOR_OUT_DIR"
    echo "system: $MTK_MAKE_SYSTEM_OUT_DIR"
    echo "out: $merged_dir"
    echo "========================================="

    rm -rf $merged_dir
    python $split_build \
        --system-dir $MTK_MAKE_SYSTEM_OUT_DIR/images \
        --vendor-dir $MTK_MAKE_VENDOR_OUT_DIR/images \
        --kernel-dir $MTK_MAKE_KERNEL_OUT_DIR/images \
        --output-dir $merged_dir
    return $?
}

__mtk_make_exe_cmds() {
    local cmd_list
    local cmd ret i

    cmd_list=("$@")
    ret=0
    for((i = 0; i < ${#cmd_list[@]}; i++)); do
        cmd=${cmd_list[$i]}
        echo "$cmd"
        $cmd || {
            ret=$?
            echo "failed at: $cmd" >&2
            break
        }
    done

    return $ret
}

__mtk_make_boot() {
    local cmd_list

    cmd_list=()
    cmd_list+=("__mtk_lunch kernel")
    cmd_list+=("rm -rf $MTK_MAKE_KERNEL_OUT_DIR/obj/KERNEL_OBJ")
    cmd_list+=("rm -rf $MTK_MAKE_KERNEL_OUT_DIR/images/krn*")
    cmd_list+=("make -j24 krn_images")

    __mtk_make_exe_cmds "${cmd_list[@]}"
    return $?
}

__mtk_make_vendor() {
    local cmd_list

    cmd_list=()
    cmd_list+=("__mtk_lunch vendor")
    # prevent remove kernel obj while having same config with kernel
    cmd_list+=("rm -rf $MTK_MAKE_VENDOR_OUT_DIR/obj/[!KERNEL_OBJ]")
    cmd_list+=("rm -rf $MTK_MAKE_VENDOR_OUT_DIR/images/vnd*")
    cmd_list+=("make -j24 vnd_images")

    __mtk_make_exe_cmds "${cmd_list[@]}"
    return $?
}

__mtk_make_system() {
    local cmd_list

    cmd_list=()
    cmd_list+=("__mtk_lunch system")
    cmd_list+=("rm -rf $MTK_MAKE_SYSTEM_OUT_DIR/obj")
    cmd_list+=("rm -rf $MTK_MAKE_SYSTEM_OUT_DIR/images")
    cmd_list+=("make -j24 sys_images")

    __mtk_make_exe_cmds "${cmd_list[@]}"
    return $?
}

# Assume user has sourced envsetup.sh
mtk-make() {
    local cmd_list
    local argv
    local -i ret

    [ $# -eq 0 ] && {
        __help_mtk_make $FUNCNAME
        return 1
    }

    cmd_list=()
    while [ $# -ne 0 ]; do
        argv="$1"
        case "$argv" in
            ak|-ak|add-kernel)
                shift
                MTK_KERNEL_LUNCH="$1"
                echo "kernel lunch added: $MTK_KERNEL_LUNCH"
                ;;
            av|-av|add-vendor)
                shift
                MTK_VENDOR_LUNCH="$1"
                echo "vendor lunch added: $MTK_VENDOR_LUNCH"
                ;;
            as|-as|add-system)
                shift
                MTK_SYSTEM_LUNCH="$1"
                echo "system lunch added: $MTK_SYSTEM_LUNCH"
                ;;
            k|-k|kernel)
                cmd_list+=("__mtk_make_boot")
                ;;
            s|-s|system)
                cmd_list+=("__mtk_make_system")
                ;;
            v|-v|vendor)
                cmd_list+=("__mtk_make_vendor")
                ;;
            m|-m|merge)
                shift
                argv="$1"
                if [ -f "$argv" ]; then
                    cmd_list+=("__merge_cmd $argv")
                else
                    cmd_list+=("__merge_cmd")
                    continue
                fi
                ;;
            l|-l|list)
                echo "List lunch config:"
                echo "kernel: $MTK_KERNEL_LUNCH"
                echo "vendor: $MTK_VENDOR_LUNCH"
                echo "system: $MTK_SYSTEM_LUNCH"
                echo "List out dir:"
                echo "kernel: $MTK_MAKE_KERNEL_OUT_DIR"
                echo "vendor: $MTK_MAKE_VENDOR_OUT_DIR"
                echo "system: $MTK_MAKE_SYSTEM_OUT_DIR"
                return 0
                ;;
            *)
                __help_mtk_make $FUNCNAME
                return 128
        esac
        shift
    done

    local -i begin end intv
    begin=$(date +%s)
    __mtk_make_exe_cmds "${cmd_list[@]}"
    ret=$?
    end=$(date +%s)
    intv=$((end - begin))
    echo "total comsumed time: $(date -d@${intv} -u +%H:%M:%S)"

    return $ret;
}

if [ -f build/envsetup.sh ]; then
    . build/envsetup.sh
fi
complete -F _lunch mtk-make
