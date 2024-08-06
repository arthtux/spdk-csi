#!/bin/bash

# list in creation order
files=(driver config-map nodeserver-config-map secret controller-rbac node-rbac controller node storageclass snapshotclass)

if [ "$1" = "teardown" ]; then
	# delete in reverse order
	for ((i = ${#files[@]} - 1; i >= 0; i--)); do
		echo "=== kubectl delete -f $(dirname "$0")/${files[i]}.yaml"
		kubectl delete -f "$(dirname "$0")/${files[i]}.yaml"
	done
else
	for ((i = 0; i <= ${#files[@]} - 1; i++)); do
		echo "=== kubectl apply -f $(dirname "$0")/${files[i]}.yaml"
		kubectl apply -f "$(dirname "$0")/${files[i]}.yaml"
	done
fi
