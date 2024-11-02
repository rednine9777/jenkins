#!/bin/bash

# EXTERNAL-IP 입력 받기
read -p "Enter the EXTERNAL-IP: " EXTERNAL_IP

# 몇 번 curl을 보낼지 입력 받기 (기본값은 무한 반복)
read -p "How many times would you like to send curl requests? Enter a number or press Enter for continuous: " COUNT

# 입력한 횟수만큼 curl 요청 보내기
if [[ "$COUNT" =~ ^[0-9]+$ ]]; then
  # 숫자가 입력된 경우 해당 횟수만큼 curl 실행
  for ((i = 1; i <= COUNT; i++)); do
    echo "Request #$i"
    curl http://$EXTERNAL_IP
    echo
  done
elif [[ -z "$COUNT" || "$COUNT" == "c" ]]; then
  # 'c' 또는 엔터 입력 시 무한 반복
  echo "Starting continuous requests. Press Ctrl+C to stop."
  while true; do
    curl http://$EXTERNAL_IP
    echo
    sleep 1 # 1초 대기
  done
else
  echo "Invalid input. Please enter a valid number or press Enter for continuous."
fi

