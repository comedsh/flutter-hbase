#!/bin/bash
# 检查安装依赖包的版本，两种调用方式 `./flutter_check_pkg_version.sh` 或者 `./flutter_check_pkg_version.sh sycomponents`
# 前者显示所有的依赖关系，后者限制指定包的版本号
if [ "$1" != "" ]
then
    flutter pub deps | grep $1
else
    flutter pub deps
fi


