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

function oldgrepao {
    grep -nHRI "${@}" --color=always --exclude-dir=.git . | sort
}

function grepao {
    if [ \( $# -eq 0 \) -o \( $# -eq 1 -a "$1" == "-h" \) ]
    then
        echo "Usage: grepao [OPTION...] <string>"
        echo "GREPAO will look for the occurencies of *string* from this folder and all of sub-folders"
        echo
        echo " LIST OF OPTIONS:"
        echo "    -f FILE   will only list occurrencies from the given *FILE*"
        echo "    --ns      will disable the '| sort' from grep lookup"
        echo "    --ng      will disable the '--exclude-dir=.git' param, so also searching into .git folder"
        echo "    -v        verbose mode: will print the grep command that grepao will execute"
    else

        REGEX=""
        FILE=""
        EXCLUDE_GIT="--exclude-dir=.git"
        SORT=1
        VERBOSE=0

        while [ "$1" != "" ]
        do
            if [ "$1" == "-f" ] ; then
                shift
                FILE="--include \*$1\*"
            elif [ "$1" == "--ns" ]; then
                SORT=0
            elif [ "$1" == "-v" ]; then
                VERBOSE=1
            elif [ "$1" == "--ng" ] ; then
                EXCLUDE_GIT=""
            else
                REGEX=$1
            fi

            shift
        done

        if [ -z "$REGEX" ] ; then
            echo "No string was found for grep lookup. Please check grepao usage with 'grepao -h'"
            return 1
        fi

        if [ ${SORT} -eq 1 ] ; then
            grep -nHRI --color=always ${FILE} ${EXCLUDE_GIT} "${REGEX}" . | sort
            SHOW_SORT="| sort"
        else
            grep -nHRI --color=always ${FILE} ${EXCLUDE_GIT} "${REGEX}" .
            SHOW_SORT=""
        fi

        CMD="grep -nHR --color=always ${FILE} ${EXCLUDE_GIT} \"${REGEX}\" . ${SHOW_SORT}"
        if [ ${VERBOSE} -eq 1 ] ; then
            echo ${CMD}
        fi
    fi
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

function manifest_find() {

    if [ $# -eq 0 ] ; then
        echo "Please insert a project/folder to inspect"
        return 1
    else
        repo manifest | grep -i $@
    fi
}

function checkoutbranch {
    arr=("$(git branch | awk -F ' +' '! /\(no branch\)/ {print $2}')")

    select opt in $arr
    do
        if [ ! -z $opt ]; then
            git checkout $opt
            break;
        fi
    done
}

function findf {
    if [ \( $# -eq 0 \) -o \( $# -eq 1 -a "$1" == "-h" \) ]
    then
        echo "Usage: findf [OPTION...] <file name"
        echo "FINDF will look for the given file from this folder and all of sub-folders"
        echo
        echo " LIST OF OPTIONS:"
        echo "    -i    will perform a case-insensitive query over file name"
        echo "    -v    verbose mode: will print the find command that findf will execute"
        echo "    -w    GO WILD - use wildcards at the beginning and end of the filename"
        echo "    -h    will display the help/instructions"
    else
        unset FILETOCHECK
        unset VERBOSE
        PARAM="-name"
        WILD=""

        while [ "$1" != "" ]
        do
            if [ "$1" == "-i" ]; then
                PARAM="-iname"
            elif [ "$1" == "-v" ]; then
                VERBOSE="true"
            elif [ "$1" == "-w" ]; then
                WILD="*"
            else
                FILETOCHECK="$1"
            fi

            shift
        done

        if [ -z "$FILETOCHECK" ] ; then
            echo "No filename was passed as argumento to findf"
        else
            if [[ ! -z "$VERBOSE" ]] ; then
                CMD="find . $PARAM \"$WILD$FILETOCHECK$WILD\""
                echo "[VERBOSE MODE] Command issued:" $CMD
                echo
            fi
            find . $PARAM "$WILD${FILETOCHECK}$WILD"

        fi
    fi

}

function emulator {
    emulator_bin_path="~/Android/Sdk/emulator/emulator"
    avds_list=$(eval "$emulator_bin_path -list-avds")

    avds_list_array=($avds_list)
    len=${#avds_list_array[@]}

    if [ $len -eq 1 ]; then
        eval $emulator_bin_path -avd "$avds_list" &
        return;
    fi

    EXIT_OPTION=" EXIT"
    avds_list=$avds_list$EXIT_OPTION

    COL=$COLUMNS
    COLUMNS=12
    PS3=$'\n'"> "

    select opt in $avds_list
    do
        if [[ $opt == "EXIT" ]]; then
            echo "Exiting..."
            COLUMNS=$COL
            return 1
        elif [ ! -z $opt ]; then
            eval $emulator_bin_path -avd $opt &
            break;
        fi
    done

    COLUMNS=$COL
}

function getAndroidDevice {
    devices="$(adb devices)"

    PREFIX="List of devices attached"

    devices_array=${devices//$PREFIX/}
    devices_array=${devices_array//"device"/}

    list=($devices_array)
    len=${#list[@]}

    if [ $len -eq 1  ]; then
        echo "$list"
        return;
    fi

    select opt in $devices_array
    do
        if [ ! -z $opt ]; then
            echo $opt
            break;
        fi
    done
}

function rununittest {
    BASE_PAGSEGURO_REPO_PATH="app-myaccount-android"
    LAST_SEGMENT_PATH=$(pwd | awk -F / '{print $NF}')

    RED='\033[0;31m'
    BLUE='\033[1;34m'
    NC='\033[0m'

    if [ $LAST_SEGMENT_PATH != $BASE_PAGSEGURO_REPO_PATH ]; then
        echo "You need to be at \"$BASE_PAGSEGURO_REPO_PATH\" to run this test!"

        SUG_PATH=$(pwd | sed "s/\(^.*${BASE_PAGSEGURO_REPO_PATH}[^\/]*\).*$/\1/g")

        if [[ "${SUG_PATH}" =~ "${BASE_PAGSEGURO_REPO_PATH}" ]]; then
            echo -e "Shouldn't this be running at: [${BLUE}"$SUG_PATH"${NC}] ?"
        fi
        return;
    fi

    DEVICE=$(getAndroidDevice)

    echo -e "${RED}*** STOPPING ANY GRADLE PROCESS  ***${NC}"
    ./gradlew --stop > log.txt

    echo -e "${RED}*** GRADLE CLEAN PROCESS ***${NC}"
    ./gradlew clean >> log.txt

    echo -e "${RED}*** ASSEMBLE RELEASE FLAVOR ***${NC}"
    ./gradlew app:assembleRelease >> log.txt

    echo -e "${RED}*** GRADLE LINT VITAL RELEASE TASK ***${NC}"
    ./gradlew app:lintVitalRelease >> log.txt

    echo -e "${RED}*** ASSEMBLE Uiest FLAVOR ***${NC}"
    ./gradlew app:assembleUitest >> log.txt

    echo -e "${RED}*** ASSEMBLE AndroidTest APP ***${NC}"
    ./gradlew app:assembleAndroidTest >> log.txt

    echo -e "${RED}*** RUN UNIT TEST TASK ***${NC}"
    ./gradlew app:testUitestUnitTest >> log.txt

    PACKAGE_TEST=$(adb -s "$DEVICE" shell pm list package | grep myaccount.test)
    if [ ${#PACKAGE_TEST} -ne 0 ]; then
        echo -e "${RED}*** UNINSTALLING PREVIOUS PAGSEGURO TEST APP ***${NC}"
        adb -s "$DEVICE" uninstall br.com.uol.ps.myaccount.test
    fi

    PACKAGE_MAIN=$(adb -s "$DEVICE" shell pm list package | grep myaccount)
    if [ ${#PACKAGE_MAIN} -ne 0 ]; then
        echo -e "${RED}*** UNINSTALLING PREVIOUS PAGSEGURO APP ***${NC}"
        adb -s "$DEVICE" uninstall br.com.uol.ps.myaccount
    fi

    echo -e "${RED}*** INSTALLING PAGSEGURO APP ***${NC}"
    adb -s "$DEVICE" install app/build/outputs/apk/uitest/app-uitest.apk

    echo -e "${RED}*** INSTALLING PAGSEGURO TEST APP ***${NC}"
    adb -s "$DEVICE" install app/build/outputs/apk/androidTest/uitest/app-uitest-androidTest.apk

    echo -e "${RED}*** RUNNING UI INSTRUMENTED TESTS ***${NC}"
    adb -s "$DEVICE" shell am instrument -w "br.com.uol.ps.myaccount.test/br.com.uol.ps.myaccount.custom.CustomRunner" >> log.txt

}

function activityOnTop {
    device=$(getAndroidDevice)

    adb -s "$device" shell dumpsys window windows | grep -E 'mCurrentFocus|mFocusedApp'
}

function fragmentOnTop {
    device=$(getAndroidDevice)

    package="br.com.uol.ps.myaccount"

    # fragment_array=("$(adb -s $device shell dumpsys activity $package | grep -oE "Child\sFragmentManager{\w+\s+\w+\s(\w*)" | cut -d " " -f 4)")
    fragment_array=("$(adb -s $device shell dumpsys activity $package | grep -A1 "Added Fragments" | grep -oE "#0:\s(\w*)" | cut -d " " -f 2)")
    fragment_array=("$(echo $fragment_array | cut -d " " -f 2)")

    echo -e "\nThe current fragment for package [$package] on top is [$fragment_array]"

}


function psopen {
    device=$(getAndroidDevice)
    adb -s "$device" shell am start -n br.com.uol.ps.myaccount/.MainActivity
}

function psclear {
    device=$(getAndroidDevice)
    adb -s "$device" shell pm clear br.com.uol.ps.myaccount
}

function pstestclear {
    device=$(getAndroidDevice)
    adb -s "$device" shell pm clear br.com.uol.ps.myaccount.test
}

function psuninstall {

    RED='\033[0;31m'
    BLUE='\033[1;34m'
    NC='\033[0m'

    device=$(getAndroidDevice)

    PACKAGE_TEST=$(adb -s "$device" shell pm list package | grep myaccount.test)
    if [ ${#PACKAGE_TEST} -ne 0 ]; then
        echo -e "${RED}*** UNINSTALLING PREVIOUS PAGSEGURO TEST APP ***${NC}"
        adb -s "$device" uninstall br.com.uol.ps.myaccount.test
    else
        echo -e "${BLUE}*** Package [br.com.uol.ps.myaccount.text] is not installed in the device ***${NC}"
    fi

    PACKAGE_MAIN=$(adb -s "$device" shell pm list package | grep myaccount)
    if [ ${#PACKAGE_MAIN} -ne 0 ]; then
        echo -e "${RED}*** UNINSTALLING PREVIOUS PAGSEGURO APP ***${NC}"
        adb -s "$device" uninstall br.com.uol.ps.myaccount
    else
        echo -e "${BLUE}*** Package [br.com.uol.ps.myaccount] is not installed in the device ***${NC}"
    fi

}

