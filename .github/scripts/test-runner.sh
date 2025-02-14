#!/bin/bash +x
OUTBOUND_AUTH_OIDC_REPO=identity-outbound-auth-oidc
OUTBOUND_AUTH_OIDC_REPO_CLONE_LINK=https://github.com/wso2-extensions/identity-outbound-auth-oidc.git
SCIM2_REPO=identity-inbound-provisioning-scim2
SCIM2_REPO_CLONE_LINK=https://github.com/wso2-extensions/identity-inbound-provisioning-scim2.git

echo ""
echo "=========================================================="
JDK_VERSION=${JDK_VERSION%/}
JAVA_8_HOME=${JAVA_8_HOME%/}
JAVA_11_HOME=${JAVA_11_HOME%/}
echo "    JAVA 8 Home: $JAVA_8_HOME"
echo "    JAVA 11 Home: $JAVA_11_HOME"
echo "    User Input: $JDK_VERSION"

echo "=========================================================="
echo "Cloning product-is"
echo "=========================================================="

git clone https://github.com/AmshikaH/wso2-product-is

  export JAVA_HOME=$JAVA_11_HOME
  cat pom.xml
  mvn clean install --batch-mode | tee mvn-build.log

  PR_BUILD_STATUS=$(cat mvn-build.log | grep "\[INFO\] BUILD" | grep -oE '[^ ]+$')
  PR_TEST_RESULT=$(sed -n -e '/\[INFO\] Results:/,/\[INFO\] Tests run:/ p' mvn-build.log)

  PR_BUILD_FINAL_RESULT=$(
    echo "==========================================================="
    echo "product-is BUILD $PR_BUILD_STATUS"
    echo "=========================================================="
    echo ""
    echo "$PR_TEST_RESULT"
  )

  PR_BUILD_RESULT_LOG_TEMP=$(echo "$PR_BUILD_FINAL_RESULT" | sed 's/$/%0A/')
  PR_BUILD_RESULT_LOG=$(echo $PR_BUILD_RESULT_LOG_TEMP)
  echo "::warning::$PR_BUILD_RESULT_LOG"

  PR_BUILD_SUCCESS_COUNT=$(grep -o -i "\[INFO\] BUILD SUCCESS" mvn-build.log | wc -l)
  if [ "$PR_BUILD_SUCCESS_COUNT" != "1" ]; then
    echo "PR BUILD not successfull. Aborting."
    echo "::error::PR BUILD not successfull. Check artifacts for logs."
    exit 1
  fi
fi

echo ""
echo "=========================================================="
echo "Build completed"
echo "=========================================================="
echo ""
