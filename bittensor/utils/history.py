import bittensor
from typing import Mapping, List
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.chrome.options import Options


def get_address_history_from_taostats(coldkey) -> Mapping[str, List[str]]:
    endpoint = bittensor.__network_explorer_map__["taostats"]["endpoint"]
    url = f"{endpoint}/account/{coldkey}#transfers"

    chrome_options = Options()
    # Disable for crawler debugging
    chrome_options.add_argument("--headless=new")
    driver = webdriver.Chrome(options=chrome_options)

    bittensor.logging.info("Crawling...")
    driver.get(url)

    # Wait for page to load
    WebDriverWait(driver, 10).until(
        lambda driver: driver.execute_script("return document.readyState") == "complete"
    )

    # Find transfers table, it will be present if id `#transfers` is the suffix to the http url.
    elements = driver.find_elements("css selector", '[data-test="transfers-table"]')

    # Get `transfers-table`, n x 6 columns
    td_elements = elements[0].find_elements("css selector", "td")
    table_data = [el.text for el in td_elements]

    driver.quit()

    assert (
        len(table_data) % 6 == 0
    ), "TaoStats Transfers parser received unexpected html elements."

    acc = {
        "extrinsic": [],
        "from": [],
        "direction": [],
        "to": [],
        "amount": [],
        "time": [],
    }
    for i in range(0, len(table_data), 6):
        acc["extrinsic"].append(table_data[i])
        acc["from"].append(table_data[i + 1])
        acc["direction"].append(table_data[i + 2])
        acc["to"].append(table_data[i + 3])
        acc["amount"].append(table_data[i + 4])
        acc["time"].append(table_data[i + 5])
    return acc
