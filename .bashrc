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
alias gitb='git branch'
alias gitl='git log'
alias gitlol='gitl --oneline'
alias gitfp='git fetch --prune && git pull'

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
    WRITABLE_SYSTEM=""

    if [ $# -eq 1 -a "$1" == "-h" ]
    then
        echo -e "\nUsage: emulator [OPTION...]"
        echo "EMULATOR will launch any Android Emulator (AVD) that is current configured for the current user"
        echo
        echo " LIST OF OPTIONS:"
        echo "     --ws    Will launch AVD with --writable-system flag enabled"
        echo "     -h      Help instructions for Emulator"
        echo
    else
      while [ "$1" != "" ]
      do
        if [ "$1" == "--ws" ]; then
          WRITABLE_SYSTEM="-writable-system"
        fi

        shift
      done

      emulator_bin_path="~/Library/Android/sdk/emulator/emulator"
      avds_list=$(eval "$emulator_bin_path -list-avds")

      avds_list_array=($avds_list)
      len=${#avds_list_array[@]}

      if [ $len -eq 1 ]; then
          eval $emulator_bin_path "$WRITABLE_SYSTEM" -avd "$avds_list" &
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
              eval $emulator_bin_path "$WRITABLE_SYSTEM" -avd "$opt" &
              break;
          fi
      done

      COLUMNS=$COL
    fi
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

function zipSenha {

    file_name=${@}
    zip_file=$(echo $file_name | sed 's/\(.*\)\..*/\1/').zip

    zip -e $zip_file $file_name
}

function come {

    local commit_type_arr
    local issue_type
    local jira_issue
    local commit_message
    local jira_regex
    local yes_no_option

    commit_type_arr="IMPROVEMENT BUGFIX FEATURE HOTFIX EXIT"
    jira_regex="^[A-Z]+-[0-9]+$"
    yes_no_option="SIM NÃO EXIT"

    echo "Selecione o tipo de atividade:"
    select opt in $commit_type_arr
    do
        if [ ! -z $opt ];
        then
            if [ $opt == "EXIT" ];
            then
                return 0
            else
                issue_type=$opt
                break
            fi
        fi
    done

    echo
    read -p 'Jira Issue: ' jira_issue
    if [[ ! $jira_issue =~ $jira_regex ]];
    then
        echo "O JiraID deve ser informado no formato no seguinte padrão: [A-Z]+-[0-9]+"
        return 1
    fi
    echo
    read -p 'Commit Messagem: ' commit_message
    echo

    echo "Deseja apenas mostrar o comando?"
    select opt in $yes_no_option
    do
        if [ ! -z $opt ];
        then
            if [ $opt == "EXIT" ];
            then
                return 0
            elif [ $opt == "SIM" ]; then
                echo
                echo "git commit -m \"[$issue_type][$jira_issue] - $commit_message\""
                break
            else
                git commit -m "[$issue_type][$jira_issue] - $commit_message"
                break
            fi
        fi
    done
}

function findAndClick {
    device=$(getAndroidDevice)

    adb -s "$device" shell "uiautomator dump | sleep 1s | cat /sdcard/window_dump.xml" | grep -oE ''"${@}"'.*bounds=\"\[\d*,\d*\]' | grep -oE '\[\d*,\d*\]' | head -1 | tr -d {}[] | awk -F',' '{print $1 " " $2}' | xargs adb shell input tap
}

function recordVideo {
  device=$(getAndroidDevice)

  DATE_PATH=$(date '+%Y-%m-%d')
  VIDEO_TIME=$(date '+%Y-%m-%d_%X')

  if [ \( $# -eq 0 \) ]
  then
    TEST_NAME=".mp4"
  else
    TEST_NAME="_"${@}".mp4"
  fi

  adb -s "$device" shell mkdir -p /sdcard/${DATE_PATH}/
  adb -s "$device" shell screenrecord /sdcard/${DATE_PATH}/"${VIDEO_TIME//:/.}${TEST_NAME// /-}"
}

function copyVideos {

  device=$(getAndroidDevice)

  if [ \( $# -eq 0 \) ]
  then
    DEST_PATH="."
  else
    DEST_PATH=${@}
  fi

  adb -s "$device" shell ls /sdcard | grep -E "\d{4}-\d{2}-\d{2}|mp4"  |  xargs -I {}  adb -s "$device" pull /sdcard/{} "$DEST_PATH"
}

function adbinput {
    device=$(getAndroidDevice)

    if [ $1 = "-t" ]; then
        input_param=${@:2:${#@}}
        adb -s "$device" shell input text ${input_param// /%s}
    elif [ $1 = "-k" ]; then
        shift
        adb -s "$device" shell input keyevent $1
    else
        adb -s "$device" shell input ${@}
    fi

}

function copyPath {
    local current_path=$(pwd)
    echo -n $current_path | pbcopy
}

function copyCurrentBranch {

  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

  echo -n $CURRENT_BRANCH | pbcopy

  echo "** Copied [$CURRENT_BRANCH] into clipboard area **"

}

function instrumentationTest {

    RED='\033[0;31m'
    NC='\033[0m'

    if [ -z "${@}" ]
    then
        echo -e "${RED}Informar o teste a ser executado!${NC}"
        return
    fi
    device=$(getAndroidDevice)
    adb -s "$device" shell am instrument -w -e class "${@}" br.com.uol.ps.myaccount.test/br.com.uol.ps.myaccount.custom.CustomRunner
}

function adbw {

    device=$(getAndroidDevice)

    echo -e "\n"
    adb -s "$device" ${@}
}

function goto() {
    pagseguro_proj=$(find ~/Projects/Pagseguro -type d -maxdepth 2 -mindepth 2 | sort)

    personal_proj=$(find ~/Projects/Personal -type d -maxdepth 1 -mindepth 1 | sort)

    projects=${pagseguro_proj///\Users\/dofukuhara\/Projects\//}" "${personal_proj///\Users\/dofukuhara\/Projects\//}" EXIT"

    COL=$COLUMNS
    COLUMNS=12
    select opt in $projects
    do
        if [[ $opt == "EXIT" ]]; then
            echo "Exiting..."
            COLUMNS=$COL
            return 1
        elif [ ! -z $opt ]; then
            project_path="/Users/dofukuhara/Projects/"$opt
            COLUMNS=$COL
            break;
        fi
    done

    cd $project_path
}

function bsReport() {
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    BLUE='\033[1;34m'
    NC='\033[0m'

    local authentication="$1"

    BUILD_NAME=${@}

    if [ -z "$BUILD_NAME" ]; then
        echo -e "${RED}*** INFORMAR O 'Build Name' ***${NC}"
    else
        BS_BUILD_RESULT=$(curl -u "$authentication" --ssl-no-revoke -X GET https://api-cloud.browserstack.com/app-automate/espresso/builds/name/$BUILD_NAME -H 'Content-Type: application/json' )

        echo $BS_BUILD_RESULT | python -m json.tool

        OPTIONS="SIM NAO"
        echo
        echo
        echo -e "${GREEN}*** Copiar JSON para o Clipboard? ***${NC}"
        select opt in $OPTIONS
        do
            if [[ $opt == "SIM" ]]; then
                echo $BS_BUILD_RESULT | python -m json.tool | pbcopy
                echo -e "${BLUE}*** JSON copiado para o Clipboard! ***${NC}"
                return 1
            else
                return 1
            fi
        done
    fi
}

function getreleasedata {
    local epoch_time_after="$1"
    local epoch_time_before="$2"
    local br_wf_name="$3"
    local br_app_slug="$4"
    local br_auth_token="$5"
    local br_build_status_success="1"

    if [ -z "$epoch_time_before" ]; then
        epoch_time_before="1640908800"
    fi
    if [ -z "$epoch_time_after" ]; then
        epoch_time="1609459200"
    fi
    local curl_command="curl --silent -X GET \"https://api.bitrise.io/v0.1/apps/${br_app_slug}/builds?sort_by=created_at&workflow=${br_wf_name}&after=${epoch_time_after}&before=${epoch_time_before}&status=${br_build_status_success}\" -H \"accept: application/json\" -H \"Authorization: ${br_auth_token}\""
    local result_json number_of_items br_build_slug version_name current_path build_start_date
    local tmp_dir="X${RAMDOM}P${RAMDON}T${RANDOM}O${RANDOM}"

    current_path=$(pwd)
    mkdir "$tmp_dir"

    cd "$current_path/$tmp_dir"

    result_json=$(eval $curl_command)
    number_of_items=$(echo "$result_json" | jq '.data | length')

    for index in $(seq $((number_of_items - 1)) 0); do
        version_name=$(echo "$result_json" | jq .data[$index].commit_message | tr -d "\"")
        br_build_slug=$(echo "$result_json" | jq .data[$index].slug | tr -d "\"")
        build_start_date=$(echo  "$result_json" | jq .data[$index].triggered_at | tr -d "\"" | awk -F'T' '{split($1,a,"-"); printf("%s/%s/%s", a[3], a[2], a[1])}')

        getbuildlog "$br_build_slug" "$version_name" "$build_start_date" "$br_wf_name"
    done

    cd "$current_path"
    rm -rf "$tmp_dir"
}

function getbuildlog {
    local build_slug=$1
    local version_name=$2
    local build_start_date=$3
    local br_wf_name=$4
    local br_app_slug="$5"
    local br_auth_token="$6"
    local bucket="$6"
    local curl_command="curl --silent -X GET \"https://api.bitrise.io/v0.1/apps/${br_app_slug}/builds/${build_slug}/log\" -H \"accept: application/json\" -H \"Authorization: ${br_auth_token}\""
    local result_json number_log_chunk last_log_chunk release_build_time debug_build_time number_of_tests testing_time
    local version_major version_minor version_revision aws_path unit_test_file_name unit_test_file_ext
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local BLUE='\033[1;34m'
    local NC='\033[0m'

    result_json=$(eval $curl_command)
    number_log_chunk=$(echo "$result_json" | jq '.log_chunks | length')

    last_log_chunk=$(echo "$result_json" | jq .log_chunks[$((number_log_chunk - 2))].chunk | tr -d "\"")$(echo "$result_json" | jq .log_chunks[$((number_log_chunk - 1))].chunk | tr -d "\"")

    release_build_time=$(echo -e "$last_log_chunk" | grep "Build App Release" | awk -F'[|]' '{print $4}' | sed 's/ min//g' | tr -d ' ' | awk -F'.' '{printf "%d.%d min (00:%02d:%02d)", $1,$2,$1,($2*6)}')
    debug_build_time=$(echo -e "$last_log_chunk" | grep "Build App Debug" | awk -F'[|]' '{print $4}' | sed 's/ min//g' | tr -d ' ' | awk -F'.' '{printf "%d.%d min (00:%02d:%02d)", $1,$2,$1,($2*6)}')

    version_major=$(echo "$version_name" | sed 's/[^0-9.]//g' | cut -d'.' -f1)
    version_minor=$(echo "$version_name" | sed 's/[^0-9.]//g' | cut -d'.' -f2)
    version_revision=$(echo "$version_name" | sed 's/[^0-9.]//g' | cut -d'.' -f3)

    if [ -z "$version_revision" ]; then
        version_revision="0"
    fi

    unit_test_file_ext=".zip"
    unit_test_file_name="UnitTest_$version_major.$version_minor.$version_revision"
    aws_path="$bucket/$version_major.$version_minor/report/$unit_test_file_name$unit_test_file_ext"

    aws s3 cp "$aws_path" "$unit_test_file_name$unit_test_file_ext"
    tar xzf "$unit_test_file_name$unit_test_file_ext"
    mv testDebugUnitTest "$unit_test_file_name"

    number_of_tests=$(grep id=\"tests\" -A1 "$unit_test_file_name"/index.html | tail -n1 | awk -F'[<|>]' '{print $3}')
    testing_time=$(grep id=\"duration\" -A1 "$unit_test_file_name"/index.html | tail -n1 | awk -F'[<|>]' '{print $3}' | awk -F'[m.s]' '{ h=0; m=$1; s=$2; if ( $3 > 30 ) s=s+1 ; printf "%02d:%02d:%02d", h,m,s }')

    echo -e "${BLUE}Versão:${NC} ${RED}$version_name${NC} ${GREEN}($br_wf_name - $build_slug)${NC}"
    echo -e "${BLUE}Data da Build:${NC} ${GREEN}$build_start_date${NC}"
    echo -e "${BLUE}Tempo Release Build:${NC} ${GREEN}$release_build_time${NC}"
    echo -e "${BLUE}Tempo Debug Build:${NC} ${GREEN}$debug_build_time${NC}"
    echo -e "${BLUE}Nro de Testes Unitários:${NC} ${GREEN}$number_of_tests${NC}"
    echo -e "${BLUE}Tempo de Execução dos Testes Unitários:${NC} ${GREEN}$testing_time${NC}"
}

function ios_message {
    local version
    local today=$(date "+%d/%m/%Y")
    local last_day=$(date -v +7d "+%d/%m/%Y")
    local yes_no_option="SIM NÃO EXIT"

    read -p 'Qual a release: ' version

    local line_1="Pessoal, versão \`$version\` do iOS liberada para 1% da base.\n"
    local line_2="Liberado dia $today com previsão para 100% dia $last_day.\n"
    local line_3="O Phased Release do iOS acontece de forma automática a partir da liberação na loja seguindo a regra:\n"
    local rollout="Dia 1 - 1%\nDia 2 - 2%\nDia 3 - 5%\nDia 4 - 10%\nDia 5 - 20%\nDia 6 - 50%\nDia 7 - 100%\n"
    local link_ref="Referência: https://help.apple.com/app-store-connect/#/dev3d65fcee1"


    echo -e "\n\n"$line_1$line_2$line_3$rollout$link_ref

    echo -e "\n\nDeseja copiar a mensagem para o clipboard?"
    select opt in $yes_no_option; do
        if [ ! -z $opt ]; then
            if [ $opt == "EXIT" ]; then
                return 0
            elif [ $opt == "SIM" ]; then
                echo -e $line_1$line_2$line_3$rollout$link_ref | pbcopy
                echo -e "\nMessage copied to Clipboard!"
                break
            else
                echo -e "\nOk, see you later ;)"
                break
            fi
        fi
    done
}

function changeJava {
    local java_options="Java8 Java11 EXIT"

    echo "Select a Java version:"
    select opt in $java_options
    do
        if  [ ! -z $opt ]; then
            if [ "$opt" == "EXIT" ]; then
                return 0
            elif [ "$opt" == "Java11" ]; then
                export JAVA_HOME=$(/usr/libexec/java_home -v 11.0.10)
                break
            else
                export JAVA_HOME=$(/usr/libexec/java_home -v 1.8.0_241)
                break
            fi
        fi
    done
}
