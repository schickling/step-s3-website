#!/bin/sh
set -e;

init_wercker_environment_variables() {
  if [ ! -n "$WERCKER_S3_WEBSITE_S3_KEY" ]
  then
    fail 'missing or empty option s3.key, please check wercker.yml';
  fi

  if [ ! -n "$WERCKER_S3_WEBSITE_S3_SECRET" ]
  then
    fail 'missing or empty option s3.secret, please check wercker.yml';
  fi

  if [ ! -n "$WERCKER_S3_WEBSITE_S3_BUCKET" ]
  then
    fail 'missing or empty option s3.bucket, please check wercker.yml';
  fi
}

install_java() {
  sudo apt-get update;
  sudo apt-get install -y default-jre;
}

install_ruby() {
  sudo apt-get update;
  sudo apt-get install -y ruby1.9.1 rubygems1.9.1;
}

install_s3_website() {
  gem install s3_website;
}

change_source_dir() {
  SOURCE_DIR="$WERCKER_ROOT/$WERCKER_S3SYNC_SOURCE_DIR";
  if cd "$SOURCE_DIR" ;
  then
    debug "changed directory $SOURCE_DIR, content is: $(ls -l)";
  else
    fail "unable to change directory to $SOURCE_DIR";
  fi
}

create_s3_website_yml_file() {

  cat > s3_website.yml <<EOF
s3_id: $WERCKER_S3_WEBSITE_S3_KEY
s3_secret: $WERCKER_S3_WEBSITE_S3_SECRET
s3_bucket: $WERCKER_S3_WEBSITE_S3_BUCKET
s3_endpoint: eu-west-1
max_age: 300
gzip:
- .html
- .css
- .js
- .svg
- .ttf
- .eot
- .woff
exclude_from_upload:
- .DS_Store
EOF

}

info 'setup step';

init_wercker_environment_variables;
install_java;
install_ruby;
install_s3_website;
change_source_dir;
create_s3_website_yml_file;

info 'starting synchronisation';

set +e;
CMD="s3_website push --site .";
debug "$CMD";
CMD_OUTPUT=$($CMD);

if [[ $? -ne 0 ]]; then
  warning $CMD_OUTPUT;
  fail 's3_website push failed';
else
  success 'finished synchronisation';
fi
set -e;
