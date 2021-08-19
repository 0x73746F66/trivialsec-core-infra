import glob
import json
import logging
import pathlib
from random import randint
from time import sleep
from datetime import datetime, timedelta
import requests
from retry.api import retry
from requests.exceptions import ConnectTimeout, ReadTimeout
from trivialsec.models.cve import CVE
from trivialsec.models.cve_remediation import CVERemediation
from trivialsec.models.cve_reference import CVEReference
from trivialsec.helpers.config import config


session = requests.Session()
logger = logging.getLogger(__name__)
logging.basicConfig(
    format='%(asctime)s - %(name)s - [%(levelname)s] %(message)s',
    level=logging.INFO
)
BASE_URL = 'https://exchange.xforce.ibmcloud.com'
DATAFILE_DIR = 'datafiles/xforce/vulnerabilities'
PROXIES = None
SOURCE = 'IBM X-Force Exchange'
if config.http_proxy or config.https_proxy:
    PROXIES = {
        'http': f'http://{config.http_proxy}',
        'https': f'https://{config.https_proxy}'
    }
v2_0 = {
    'E': {
        'High': 'E:H',
        'Functional': 'E:F',
        'Proof-of-Concept': 'E:POC',
        'Unproven': 'E:U',
    },
    'RL': {
        'Official Fix': 'RL:OF',
        'Temporary Fix': 'RL:TF',
        'Workaround': 'RL:W',
        'Unavailable': 'RL:U',
    },
    'RC': {
        'Unconfirmed': 'RC:UC',
        'Uncorroborated': 'RC:UR',
        'Confirmed': 'RC:C',
    }
}

def process_file(filename :str):
    xforce_file = pathlib.Path(filename)
    if not xforce_file.is_file():
        return
    raw_text = xforce_file.read_text()
    xforce_data = json.loads(raw_text)
    for cve_ref in xforce_data.get('stdcode', []):
        cve_ref = f"{cve_ref.upper().replace('CVE ', 'CVE-').replace('‑', '-').replace('–', '-')}"
        if not cve_ref.startswith('CVE-'):
            continue
        try:
            cve = CVE()
            cve.cve_id=cve_ref
            if cve.exists():
                cve.hydrate()
                cve.temporal_score = xforce_data.get('temporal_score')
                cve.persist()
            else:
                cve.assigner = 'Unknown'
                cve.title = xforce_data['title']
                cve.description = xforce_data['description']
                if xforce_data['cvss']['version'] == '2.0':
                    vd = CVE.vector_to_dict(xforce_data['cvss_vector'], 2)
                    cve.vector = CVE.dict_to_vector(vd, 2)
                    cve.cvss_version = vd.get('CVSS', xforce_data['cvss']['version'])
                if xforce_data['cvss']['version'] in ['3.0', '3.1']:
                    vd = CVE.vector_to_dict(xforce_data['cvss_vector'], 3)
                    cve.vector = CVE.dict_to_vector(vd, 3)
                    cve.cvss_version = vd.get('CVSS', xforce_data['cvss']['version'])
                cve.base_score = xforce_data['risk_level']
                cve.temporal_score = xforce_data.get('temporal_score')
                cve.reported_at = xforce_data['reported'].replace('T', ' ').replace('Z', '')
                cve.last_modified = cve.reported_at
                cve.persist()

            for ref in xforce_data['references']:
                if 'cve.mitre.org' in ref['link_target']:
                    continue
                reference = CVEReference()
                reference.cve_id = cve_ref
                reference.name = ref['link_name']
                reference.url = ref['link_target']
                reference.source = SOURCE
                reference.tags = xforce_data['tagname']
                reference.persist()

            cve_remedy = CVERemediation()
            cve_remedy.cve_id = cve_ref
            cve_remedy.type = 'advisory'
            cve_remedy.source = SOURCE
            cve_remedy.source_id = xforce_data['xfdbid']
            cve_remedy.source_url = f"https://exchange.xforce.ibmcloud.com/vulnerabilities/{xforce_data['xfdbid']}"
            cve_remedy.description = xforce_data['remedy']
            cve_remedy.published_at = xforce_data['reported'].replace('T', ' ').replace('Z', '')
            cve_remedy.persist()

        except Exception as ex:
            logger.exception(ex)
            logger.error(f'cve ref {cve_ref} xfdbid {xforce_data["xfdbid"]}')

@retry((ConnectTimeout, ReadTimeout), tries=10, delay=30, backoff=5)
def query_single(ref_id :int):
    api_url = f'{BASE_URL}/api/vulnerabilities/{ref_id}'
    logger.info(api_url)
    resp = session.get(
        api_url,
        proxies=PROXIES,
        headers={
            'x-ui': "XFE",
            'User-Agent': config.user_agent,
            'origin': BASE_URL
        },
        timeout=10
    )
    if resp.status_code != 200:
        logger.info(f'{resp.status_code} {api_url}')

    return resp.text

