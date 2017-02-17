#!/usr/bin/env bash

set -eou pipefail

command -v jq &> /dev/null || {
  echo -e "Cannot find jq in PATH!\nhttps://stedolan.github.io/jq/"
  exit 1
}

repository_domain=.
repository_path=atlas/vagrant/boxes
repository_url=${repository_domain}/${repository_path}
repository_filepath=./${repository_path}

versions_json='{
  "version": $version,
  "providers": [{
    "name": "virtualbox",
    "url": $box,
    "checksum_type": "sha256",
    "checksum": $checksum
    }]
}'

metadata_json='{
  "name": "jla/centos6-lxc",
  "description": "all your box belong to us",
  "versions": []
}'

while read box; do
  name=$(basename ${box} .box)
  version=$(echo ${name} | awk -F- '{print $3}')

  # derive checksum from pre-generated file if present, otherwise compute
  checksum_file=${repository_filepath}/${name}.sha256
  checksum="unknown" && [[ -f "${checksum_file}" ]] \
	             && checksum=$(awk '{print $1}' ${checksum_file}) \
                     || checksum=$(sha256sum ${box} | awk '{print $1}')

  # generate json snippet for box version
  json=$(jq -nc --arg box "${repository_url}/${name}.box" \
	        --arg version "${version}" \
	        --arg checksum "${checksum}" \
		"$versions_json")

  # append box details snippet to json metadata
  metadata_json=$(echo ${metadata_json} | jq ".versions |= .+ [${json}]")
done <<< "$(ls ${repository_filepath}/*.box)"

echo ${metadata_json} | jq . 
