import pytest
from selenium import webdriver
import os
import re


@pytest.fixture()
def chrome_driver():
    chrome_options = webdriver.ChromeOptions()
    driver = webdriver.Remote("http://localhost:4444/wd/hub", options=chrome_options)
    yield driver
    driver.quit()


@pytest.fixture()
def instance_ip():
    TERRAFORM_OUTPUT = os.path.abspath(
        os.path.join(__file__, os.pardir, "server_ip.txt")
    )
    assert os.path.exists(TERRAFORM_OUTPUT), "Cannot find the server ip."
    with open(TERRAFORM_OUTPUT) as f:
        ip = f.read()
    pattern = re.compile(r"(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})")
    return pattern.search(ip)[0]


def test_site_name(chrome_driver, instance_ip):
    chrome_driver.get(f"http://{instance_ip}:8000/")
    assert chrome_driver.title == "GianDocs"
