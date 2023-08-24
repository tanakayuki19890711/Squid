# イメージのビルド
docker build -t cached_proxy .

# Squidイメージのビルド
docker-compose up -d 

# テストイメージのビルド
docker-compose run test 


# cronによる定期実行
cronjobの*を0~60に変更することで定期実行できる（分 時 日 月 曜日）
* * * * * /usr/sbin/squid -k rotate

      
