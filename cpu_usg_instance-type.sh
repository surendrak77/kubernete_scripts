#!/bin/bash

set -e

KUBECTL="kubectl"
NODES=$($KUBECTL get nodes --no-headers -o custom-columns=NAME:.metadata.name)

function usage() {
	local node_count=0
	local total_percent_cpu=0
	local total_percent_mem=0
	local readonly nodes=$@

	for n in $nodes; do
		local requests=$($KUBECTL describe node $n | grep -A 2  "Request" | tail -n -1)
		local requests_mem=$($KUBECTL describe node $n | grep -A 3  "Request" | tail -n -1)
		local instances_type=$($KUBECTL describe node $n |grep -A 1 "Labels"| tail -n -1|sed 's/\<beta.kubernetes.io\>//g'| tr -d '/')
		local percent_cpu=$(echo $requests | awk -F "[()%]" '{print $2}')
		local percent_mem=$(echo $requests_mem | awk -F "[()%]" '{print $2}')
		local instances_type=$(echo $instances_type | awk -F "[()%]" '{print $1}')
		echo "$n: ${percent_cpu}% CPU, ${percent_mem}% memory,${instances_type}"

		node_count=$((node_count + 1))
		total_percent_cpu=$((total_percent_cpu + percent_cpu))
		total_percent_mem=$((total_percent_mem + percent_mem))
	done

	local readonly avg_percent_cpu=$((total_percent_cpu / node_count))
	local readonly avg_percent_mem=$((total_percent_mem / node_count))

	echo "Average usage: ${avg_percent_cpu}% CPU, ${avg_percent_mem}% memory."
}

usage $NODES





