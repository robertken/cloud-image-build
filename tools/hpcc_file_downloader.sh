#!/bin/sh
#!/bin/sh

HPCC_VERSION="7.6.48"

WORKING_DIR="../hpcc-systems"
wget=/usr/bin/wget

if [ ! -x "$wget" ]; then
  echo "ERROR: wget not found..." >&2
  exit 1
fi

mkdir -p ../hpcc-systems/bionic_${HPCC_VERSION}

wget -P ../hpcc-systems/bionic_${HPCC_VERSION}/ https://d2wulyp08c6njk.cloudfront.net/releases/CE-Candidate-${HPCC_VERSION}/bin/platform/hpccsystems-platform-community_${HPCC_VERSION}-1bionic_amd64.deb
wget -P ../hpcc-systems/bionic_${HPCC_VERSION}/ https://d2wulyp08c6njk.cloudfront.net/releases/CE-Candidate-${HPCC_VERSION}/bin/plugins/hpccsystems-plugin-couchbaseembed_${HPCC_VERSION}-1bionic_amd64.deb
wget -P ../hpcc-systems/bionic_${HPCC_VERSION}/ https://d2wulyp08c6njk.cloudfront.net/releases/CE-Candidate-${HPCC_VERSION}/bin/plugins/hpccsystems-plugin-javaembed_${HPCC_VERSION}-1bionic_amd64.deb
wget -P ../hpcc-systems/bionic_${HPCC_VERSION}/ https://d2wulyp08c6njk.cloudfront.net/releases/CE-Candidate-${HPCC_VERSION}/bin/plugins/hpccsystems-plugin-kafka_${HPCC_VERSION}-1bionic_amd64.deb
wget -P ../hpcc-systems/bionic_${HPCC_VERSION}/ https://d2wulyp08c6njk.cloudfront.net/releases/CE-Candidate-${HPCC_VERSION}/bin/plugins/hpccsystems-plugin-memcached_${HPCC_VERSION}-1bionic_amd64.deb
wget -P ../hpcc-systems/bionic_${HPCC_VERSION}/ https://d2wulyp08c6njk.cloudfront.net/releases/CE-Candidate-${HPCC_VERSION}/bin/plugins/hpccsystems-plugin-mysqlembed_${HPCC_VERSION}-1bionic_amd64.deb
wget -P ../hpcc-systems/bionic_${HPCC_VERSION}/ https://d2wulyp08c6njk.cloudfront.net/releases/CE-Candidate-${HPCC_VERSION}/bin/plugins/hpccsystems-plugin-redis_${HPCC_VERSION}-1bionic_amd64.deb
wget -P ../hpcc-systems/bionic_${HPCC_VERSION}/ https://d2wulyp08c6njk.cloudfront.net/releases/CE-Candidate-${HPCC_VERSION}/bin/plugins/hpccsystems-plugin-rembed_${HPCC_VERSION}-1bionic_amd64.deb
wget -P ../hpcc-systems/bionic_${HPCC_VERSION}/ https://d2wulyp08c6njk.cloudfront.net/releases/CE-Candidate-${HPCC_VERSION}/bin/plugins/hpccsystems-plugin-spark_${HPCC_VERSION}-1bionic_amd64.deb
wget -P ../hpcc-systems/bionic_${HPCC_VERSION}/ https://d2wulyp08c6njk.cloudfront.net/releases/CE-Candidate-${HPCC_VERSION}/bin/plugins/hpccsystems-plugin-sqlite3embed_${HPCC_VERSION}-1bionic_amd64.deb
wget -P ../hpcc-systems/bionic_${HPCC_VERSION}/ https://d2wulyp08c6njk.cloudfront.net/releases/CE-Candidate-${HPCC_VERSION}/bin/plugins/hpccsystems-plugin-sqs_${HPCC_VERSION}-1bionic_amd64.deb
wget -P ../hpcc-systems/bionic_${HPCC_VERSION}/ https://d2wulyp08c6njk.cloudfront.net/releases/CE-Candidate-${HPCC_VERSION}/bin/plugins/hpccsystems-plugin-v8embed_${HPCC_VERSION}-1bionic_amd64.deb