def xforce_cvss_vector(obj :dict):
    if 'cvss' not in obj:
        return None
    try:
        vector = ''
        if obj['cvss']['version'] in ['1.0', '2.0']:
            if 'access_vector' in obj['cvss']:
                vector += f"AV:{obj['cvss']['access_vector'][:1].upper()}/"
            if 'access_complexity' in obj['cvss']:
                vector += f"AC:{obj['cvss']['access_complexity'][:1].upper()}/"
            if 'authentication' in obj['cvss']:
                vector += f"Au:{obj['cvss']['authentication'][:1].upper()}/"
            if 'confidentiality_impact' in obj['cvss']:
                vector += f"C:{obj['cvss']['confidentiality_impact'][:1].upper()}/"
            if 'integrity_impact' in obj['cvss']:
                vector += f"I:{obj['cvss']['integrity_impact'][:1].upper()}/"
            if 'availability_impact' in obj['cvss']:
                vector += f"A:{obj['cvss']['availability_impact'][:1].upper()}/"
        if obj['cvss']['version'] in ['3.0', '3.1']:
            if 'access_vector' in obj['cvss']:
                vector += f"AV:{obj['cvss']['access_vector'][:1].upper()}/"
            if 'access_complexity' in obj['cvss']:
                vector += f"AC:{obj['cvss']['access_complexity'][:1].upper()}/"
            if 'privilegesrequired' in obj['cvss']:
                vector += f"PR:{obj['cvss']['privilegesrequired'][:1].upper()}/"
            if 'userinteraction' in obj['cvss']:
                vector += f"UI:{obj['cvss']['userinteraction'][:1].upper()}/"
            if 'scope' in obj['cvss']:
                vector += f"S:{obj['cvss']['scope'][:1].upper()}/"
            if 'confidentiality_impact' in obj['cvss']:
                vector += f"C:{obj['cvss']['confidentiality_impact'][:1].upper()}/"
            if 'integrity_impact' in obj['cvss']:
                vector += f"I:{obj['cvss']['integrity_impact'][:1].upper()}/"
            if 'availability_impact' in obj['cvss']:
                vector += f"A:{obj['cvss']['availability_impact'][:1].upper()}/"
            if 'exploitability' in obj:
                exploitability = obj['exploitability'][:1].upper()
                vector += 'E:X/' if exploitability not in ['U', 'P', 'F', 'H'] else f'E:{exploitability}/'
            if 'remediation_level' in obj['cvss']:
                remediation_level = obj['cvss']['remediation_level'][:1].upper()
                vector += 'RL:X/' if remediation_level not in ['O', 'T', 'W', 'U'] else f'RL:{remediation_level}/'
            if 'report_confidence' in obj:
                report_confidence = obj['report_confidence'][:1].upper()
                vector += 'RC:X' if report_confidence not in ['U', 'R', 'C'] else f'RC:{report_confidence}'
            vector = CVE.dict_to_vector(CVE.vector_to_dict(vector, 3), 3)
        if obj['cvss']['version'] == '2.0':
            if 'exploitability' in obj:
                vector += 'E:ND/' if obj['exploitability'] not in v2_0['E'] else f"{v2_0['E'][obj['exploitability']]}/"
            if 'remediation_level' in obj['cvss']:
                vector += 'RL:ND/' if obj['cvss']['remediation_level'] not in v2_0['RL'] else f"{v2_0['RL'][obj['cvss']['remediation_level']]}/"
            if 'report_confidence' in obj:
                vector += 'RC:ND' if obj['report_confidence'] not in v2_0['RC'] else f"{v2_0['RC'][obj['report_confidence']]}"
            vector = CVE.dict_to_vector(CVE.vector_to_dict(vector, 2), 2)
    except (KeyError, ValueError) as ex:
        logger.exception(ex)
        logger.error(f'vector {vector} obj {repr(obj)}')
        return None
    return vector

@retry((ConnectTimeout, ReadTimeout), tries=10, delay=30, backoff=5)
def query_bulk(start :datetime, end :datetime):
    response = None
    api_url = f'{BASE_URL}/api/vulnerabilities/fulltext?q=vulnerability&startDate={start.isoformat()}Z&endDate={end.isoformat()}Z'
    logger.info(api_url)
    resp = session.get(
        api_url,
        proxies=PROXIES,
        headers={
            'x-ui': "XFE",
            'User-Agent': config.user_agent,
            'origin': BASE_URL
        },
        timeout=10
    )
    if resp.status_code != 200:
        logger.info(f'{resp.status_code} {api_url}')
        return response

    raw = resp.text
    if raw is None or not raw:
        logger.info(f'empty response {api_url}')

    try:
        response = json.loads(raw)
    except json.decoder.JSONDecodeError as ex:
        logger.exception(ex)
        logger.info(raw)

    return response

