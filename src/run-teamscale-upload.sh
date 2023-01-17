#!/bin/bash

if [[ "$OS" == "Windows" ]]; then
  wget -O teamscale-upload.zip https://github.com/cqse/teamscale-upload/releases/download/v2.6.0/teamscale-upload-windows.zip;
else
  wget -O teamscale-upload.zip https://github.com/cqse/teamscale-upload/releases/download/v2.6.0/teamscale-upload-linux.zip;
fi
unzip teamscale-upload.zip
chmod +x teamscale-upload;

# mandatory arguments that have to be always present
ARGS=( "--server" "$SERVER" "--project" "$PROJECT" "--user" "$USER" "--partition" "$PARTITION" "--accesskey" "$ACCESSKEY" "--format" "$FORMAT" )

# optional parameters. We only use them if they have been set
if [ -n "$REVISION" ]; then
  ARGS+=( "--commit" "$REVISION" )
fi
if [ -n "$REPOSITORY" ]; then
  ARGS+=( "--repository" "$REPOSITORY" )
fi
if [ -n "$BRANCH_AND_TIMESTAMP" ]; then
  ARGS+=( "--branch-and-timestamp" "$BRANCH_AND_TIMESTAMP" )
fi
if [ -n "$MESSAGE" ]; then
  ARGS+=( "--message" "${MESSAGE}" )
fi
if [ -n "$INPUT" ]; then
  ARGS+=( "--input" "${INPUT}" )
fi
if [ -n "$TRUSTED_KEYSTORE" ]; then
  ARGS+=( "--trusted-keystore" "${TRESTED_KEYSTORE}" )
fi

# Transforming the space separated parameter into multiple single-value parameters. This is necessary, since it is not
# possible in a Github Action to specify the same parameter multiple times as we do for teamscale-upload.
for linenumber in $APPEND_TO_MESSAGE; do
  ARGS+=( "--append-to-message" "$linenumber" )
done
if [[ "$MOVE_TO_LAST_COMMIT" == "true" ]]; then
  ARGS+=( "--move-to-last-commit" )
fi
if [[ "$STACKTRACE" == "true" ]]; then
  ARGS+=( "--stacktrace" )
fi
if [[ "$INSECURE" == "true" ]]; then
  ARGS+=( "--insecure" )
fi

# Transforming the space separated filenames into an array of filenames
read -r -a FILES_ARRAY <<< "$FILES"
ARGS+=( "${FILES_ARRAY[@]}" )

./teamscale-upload "${ARGS[@]}"
