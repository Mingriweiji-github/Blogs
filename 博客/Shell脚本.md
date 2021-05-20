# Shell脚本

## Linux基本命令

#### 终端：

- `查看当前时间：date`
- `查看日历： cal`
- `查看当年日历： cal 2022`

- 命令别名配置功能： (alias): alias l='luck'



- iOS build版本 自动增加: `xcrun agvtool next-version -all`

- 获取当前脚本所在目录: script_dir="$( cd "$( dirname "$0"  )" && pwd  )"

#### [fir.im打包](https://www.jianshu.com/p/645fedd4f47b)

```shell
  # 工程根目录
  project_dir=$script_dir
  
  # 时间
  DATE=`date '+%Y%m%d_%H%M%S'`
  # 指定输出导出文件夹路径
  export_path="~/Desktop/Package/$scheme_name-$DATE"
  
  # 进入项目工程目录
  cd ${project_dir}
  
  # 指定输出文件目录不存在则创建
  if [ -d "$export_path" ] ; then
      echo $export_path
  else
      mkdir -pv $export_path
  fi
  
  # 判断编译的项目类型是workspace还是project
  PROJECT_TYPE="workspace"
  BUILD_TYPE="xcworkspace"
  if $is_workspace ; then
  PROJECT_TYPE="workspace"
  BUILD_TYPE="xcworkspace"
  else
  PROJECT_TYPE="project"
  BUILD_TYPE="xcodeproj"
  fi
  
  # 编译前清理工程
  xcodebuild clean -${PROJECT_TYPE} ${workspace_name}.${BUILD_TYPE} \
                   -scheme ${scheme_name} \
                   -configuration ${build_configuration}
  
  echo '///-----------'
  echo '/// 正在编译工程:'${development_mode}
  echo '///-----------'${PROJECT_TYPE} ${workspace_name}.${BUILD_TYPE}
  
  xcodebuild archive -${PROJECT_TYPE} ${workspace_name}.${BUILD_TYPE} \
                     -scheme ${scheme_name} \
                     -configuration ${build_configuration} \
                     -archivePath ${export_archive_path}  -quiet || exit
  echo '///--------'
  echo '/// 编译完成'
  echo '///--------'
  echo ''
  
  echo "------------------------------------------------------"
  
  
```

  

## Bugly - dSYM_upload_production.sh



```shell
# 在Xcode工程中执行
function runInXcode(){
    echo "Uploading dSYM to Bugly in Xcode ..."

    echo "Info.Plist : ${INFOPLIST_FILE}"
		# bundle
    BUNDLE_VERSION=$(/usr/libexec/PlistBuddy -c 'Print CFBundleVersion' "${INFOPLIST_FILE}")
    # version
    BUNDLE_SHORT_VERSION=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "${INFOPLIST_FILE}")

    # 组装Bugly默认识别的版本信息(格式为CFBundleShortVersionString(CFBundleVersion), 例如: 1.0(1))
    if [ ! "${CUSTOMIZED_APP_VERSION}" ]; then
        BUGLY_APP_VERSION="${BUNDLE_SHORT_VERSION}(${BUNDLE_VERSION})"
    else
        BUGLY_APP_VERSION="${CUSTOMIZED_APP_VERSION}"
    fi

    echo "--------------------------------"
    echo "Prepare application information."
    echo "--------------------------------"

    echo "Product Name: ${PRODUCT_NAME}"
    echo "Bundle Identifier: ${BUNDLE_IDENTIFIER}"
    echo "Version: ${BUNDLE_SHORT_VERSION}"
    echo "Build: ${BUNDLE_VERSION}"

    echo "Bugly App ID: ${BUGLY_APP_ID}"
    echo "Bugly App key: ${BUGLY_APP_KEY}"
    echo "Bugly App Version: ${BUGLY_APP_VERSION}"

    echo "--------------------------------"
    echo "Check the arguments ..."

    ##检查模拟器编译是否允许上传符号
    if [ "$EFFECTIVE_PLATFORM_NAME" == "-iphonesimulator" ]; then
    if [ $UPLOAD_SIMULATOR_SYMBOLS -eq 0 ]; then
        exitWithMessage "Warning: Build for simulator and skipping to upload. \nYou can modify 'UPLOAD_SIMULATOR_SYMBOLS' to 1 in the script." 0
    fi
    fi

    ##检查是否是Release模式编译
    if [ "${CONFIGURATION=}" == "Debug" ]; then
    if [ $UPLOAD_DEBUG_SYMBOLS -eq 0 ]; then
        exitWithMessage "Warning: Build for debug mode and skipping to upload. \nYou can modify 'UPLOAD_DEBUG_SYMBOLS' to 1 in the script." 0
    fi
    fi

    ##检查是否Archive操作
    if [ $UPLOAD_ARCHIVE_ONLY -eq 1 ]; then
    if [[ "$TARGET_BUILD_DIR" == *"/Archive"* ]]; then
        echo "Archive the package"
    else
        exitWithMessage "Warning: Build for NOT Archive mode and skipping to upload. \nYou can modify 'UPLOAD_ARCHIVE_ONLY' to 0 in the script." 0
    fi
    fi

    #
    run ${BUGLY_APP_ID} ${BUGLY_APP_KEY} ${BUNDLE_IDENTIFIER} ${BUGLY_APP_VERSION} ${DWARF_DSYM_FOLDER_PATH} ${BUILD_DIR}/BuglySymbolTemp ${UPLOAD_DSYM_ONLY}
}

# 根据Xcode的环境变量判断是否处于Xcode环境
INFO_PLIST_FILE="${INFOPLIST_FILE}"

```

