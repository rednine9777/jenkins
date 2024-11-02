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
          echo "NFS 테스트 완료" && \
          sleep 10
      securityContext:
        runAsUser: 0
        privileged: true
  restartPolicy: Never
YAML

# YAML 파일 적용하여 Pod 생성
echo "✅ Pod 생성 중..."
kubectl apply -f test-nfs-access.yaml

# Pod가 준비될 때까지 대기
echo "⏳ Pod가 준비될 때까지 대기 중..."
kubectl wait --for=condition=Ready pod/test-nfs-access --timeout=60s
if [ $? -ne 0 ]; then
  echo "❌ Pod 준비 실패. 종료합니다."
  exit 1
fi

# Pod 로그 출력
echo "📝 Pod 로그 확인:"
kubectl logs test-nfs-access

# 작업 성공 여부 확인
if kubectl logs test-nfs-access | grep -q "NFS 테스트 완료"; then
  echo "✅ NFS 테스트 성공!"
else
  echo "❌ NFS 테스트 실패. 로그를 확인하세요."
fi

# Pod 및 YAML 파일 삭제
echo "🧹 정리 작업 중..."
kubectl delete -f test-nfs-access.yaml
rm -f test-nfs-access.yaml

