## Distributed Load Testing Using GKE and Locust

This is the sample code for the [Distributed load testing using Google Kubernetes Engine](https://cloud.google.com/architecture/distributed-load-testing-using-gke) tutorial.

## 使用方式
找到 locust/docker-images/locust-tasks 底下的tasks.py，將需要測試的腳本貼上。測試腳本的撰寫。腳本撰寫的教學[可見此連結](https://docs.locust.io/en/stable/writing-a-locustfile.html)

進入 locust/docker-image 下，進入gen-locust-k8s-manifests.sh，修改對應的環境變數。修改後，執行產生部署的k8s-manifests/
```
bash gen-locust-k8s-manifests.sh
```
再使用skaffold產生對應的部署檔案，就可以部署分散式測試了：
```
skaffold init
skaffold run
```


