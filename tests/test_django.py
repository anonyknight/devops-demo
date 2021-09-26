import pytest
from selenium import webdriver


@pytest.fixture()
def chrome_driver():
    chrome_options = webdriver.ChromeOptions()
    driver = webdriver.Remote("http://localhost:4444/wd/hub", options=chrome_options)
    yield driver
    driver.quit()


def test_visit_site(chrome_driver):
    chrome_driver.get('http://web:8000/')
    assert chrome_driver.title == "The install worked successfully! Congratulations!"