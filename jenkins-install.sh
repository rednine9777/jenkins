#!/usr/bin/env bash

# Jenkins 세션 및 시간 설정
jkopt1="--sessionTimeout=1440"
jkopt2="--sessionEviction=86400"
jvopt1="-Duser.timezone=Asia/Seoul"

# Jenkins Configuration as Code (JCasC) 설정 경로 및 다운로드 서비스 검증 설정
jvopt2="-Dcasc.jenkins.config=https://raw.githubusercontent.com/rednine9777/jenkins/main/jenkins-config/jenkins-config.yaml"
jvopt3="-Dhudson.model.DownloadService.noSignatureCheck=true"

# Helm을 사용하여 Jenkins 설치
helm install jenkins edu/jenkins --version 2.7.1 \
--set persistence.existingClaim=jenkins \
--set master.adminPassword=admin \
--set master.nodeSelector."kubernetes\.io/hostname"=kind-control-plane \
--set master.tolerations[0].key=node-role.kubernetes.io/master \
--set master.tolerations[0].effect=NoSchedule \
--set master.tolerations[0].operator=Exists \
--set master.tolerations[1].key=node-role.kubernetes.io/control-plane \
--set master.tolerations[1].effect=NoSchedule \
--set master.tolerations[1].operator=Exists \
--set master.runAsUser=1000 \
--set master.runAsGroup=1002 \
--set master.fsGroup=1002 \
--set master.tag=2.249.3-lts-centos7 \
--set master.serviceType=LoadBalancer \
--set master.servicePort=80 \
--set master.jenkinsOpts="$jkopt1 $jkopt2" \
--set master.javaOpts="$jvopt1 $jvopt2 $jvopt3"
