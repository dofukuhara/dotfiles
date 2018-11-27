# Fukuhara - Display GIT Branch Name in prompt
#source /etc/bash_completion.d/git
#export PS1='\w$(__git_ps1 "(%s)") > '
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
#PS1="${debian_chroot:+($debian_chroot)}\[\033[00;32m\]\h:\[\033[01;34m\]\w\[\033[00;32m\]\$(parse_git_branch)\[\033[00m\] $ "
PS1="\n\[\033[01;34m\][\W]\[\033[00;32m\]\$(parse_git_branch)\[\033[00m\] $ "

# Fukuhara - Returning to the current path after using 'refri'
cd $current_path

# Fukuhara - Custom alias
alias upbash='vim /home/douglas.fukuhara/.bashrc'
alias upvim='vim /home/douglas.fukuhara/.vimrc'
alias refri='source /home/douglas.fukuhara/.bashrc'
alias gits='git status'
alias gitp='git pull'
alias gitd='git diff '
alias upapps='repo sync -j16 .'

#Fukuhara - Custom functions
function lobr {
    branch=("$(echo "${@}" | awk -F"/" '{print $NF}')")
    git checkout "${@}" -b "$branch"_local
}

function md5dev-backup {
    md5=("$(echo "${@}" | md5sum)")
    lenght=${#md5}
    lenght=$(($lenght-3))
    realMD5="${md5:0:lenght}"
    echo "tag_"$realMD5"_"
}

function md5dev {
    params=(${@})
    dev=${params[0]}
    switch=${params[1]}
    md5=("$(echo -n "$dev" | md5sum)")
    lenght=${#md5}
    lenght=$(($lenght-3))
    realMD5="${md5:0:lenght}"

    echo "Dev: "$dev
    echo "switch: "$switch
    echo "tag_"$realMD5"_"$switch
}

function grepim {
    params=(${@})
    size=${#params[@]}
    thing="${@:$size}"
    size=$(($size-1))
    params=${@:1:$size}
    grep -nHRI $params --color --exclude-dir=.git "$thing" .
}

function grepao {
    grep -nHRI "${@}" --color=always --exclude-dir=.git . | sort
}

function grepiao {
    grep -niHRI $2 $3 "$1" . --color=always --exclude-dir=.git | sort
}

function syncao {
    project=(${1})
    folder=(${2})

    if [ "${folder: -1}" = "/" ]; then
        folder="${folder: :-1}"
    fi;

    repo sync -j16 $project ; cd $folder ; repo start master .
}

function grepov {
    IFS_backup=$IFS
    IFS=$'\n'
    arr=("$(grep -nHRI --color=always --exclude-dir=.git "${@}" .)")
    COL=$COLUMNS
    COLUMNS=1
    PS3=$'\n'"> "
    select opt in $arr
    do
        if [ ! -z $opt ]; then
            IFS=$' '
            #to split and remove colors from opt
            rr=($(echo ${opt} | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" | awk '{split($0,a,":"); print a[1], a[2]}'))
            vim ${rr[0]} -c "/${@}" +${rr[1]}
            break;
        fi
    done
    COLUMNS=$COL
    IFS=$IFS_backup
}

function grepiov {
    IFS_backup=$IFS
    IFS=$'\n'
    arr=("$(grep -niHR --color=always --exclude-dir=.git "${@}" .)")
    COL=$COLUMNS
    COLUMNS=1
    PS3=$'\n'"> "
    select opt in $arr
    do
        if [ ! -z $opt ]; then
            IFS=$' '
            #to split and remove colors from opt
            rr=($(echo ${opt} | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" | awk '{split($0,a,":"); print a[1], a[2]}'))
            vim ${rr[0]} +${rr[1]}
            break;
        fi
    done
    COLUMNS=$COL
    IFS=$IFS_backup
}

function goapps {
    arr=("$(ls /home/douglas.fukuhara/repos/LG_apps_master/android/vendor/lge/apps)")
    exitOption=" EXIT"
    arr=$arr$exitOption

    COL=$COLUMNS
    COLUMNS=12

    PS3=$'\n'"> "
    select opt in $arr
    do
        if [[ $opt == "EXIT" ]]; then
            echo "Exiting..."
            return 1
        elif [ ! -z $opt ]; then
            cd "/home/douglas.fukuhara/repos/LG_apps_master/android/vendor/lge/apps/"$opt
            return 1
        #else
        #    echo "invalid option"
        #    return 1
        fi
    done

    COLUMNS=$COL
}

function lgappsFolder() {
    BASE_PATH='/home/douglas.fukuhara/repos/'
    BRANCH_PREFIX='LG_apps_'
    BRANCH_POSTFIX='_release/'

    echo $BASE_PATH$BRANCH_PREFIX$1$BRANCH_POSTFIX
}

function goover {
    APPS_PATH='android/vendor/lge/apps/'

    OS_ARRAY="M-OS N-OS O-OS P-OS EXIT"

    PS3=$'\n'"> "
    select opt in $OS_ARRAY
    do
        case "$opt" in
        "M-OS")
            APPS_RELEASE_FOLDER=$(lgappsFolder "m")
            ;;
        "N-OS")
            APPS_RELEASE_FOLDER=$(lgappsFolder "n")
            ;;
        "O-OS")
            APPS_RELEASE_FOLDER=$(lgappsFolder "o")
            ;;
        "P-OS")
            APPS_RELEASE_FOLDER=$(lgappsFolder "p")
            ;;
        "EXIT")
            echo "Exiting..."
            return 1
            ;;
        *)
            echo "Invalid option, please try another one!"
            return 1
        esac

        if [[ -d "$APPS_RELEASE_FOLDER" ]]; then

            if [[ ! -d "$APPS_RELEASE_FOLDER$APPS_PATH" ]]; then
                echo "You don't have any 'apkoverlay' folder, please sync if first!"
                return 1
            fi

            APKOVERLAYS=("$(ls $APPS_RELEASE_FOLDER$APPS_PATH)")
            select opt in $APKOVERLAYS
            do
                PATH_A=$APPS_RELEASE_FOLDER$APPS_PATH$opt
                PATH_SIZE_NUMBER=$((${#PATH_A} + 20))

                printf "\n╔"
                printf '=%.s' $(eval "echo {1.."$PATH_SIZE_NUMBER"}")
                printf '╗'

                printf "\n║ Entering inside [\e[1;34m$APPS_RELEASE_FOLDER$APPS_PATH$opt\e[0m] ║\n"

                printf '╚'
                printf '=%.s' $(eval "echo {1.."$PATH_SIZE_NUMBER"}")
                printf "╝\n\n"

                cd $APPS_RELEASE_FOLDER$APPS_PATH$opt

                return 1
            done

        else
            echo "Folder ["$APPS_RELEASE_FOLDER"] DOES NOT EXISTS!!!"
            return 1
        fi

    done
}

function goup {
    PARAM=(${@})
    RE='^[0-9]+$'
    PATH_PREV=$(pwd)

    if [[ $PARAM =~ $RE ]] ; then
        BACK_UNTIL=$(printf '../%.s' $(eval "echo {1.."$PARAM"}"))

        cd $BACK_UNTIL

        PATH_NEW=$(pwd)

    else

#        PARAM=$PARAM"/"
#        BACK_TO=$(expr ${PATH_PREV} : .*${PARAM})
#        if [ ${BACK_TO} -eq "0" ]; then
#            echo "folder ["$PARAM"] not found!"
#            return 0;
#        fi
#        PATH_NEW=$(expr substr ${PATH_PREV} 1 ${BACK_TO})

        PATH_NEW=$(pwd | sed "s/\(^.*${PARAM}[^\/]*\).*$/\1/g")

        cd $PATH_NEW

    fi

    echo "I sent you..."
    echo "From: ["$PATH_PREV"]"
    echo "To: ["$PATH_NEW"]"

}

