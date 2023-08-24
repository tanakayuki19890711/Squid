#!/bin/bash

while true; do
  yum -y install php
  sleep 20  # 5秒ごとにリクエストを送信する場合
  yum -y erase php
done
