import pytest
from selenium import webdriver
import json
import os

@pytest.fixture()
def chrome_driver():
    chrome_options = webdriver.ChromeOptions()
    driver = webdriver.Remote("http://localhost:4444/wd/hub", options=chrome_options)
    yield driver
    driver.quit()

@pytest.fixture()
def instance_ip():
    TERRAFORM_OUTPUT = os.path.abspath(os.path.join(__file__,os.pardir,"server_info.json"))
    assert os.path.exists(TERRAFORM_OUTPUT), "Cannot find the server ip."
    with open(TERRAFORM_OUTPUT) as f:
        json_output = json.load(f)
    return json_output["instance_ip_addr"]["value"]
        

def test_site_name(chrome_driver, instance_ip):
    chrome_driver.get(f'http://{instance_ip}:8000/')
    assert chrome_driver.title == "GianDocs"