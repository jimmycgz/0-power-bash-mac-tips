export TARGET_FILE=terraform.tfvars
sed -i '' '/^anthos_bm_version/s/=.*$/= \"1.8.4\"/' $TARGET_FILE
sed -i '' "/^project_id/s/=.*$/= \"${PROJECT_ID}\"/" $TARGET_FILE
sed -i '' "/^region/s/=.*$/= \"${REGION}\"/" $TARGET_FILE
sed -i '' "/^zone/s/=.*$/= \"${ZONE}\"/" $TARGET_FILE
sed -i '' "/^credentials_file/s/=.*$/= \"cred\/${KEY_FILE}\"/" $TARGET_FILE
sed -i '' "/^network/s/=.*$/= \"${NETWORK}\"/" $TARGET_FILE
sed -i '' "/^tags/s/=.*$/= \[\"http-server\"\,\"https-server\"\,\"${NAME_Prefix}\-anthos\"\]/" $TARGET_FILE