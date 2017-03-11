#!/bin/sh
set -e;

init_wercker_environment_variables() {
  if [ ! -n "$WERCKER_S3_WEBSITE_KEY" ]
  then
    fail 'missing or empty option key, please check wercker.yml';
  fi

  if [ ! -n "$WERCKER_S3_WEBSITE_SECRET" ]
  then
    fail 'missing or empty option secret, please check wercker.yml';
  fi

  if [ ! -n "$WERCKER_S3_WEBSITE_BUCKET" ]
  then
    fail 'missing or empty option bucket, please check wercker.yml';
  fi

  if [ ! -n "$WERCKER_S3_WEBSITE_REGION" ]
  then
    fail 'missing or empty option region, please check wercker.yml';
  fi
}

install_java() {
  sudo apt-get update;
  sudo apt-get install -y default-jre;
}

install_ruby() {
  sudo apt-get update;
  sudo apt-get install -y ruby rubygems;
}

install_s3_website() {
  sudo gem install s3_website;
}

change_source_dir() {
  SOURCE_DIR="$WERCKER_ROOT/$WERCKER_S3_WEBSITE_SOURCE_DIR";
  if cd "$SOURCE_DIR" ;
  then
    debug "changed directory $SOURCE_DIR, content is: $(ls -l)";
  else
    fail "unable to change directory to $SOURCE_DIR";
  fi
}

create_s3_website_yml_file() {

  cat > s3_website.yml <<EOF
s3_id: $WERCKER_S3_WEBSITE_KEY
s3_secret: $WERCKER_S3_WEBSITE_SECRET
s3_bucket: $WERCKER_S3_WEBSITE_BUCKET
s3_endpoint: $WERCKER_S3_WEBSITE_REGION
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
- .git
- .gitignore
- .md
- .yml
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

s3_website cfg apply --headless
s3_website push --site .
