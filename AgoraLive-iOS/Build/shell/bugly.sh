Project_Path=$1
Product_Path=$2

APP_KEY=$3
APP_ID=$4

Current_Path=`pwd`

cd ${Project_Path}

Project_Name=`find . -name *.xcodeproj | awk -F "[/.]" '{print $(NF-1)}'`

echo "Project_Name" ${Project_Name}

App_Version=`sed -n '/MARKETING_VERSION/{s/MARKETING_VERSION = //;s/;//;s/^[[:space:]]*//;p;q;}' ./${Project_Name}.xcodeproj/project.pbxproj`
BundleId=`sed -n '/PRODUCT_BUNDLE_IDENTIFIER/{s/PRODUCT_BUNDLE_IDENTIFIER = //;s/;//;s/^[[:space:]]*//;p;q;}' ./${Project_Name}.xcodeproj/project.pbxproj`

echo "App_Version" ${App_Version}
echo "BundleId" ${BundleId}

cd ${Current_Path}

cd ${Product_Path}

for I in `ls`
do
    echo "product ls" $I
    if [[ $I =~ "archive" ]] 
    then
    ArchiveFolder=$I
    fi
done

cd ${ArchiveFolder}/dSYMs

echo `pwd`

for I in `ls`
do
    echo "dsym ls" $I
    rm -f upload.zip

    if [[ $I =~ "archive" ]] 
    then
    zip -q -r upload.zip $I
    curl -k "https://api.bugly.qq.com/openapi/file/upload/symbol?app_key=${APP_KEY}&app_id=${APP_ID}" --form "api_version=1" --form "app_id=${APP_ID}" --form "app_key=${APP_KEY}" --form "symbolType=2"  --form "bundleId=${BundleId}" --form "productVersion=${App_Version}" --form "fileName=upload.zip" --form "file=@upload.zip" --verbose
    fi
done

