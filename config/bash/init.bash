export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Used for Android
## Generate compile_commands.json
export SOONG_GEN_COMPDB=1
export SOONG_GEN_COMPDB_DEBUG=1
# Make soong generate a symlink to the compdb file using an env var
# export SOONG_LINK_COMPDB_TO=$ANDROID_HOST_OUT

# FIXME: hard code here
export SHELL_DIR=$HOME/shell

__customize_ps1() {
    local white='\[\033[01;38m\]'
    local blue='\[\033[01;34m\]'
    local yellow='\[\033[38;5;11m\]'
    local green='\[\033[01;32m\]'
    local purple='\[\033[38;5;63m\]'
    local sed_purple='\\\[\\\033[38;5;63m\\\]'
    local sed_orange='\\\[\\\033[38;5;202m\\\]'
    local reset='\[\033[0m\]'

    PS1=${white}'[\t] ' # Current time
    PS1+='${debian_chroot:+($debian_chroot)}'
    PS1+=${purple}'$? '
    PS1+=${green}'\u@\h '
    PS1+=${blue}'\w '
    PS1+='$(git branch 2>&- | sed -e "/^[^*]/d" -e "s/* \(.*\)/'${sed_purple}'-> '${sed_orange}'\1/")'
    PS1+='\n'${reset}'└─ '
    PS1+=${yellow}'\$'${reset}' '

    export PS1
}

__knock_helper() {
    local NAME FILE
    local LIST DONE
    local POSTFIX='_helper.sh'

    LIST=($(ls ${SHELL_DIR}/tools/*${POSTFIX}))
    if [ -z "$LIST" ]; then
        return 128
    fi

    for ((i = 0; i < $#; i++)); do
        DONE=n
        for ((j = 0; j < ${#LIST[@]}; j++)); do
            FILE=$(basename ${LIST[$j]})
            NAME=${FILE//${POSTFIX}/}
            if [[ "$1" == $NAME ]]; then
                echo "call helper: $NAME"
                . ${LIST[$j]}
                DONE=y
                break
            fi
        done

        if [[ $DONE != y ]]; then
            echo "unsupport helper: $1"
            return 128
        fi
        shift
    done
}

__knock_helper_compl() {
    local LIST POSTFIX
    POSTFIX='_helper.sh'
    LIST="$(cd ${SHELL_DIR}/tools/ && { ls *${POSTFIX} | sed "s/$POSTFIX//g"; })"

    COMPREPLY=($(compgen -W "$LIST" "${COMP_WORDS[1]}"))
}

__customize_ps1
unset -f __customize_ps1
