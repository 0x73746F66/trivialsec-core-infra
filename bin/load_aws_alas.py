from xml.etree.ElementTree import Element, ElementTree
import re
import logging
import pathlib
import requests
from datetime import datetime
from requests.exceptions import ConnectTimeout, ReadTimeout
from retry.api import retry
from bs4 import BeautifulSoup as bs
from trivialsec.models.cve import CVE
from trivialsec.models.cve_reference import CVEReference
from trivialsec.models.cve_remediation import CVERemediation
from trivialsec.helpers.config import config


session = requests.Session()
logger = logging.getLogger(__name__)
logging.basicConfig(
    format='%(asctime)s - %(name)s - [%(levelname)s] %(message)s',
    level=logging.INFO
)
PROXIES = None
if config.http_proxy or config.https_proxy:
    PROXIES = {
        'http': f'http://{config.http_proxy}',
        'https': f'https://{config.https_proxy}'
    }
AMZ_DATE_FORMAT = "%a, %d %b %Y %H:%M:%S %Z"
USER_AGENT = 'trivialsec.com'
BASE_URL = 'https://alas.aws.amazon.com/'
DATAFILE_DIR = 'datafiles/feeds/alas'
ALAS_PATTERN = r"(ALAS\-\d{4}\-\d*)"

@retry((ConnectTimeout, ReadTimeout), tries=10, delay=30, backoff=5)
def fetch_url(url :str):
    logger.info(url)
    resp = session.get(
        url,
        proxies=PROXIES,
        headers={
            'User-Agent': config.user_agent,
            'Referer': BASE_URL
        },
        timeout=10
    )
    if resp.status_code != 200:
        logger.info(f'{resp.status_code} {url}')
        return None
    return resp.text

def html_to_dict(html_content :str):
    result = {}
    soup = bs(html_content, 'html.parser')
    issue_correction = soup.find(id='issue_correction')
    if issue_correction is not None:
        result['issue_correction'] = issue_correction.get_text(' ', strip=True).replace('Issue Correction: ', '')
    issue_overview = soup.find(id='issue_overview')
    if issue_overview is not None:
        result['issue_overview'] = issue_overview.get_text(' ', strip=True).replace('Issue Overview: ', '')
    affected_packages = soup.find(id='affected_packages')
    if affected_packages is not None:
        result['affected_packages'] = affected_packages.get_text(' ', strip=True).replace('Affected Packages: ', '')
    new_packages = soup.find(id='new_packages')
    if new_packages is not None:
        result['new_packages'] = new_packages.pre.get_text('\n', strip=False)
    return result

def download_xml_file(url :str, local_file :str):
    raw_file = pathlib.Path(local_file)
    if not raw_file.is_file():
        raw = fetch_url(url)
        if raw is None:
            logger.info(f'Failed to save {local_file}')
            return None
        raw_file.write_text(raw)
    if not raw_file.is_file():
        logger.info('failed to read xml file')
        return None
    tree = ElementTree()
    tree.parse(local_file)
    return tree.find('.//channel')

def parse_xml(channel :Element):
    results = []
    for elem in channel:
        if elem.tag != 'item':
            continue
        data = {}
        for item in elem:
            if item.tag == 'description':
                data['cve_refs'] = list(filter(None, [x.strip() for x in item.text.split(',')]))
            else:
                data[item.tag] = item.text
        data['vendor_id'] = None
        matches = re.search(ALAS_PATTERN, data['title'])
        if matches is not None:
            data['vendor_id'] = matches.group(1)
        results.append(data)

    return results

def save_alas(data :dict):
    source = 'Amazon Linux AMI Security Bulletin'
    for cve_ref in data.get('cve_refs', []):
        if cve_ref == 'CVE-PENDING':
            continue
        cve = CVE()
        cve.cve_id = cve_ref
        if not cve.exists():
            cve.assigner = 'Unknown'
            cve.title = data["title"]
            cve.description = f'{source}\n{data.get("issue_overview", "")}'.strip()
            cve.published_at = datetime.strptime(data['pubDate'], AMZ_DATE_FORMAT)
            cve.last_modified = datetime.strptime(data['lastBuildDate'], AMZ_DATE_FORMAT)
            cve.persist()
        cve_remediation = CVERemediation()
        cve_remediation.cve_id = cve_ref
        cve_remediation.type = 'patch'
        cve_remediation.source = source
        cve_remediation.source_id = data['vendor_id']
        cve_remediation.source_url = data['link']
        cve_remediation.description = f"{data.get('issue_correction', '')}\n\n{data.get('new_packages', '')}".strip()
        cve_remediation.published_at = datetime.strptime(data['lastBuildDate'], AMZ_DATE_FORMAT)
        cve_remediation.persist()
        if 'cve.mitre.org' in data['link']:
            continue
        cve_reference = CVEReference()
        cve_reference.cve_id = cve_ref
        cve_reference.url = data['link']
        cve_reference.name = data['vendor_id']
        cve_reference.source = source
        cve_reference.tags = data.get('affected_packages')
        cve_reference.persist()

def main(feeds :dict):
    for feed_file, feed_url in feeds.items():
        channel = download_xml_file(feed_url, feed_file)
        if not isinstance(channel, Element):
            continue
        alas_data = parse_xml(channel)
        for data in reversed(alas_data):
            html_content = fetch_url(data['link'])
            if html_content:
                data |= html_to_dict(html_content)
            save_alas(data)

if __name__ == "__main__":
    main({
        f'{DATAFILE_DIR}-amzl1.xml': f'{BASE_URL}alas.rss',
        f'{DATAFILE_DIR}-amzl2.xml': f'{BASE_URL}AL2/alas.rss'
    })
