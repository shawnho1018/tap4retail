from locust import HttpUser, task, between, events
import random


class QuickstartUser(HttpUser):
    wait_time = between(1, 5)


    @task(1)
    def get(self):
        self.client.get("/")
    @task(1)
    def titles(self):
        num = random.randint(1, 5)
        self.client.post("/post", data={"name": "sweet heart", "message": f"test message {num}"})

