#!/bin/bash

indices_list="/root/temp/indices_list.txt"
indices_month="jun_2020"

user_input="xpto"
user_input_pass="otpx"
input_host="host1"
input_host_port="9200"

user_output="xpto"
user_output_pass="otpx"
output_host="host2"
output_host_port="9243"


while IFS= read -r line
do
  echo "INDEX $line" | tee -a output_"$indices_month".txt

    docker run --rm -v /root/temp/backup:/data taskrabbit/elasticsearch-dump \
    --input=https://"$user_input":"$user_input_pass"@"$input_host":"$input_host_port"/"$line" \
    --tlsAuth \
    --input-cert=/data/es1.crt \
    --input-key=/data/es1.p8.key \
    --input-ca=/data/ca.crt \
    --output=https://"$user_output":"$user_output_pass"@"$output_host":"$output_host_port"/"$line" \
    --output-ca=/data/CAcert.pem \
    --type=mapping | tee -a output_"$indices_month".txt

    if [ $? -eq 0 ]
       then
          echo "SUCCESS copying index mapping ->  $line" >> log_"$indices_month".txt
    else
         echo "ERROR copying index mapping ->  $line" >> log_"$indices_month".txt
         fi

    docker run --rm -v /root/temp/backup:/data taskrabbit/elasticsearch-dump \
    --input=https://"$user_input":"$user_input_pass"@"$input_host":"$input_host_port"/"$line" \
    --tlsAuth \
    --input-cert=/data/es1.crt \
    --input-key=/data/es1.p8.key \
    --input-ca=/data/ca.crt \
    --limit=10000 \
    --output=https://"$user_output":"$user_output_pass"@"$output_host":"$output_host_port"/"$line" \
    --output-ca=/data/CAcert.pem \
    --type=data | tee -a output_"$indices_month".txt

    if [ $? -eq 0 ]
       then
          echo "SUCCESS copying index data -> $line" >> log_"$indices_month".txt
    else
         echo "ERROR copying index data -> $line" >> log_"$indices_month".txt
         fi

done < "$indices_list"