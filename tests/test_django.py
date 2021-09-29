import pytest
from selenium import webdriver


@pytest.fixture()
def chrome_driver():
    chrome_options = webdriver.ChromeOptions()
    driver = webdriver.Remote("http://localhost:4444/wd/hub", options=chrome_options)
    yield driver
    driver.quit()


def test_visit_site(chrome_driver):
    chrome_driver.get('http://web:8080/admin')
    assert chrome_driver.title == "Log in | Django site admin"