@retry((ConnectTimeout, ReadTimeout), tries=10, delay=30, backoff=5)
def query_latest(limit :int = 200):
    response = []
    api_url = f'{BASE_URL}/api/vulnerabilities/?limit={limit}'
    resp = session.get(
        api_url,
        proxies=PROXIES,
        headers={
            'x-ui': "XFE",
            'User-Agent': config.user_agent,
            'origin': BASE_URL
        },
        timeout=10
    )
    if resp.status_code != 200:
        logger.info(f'{resp.status_code} {api_url}')
    raw = resp.text
    if raw is None or not raw:
        logger.info(f'empty response {api_url}')

    try:
        response = json.loads(raw)
    except json.decoder.JSONDecodeError as ex:
        logger.exception(ex)
        logger.info(raw)

    return response

def do_latest(limit :int = 200):
    for item in query_latest(limit):
        original_data = {}
        datafile_path = f"{DATAFILE_DIR}/{item['xfdbid']}.json"
        xforce_file = pathlib.Path(datafile_path)
        if xforce_file.is_file():
            original_data = json.loads(xforce_file.read_text())
            original_data |= item
            original_data['cvss_vector'] = xforce_cvss_vector(original_data)
            logger.info(f'UPDATE {datafile_path}')
            xforce_file.write_text(json.dumps(original_data, default=str, sort_keys=True))
            process_file(datafile_path)
            continue

        item['cvss_vector'] = xforce_cvss_vector(item)
        logger.info(f'NEW {datafile_path}')
        xforce_file.write_text(json.dumps(item, default=str, sort_keys=True))
        process_file(datafile_path)

def do_bulk(start :datetime, end :datetime) -> bool:
    resp = query_bulk(start, end)
    if resp is None:
        return False
    total_rows = int(resp.get('total_rows', 0))
    logger.info(f'total_rows {total_rows}')
    if total_rows == 0:
        logger.info(f'no data between {start} and {end}')
        return False
    if total_rows > 200:
        rows = []
        midday = datetime(start.year, start.month, start.day, 12)
        bulk1 = query_bulk(start, midday)
        if bulk1 is not None:
            rows += bulk1.get('rows', [])
        bulk2 = query_bulk(midday, end)
        if bulk2 is not None:
            rows += bulk2.get('rows', [])
    if total_rows <= 200:
        rows = resp.get('rows', [])
    for item in rows:
        datafile = f"{DATAFILE_DIR}/{item['xfdbid']}.json"
        original_data = {}
        xforce_file = pathlib.Path(datafile)
        if xforce_file.is_file():
            logger.debug(datafile)
            original_data = json.loads(xforce_file.read_text())
            original_data |= item
            original_data['cvss_vector'] = xforce_cvss_vector(original_data)
            xforce_file.write_text(json.dumps(original_data, default=str, sort_keys=True))
            process_file(datafile)
            continue

        logger.info(datafile)
        item['cvss_vector'] = xforce_cvss_vector(item)
        xforce_file.write_text(json.dumps(item, default=str, sort_keys=True))
        process_file(datafile)
    return True

def read_file(file_path :str):
    xforce_file = pathlib.Path(file_path)
    if not xforce_file.is_file():
        return None
    item = json.loads(xforce_file.read_text())
    original_data = json.loads(xforce_file.read_text())
    original_data |= item
    original_data['cvss_vector'] = xforce_cvss_vector(original_data)
    xforce_json = json.dumps(original_data, default=str, sort_keys=True)
    xforce_file.write_text(xforce_json)
    process_file(file_path)

def query_all_individually():
    next_id = 1
    while next_id < 206792:
        datafile = f"{DATAFILE_DIR}/{next_id}.json"
        original_data = {}
        xforce_file = pathlib.Path(datafile)
        if xforce_file.is_file():
            original_data = json.loads(xforce_file.read_text())
            original_data['cvss_vector'] = xforce_cvss_vector(original_data)
            xforce_file.write_text(json.dumps(original_data, default=str, sort_keys=True))
            process_file(datafile)
            next_id += 1
            continue

        try:
            raw = query_single(next_id)
            if raw is None:
                next_id += 1
                continue
            response = json.loads(raw)
            response['cvss_vector'] = xforce_cvss_vector(response)
            xforce_file.write_text(json.dumps(response, default=str, sort_keys=True))
            process_file(datafile)
        except json.decoder.JSONDecodeError as ex:
            logger.exception(ex)
            logger.info(raw)
        next_id += 1

def process_local():
    for pathname in glob.glob(f"{DATAFILE_DIR}/*.json"):
        read_file(pathname)

def main():
    now = datetime.utcnow()
    not_before = now - timedelta(days=3)
    end = datetime(now.year, now.month, now.day)
    start = end - timedelta(days=1)
    while start > not_before:
        logger.info(f'between {start} and {end}')
        do_bulk(start, end)
        end = start
        start = end - timedelta(days=1)
        sleep(randint(3,6))

if __name__ == "__main__":
    process_local()
    # main()
    # do_latest()
