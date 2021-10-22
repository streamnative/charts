import requests
import json
import os
host = os.getenv("STREAMNATIVE_CONSOLE_BACKEND_URL")
loginPath = "/cloud-manager/login"
loginData = {
    "username": os.getenv("VAULT_SUPER_USER_NAME"),
    "password": os.getenv("VAULT_SUPER_USER_PASSWORD"),
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
if (os.getenv("KOP_SERVICE_URL")):
    instanceData["service"] = json.dumps({"kopServiceUrl": os.getenv("KOP_SERVICE_URL")})
instancePath = "/cloud-manager/v1/instances"
instanceResponse = requests.post(url = host + instancePath, data = json.dumps(instanceData), headers=headers)
if (instanceResponse.ok):
    print("Add environment success")
else:
    print("Add environment failed" + instanceResponse.text)