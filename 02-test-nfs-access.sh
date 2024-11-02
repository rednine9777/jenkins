#!/bin/bash

# YAML 파일 생성
cat << 'YAML' > test-nfs-access.yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-nfs-access
spec:
  containers:
    - name: test-nfs-access
      image: busybox
      command:
        - "sh"
        - "-c"
        - |
          mkdir -p /mnt && \
          mount -o nolock 172.18.0.1:/nfs_shared/jenkins /mnt && \
          echo "NFS test file" > /mnt/testfile.txt && \
          echo "Created file:" && ls -l /mnt && \
          echo "Contents of testfile.txt:" && cat /mnt/testfile.txt && \
          rm /mnt/testfile.txt && \
          echo "Deleted testfile.txt" && ls -l /mnt && \
          sleep 10
      securityContext:
        runAsUser: 0
        privileged: true
  restartPolicy: Never
YAML

# YAML 파일 적용하여 Pod 생성
kubectl apply -f test-nfs-access.yaml

# Pod가 준비될 때까지 대기
echo "Waiting for Pod to be ready..."
kubectl wait --for=condition=Ready pod/test-nfs-access --timeout=60s

# Pod 로그 출력
echo "Logs from test-nfs-access:"
kubectl logs test-nfs-access

# Pod 및 YAML 파일 삭제
echo "Cleaning up..."
kubectl delete -f test-nfs-access.yaml
rm -f test-nfs-access.yaml

