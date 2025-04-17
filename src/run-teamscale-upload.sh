#!/bin/bash

if [[ "$OS" == "Windows" ]]; then
  curl -L https://github.com/cqse/teamscale-upload/releases/download/v2.9.6/teamscale-upload-windows.zip -o teamscale-upload.zip
  unzip teamscale-upload.zip;
else
  wget -O teamscale-upload.zip https://github.com/cqse/teamscale-upload/releases/download/v2.9.6/teamscale-upload-linux.zip;
  unzip teamscale-upload.zip
fi
chmod +x teamscale-upload;

# mandatory arguments that have to be always present
ARGS=( "--server" "$SERVER" "--project" "$PROJECT" "--user" "$USER" "--accesskey" "$ACCESSKEY" "--partition" "$PARTITION" )

# optional parameters. We only use them if they have been set
if [ -n "$FORMAT" ]; then
  ARGS+=( "--format" "$FORMAT" )
fi
if [ -n "$REVISION" ]; then
  ARGS+=( "--commit" "$REVISION" )
fi
if [ -n "$REPOSITORY" ]; then
  ARGS+=( "--repository" "$REPOSITORY" )
fi
if [ -n "$BRANCH_AND_TIMESTAMP" ]; then
  ARGS+=( "--branch-and-timestamp" "$BRANCH_AND_TIMESTAMP" )
fi
if [[ "$MOVE_TO_LAST_COMMIT" == "true" ]]; then
  ARGS+=( "--move-to-last-commit" )
fi
if [ -n "$MESSAGE" ]; then
  ARGS+=( "--message" "${MESSAGE}" )
fi
if [ -n "$INPUT" ]; then
  ARGS+=( "--input" "${INPUT}" )
fi
if [[ "$INSECURE" == "true" ]]; then
  ARGS+=( "--insecure" )
fi
if [ -n "$TRUSTED_KEYSTORE" ]; then
  ARGS+=( "--trusted-keystore" "${TRUSTED_KEYSTORE}" )
fi

# Transforming the space separated parameter into multiple single-value parameters. This is necessary, since it is not
# possible in a Github Action to specify the same parameter multiple times as we do for teamscale-upload.
for line in $APPEND_TO_MESSAGE; do
  ARGS+=( "--append-to-message" "$line" )
done

# Transforming the space separated filenames into an array of filenames
read -r -a FILES_ARRAY <<< "$FILES"
ARGS+=( "${FILES_ARRAY[@]}" )

if [[ "$STACKTRACE" == "true" ]]; then
  ARGS+=( "--stacktrace" )
fi
if [ -n "$TIMEOUT" ]; then
  ARGS+=( "--timeout" "${TIMEOUT}" )
fi

./teamscale-upload "${ARGS[@]}"
