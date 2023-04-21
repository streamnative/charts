import requests
import json
import os
host = os.getenv("STREAMNATIVE_CONSOLE_BACKEND_URL")
loginPath = "/cloud-manager/login"
username = os.getenv("VAULT_SUPER_USER_NAME")
password = os.getenv("VAULT_SUPER_USER_PASSWORD")
if not username or not password:
    username = os.getenv("SUPER_USER_NAME")
    password = os.getenv("SUPER_USER_PASSWORD")
loginData = {
    "username": username,
    "password": password,
    "type":"pulsar-vault-userpass"
}
headers = {
    "Content-Type": "application/json"
}
loginResponse = requests.post(url = host + loginPath, data=json.dumps(loginData), headers=headers)
token = loginResponse.headers['token']
headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer " + token
}

instanceData = {"name": os.getenv("INSTANCE_NAME"), "broker": os.getenv("WEB_SERVICE_URL")}
serviceData = {}
if (os.getenv("KOP_SERVICE_URL")):
    serviceData["kopServiceUrl"] = os.getenv("KOP_SERVICE_URL")
if (os.getenv("FLINK_SERVICE_URL")):
    serviceData["flinkServiceUrl"] = os.getenv("FLINK_SERVICE_URL")
instanceData["service"] = json.dumps(serviceData)

instancePath = "/cloud-manager/v1/instances"
instanceResponse = requests.post(url = host + instancePath, data = json.dumps(instanceData), headers=headers)
if (instanceResponse.ok and 'Add environment success' in instanceResponse.text):
    print("Add environment success")
else:
    print("Add environment failed " + instanceResponse.text)
    exit(-1)