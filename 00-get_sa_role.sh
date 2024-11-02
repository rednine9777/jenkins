#!/bin/bash

# Clear any previous output
clear

# 서비스 어카운트 이름과 네임스페이스 입력받기
echo "Enter the ServiceAccount name:"
read sa_name
if [ -z "$sa_name" ]; then
    echo "No ServiceAccount name provided. Exiting..."
    exit 1
fi

echo "Enter the Namespace (press enter to use current namespace):"
read namespace
if [ -z "$namespace" ]; then
    namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}')
    echo "No Namespace provided. Using current namespace: $namespace"
fi

# 입력받은 값 출력
echo "ServiceAccount: '$sa_name'"
echo "Namespace: '$namespace'"

# 정보 조회 시작
echo "Checking roles and bindings for ServiceAccount '$sa_name' in namespace '$namespace'..."

# ClusterRoleBindings 조회
echo -e "\n========== ClusterRole list =========="
clusterrole_bindings=$(kubectl get clusterrolebindings -o json | jq -r \
    --arg sa_name "$sa_name" --arg namespace "$namespace" \
    '.items[] | select(.subjects[]? | .kind == "ServiceAccount" and .name == $sa_name and .namespace == $namespace) | .metadata.name + "," + .roleRef.name')

if [ -z "$clusterrole_bindings" ]; then
    echo "No ClusterRoleBindings found."
else
    for cr_binding in $clusterrole_bindings; do
        cr_binding_name=$(echo "$cr_binding" | cut -d',' -f1)
        cr_name=$(echo "$cr_binding" | cut -d',' -f2)
        echo -e "\nClusterRoleBinding: $cr_binding_name"
        echo "ClusterRole: $cr_name"
        # ClusterRole 권한 출력
        kubectl get clusterrole "$cr_name" -o yaml | yq eval '.rules' - || echo "ClusterRole $cr_name not found"
    done
fi

# RoleBindings 조회
echo -e "\n========== Role list =========="
role_bindings=$(kubectl get rolebindings -n "$namespace" -o json | jq -r \
    --arg sa_name "$sa_name" \
    '.items[] | select(.subjects[]? | .kind == "ServiceAccount" and .name == $sa_name) | .metadata.name + "," + .roleRef.name')

if [ -z "$role_bindings" ]; then
    echo "No RoleBindings found in namespace $namespace."
else
    for role_binding in $role_bindings; do
        role_binding_name=$(echo "$role_binding" | cut -d',' -f1)
        role_name=$(echo "$role_binding" | cut -d',' -f2)
        echo -e "\nRoleBinding: $role_binding_name"
        echo "Role: $role_name (in namespace $namespace)"
        # Role 권한 출력
        kubectl get role "$role_name" -n "$namespace" -o yaml | yq eval '.rules' - || echo "Role $role_name not found in namespace $namespace"
    done
fi
