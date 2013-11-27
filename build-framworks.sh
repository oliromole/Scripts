#!/bin/sh

var_framework_names=(
"RECoreGraphics"
"RECoreLocation"
"REFoundation"
"REMapKit"
"REUIKit"
"RFFoundation"
"RFLibKern"
"RFMapKit"
"RFNetwork"
"RFObjC"
"RFQuartzCore"
"RFUIKit"
"RWObjC"
"RWSQLite"
"RWUUID"
)

var_separator="---"

var_framework_names2=(
"${var_separator}"
"RECoreGraphics"   #
"RECoreLocation"   #
"RFQuartzCore"     #
"RFObjC"           #
"RFLibKern"        #
"RWSQLite"         #
"RWObjC"           #

"${var_separator}"
"REFoundation"     # RWObjC
"REMapKit"         # RECoreLocation

"${var_separator}"
"REUIKit"          # REFoundation   RWObjC
"RFMapKit"         # RECoreGraphics RECoreLocation REFoundation    REMapKit RWObjC
"RWUUID"           # REFoundation   RWObjC

"${var_separator}"
"RFFoundation"     # REFoundation   RWObjC         RWUUID

"${var_separator}"
"RFUIKit"          # REFoundation   RFFoundation   RWObjC          RWUUID

"${var_separator}"
"RFNetwork"        # REFoundation   RFFoundation   RFUIKit  RWObjC
)

var_used_paranel_command=1
var_used_last_revision=1
var_preprocessor_definitions_enabled=1

var_frameworks_dir="${PWD}/Frameworks"
var_github_url="https://github.com"
var_github_account_name="oliromole"
var_github_account_url="${var_github_url}/${var_github_account_name}"

var_external_frameworks_dir="${PWD}/External Frameworks"

if [ -d "${var_frameworks_dir}/" ]
then
	rm -rf "${var_frameworks_dir}/"
fi

if [ -d "${var_external_frameworks_dir}/" ]
then
    rm -rf "${var_external_frameworks_dir}/"
fi

for var_framework_name in "${var_framework_names[@]}"
do
    var_github_framwork_url="${var_github_account_url}/${var_framework_name}"
    var_github_framwork_clone_url="${var_github_framwork_url}.git"
    var_framework_root="${var_frameworks_dir}/${var_framework_name}"
    var_framework_project_dir="${var_framework_root}/${var_framework_name}"

    var_command_git_clone_framwrowk="git clone"

    if [ "${var_used_last_revision}" -eq 1 ]
    then
        var_command_git_clone_framwrowk="${var_command_git_clone_framwrowk} --depth 1"
    fi

    var_command_git_clone_framwrowk="${var_command_git_clone_framwrowk} ${var_github_framwork_clone_url} ${var_framework_project_dir}"

    echo $var_command_git_clone_framwrowk

    if [ "${var_used_paranel_command}" -eq 1 ]
    then
        ${var_command_git_clone_framwrowk} &
    else
        ${var_command_git_clone_framwrowk}
    fi
done

wait

var_xcode_path="/Applications/Xcode.app"
var_xcode_bin_dir="${var_xcode_path}/Contents/Developer/usr/bin"

for var_framework_name in "${var_framework_names2[@]}"
do
    if [ "${var_framework_name}" == "${var_separator}" ]
    then
        wait
    else
        var_framework_root="${var_frameworks_dir}/${var_framework_name}"
        var_framework_project_dir="${var_framework_root}/${var_framework_name}"

        var_framework_project_path="${var_framework_project_dir}/${var_framework_name}.xcodeproj"
        var_framework_project_target="${var_framework_name}-UniversalFramework"
        var_framework_project_configuration="Release"
        var_framework_project_sdk=""
        var_framework_project_action="build"
        var_framework_project_build_dir=""
        var_framework_project_build_root=""
        var_framework_project_obj_root=""

        var_command_xcodebuild_build="${var_xcode_bin_dir}/xcodebuild"
        var_command_xcodebuild_build="${var_command_xcodebuild_build} -project ${var_framework_project_path}"
        var_command_xcodebuild_build="${var_command_xcodebuild_build} -target ${var_framework_project_target}"
        var_command_xcodebuild_build="${var_command_xcodebuild_build} -configuration ${var_framework_project_configuration}"

        if [ "${var_preprocessor_definitions_enabled}" -eq 1 ]
        then
            var_command_xcodebuild_build="${var_command_xcodebuild_build} PR_USE_PREPROCESSOR_DEFINITIONS=1"
        fi

        echo ${var_command_xcodebuild_build}

        if [ "${var_used_paranel_command}" -eq 1 ]
        then
            ${var_command_xcodebuild_build} &
        else
            ${var_command_xcodebuild_build}
        fi
    fi
done

wait

mkdir -p  "${var_external_frameworks_dir}"

for var_framework_name in "${var_framework_names[@]}"
do
    var_framework_root="${var_frameworks_dir}/${var_framework_name}"
    var_framework_project_dir="${var_framework_root}/${var_framework_name}"
    var_framework_path="${var_framework_project_dir}/${var_framework_name}.framework"

    var_external_frameworks_framework_path="${var_external_frameworks_dir}/${var_framework_name}.framework"

    if [ "${var_used_paranel_command}" -eq 1 ]
    then
        cp -R "${var_framework_path}/" "${var_external_frameworks_framework_path}/" &
    else
        cp -R "${var_framework_path}/" "${var_external_frameworks_framework_path}/"
    fi
done

wait

echo "---FINISHED---"
