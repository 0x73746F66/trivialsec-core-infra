import json
import gzip
import urllib.request
import logging
import pathlib
import requests
from datetime import datetime
from trivialsec.models.cve import CVE
from trivialsec.models.cve_cpe import CPE
from trivialsec.models.cve_reference import CVEReference
from trivialsec.models.cwe import CWE
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
USER_AGENT = 'trivialsec.com'
BASE_URL = 'https://nvd.nist.gov'
DATAFILE_DIR = 'datafiles/cve'

def download_gzip(url, out_file):
    try:
        with urllib.request.urlopen(url) as response:
            with gzip.GzipFile(fileobj=response) as uncompressed:
                file_content = uncompressed.read()
        with open(out_file, 'wb') as f:
            f.write(file_content)
            return True

    except Exception as e:
        logger.exception(e)

    return False

def download_cve_file(year :int):
    jsongz_url = f'{BASE_URL}/feeds/json/cve/1.1/nvdcve-1.1-{year}.json.gz'
    json_file_path = f'{DATAFILE_DIR}/nvdcve-1.1-{year}.json'

    json_file = pathlib.Path(json_file_path)
    if not json_file.is_file():
        logger.info(jsongz_url)
        if not download_gzip(jsongz_url, json_file_path):
            logger.info(f'Failed to save {json_file_path}')

    if not json_file.is_file():
        logger.info('failed to read json file')
        return False

    data = json.loads(json_file.read_text())
    for item in data['CVE_Items']:
        cve = CVE()
        cve.cve_id = item['cve']['CVE_data_meta']['ID']
        cve.hydrate()
        cve.assigner = item['cve']['CVE_data_meta']['ASSIGNER']
        description = []
        for desc in item['cve']['description']['description_data']:
            description.append(desc['value'])
        cve.description = '\n'.join(description)
        cvss_version = cve.cvss_version
        vector = cve.vector
        base_score = cve.base_score
        exploitability_score = cve.exploitability_score
        impact_score = cve.impact_score
        if 'baseMetricV2' in item['impact'] and 'cvssV2' in item['impact']['baseMetricV2']:
            original_vector = CVE.vector_to_dict(cve.vector, 2) if cve.vector is not None else {}
            if original_vector.get('CVSS') != '2.0':
                original_vector = {}
            vd = CVE.vector_to_dict(item['impact']['baseMetricV2']['cvssV2']['vectorString'], 2)
            cvss_version = vd.get('CVSS', '2.0')
            vd['E'] = original_vector.get('E', vd['E'])
            vd['RL'] = original_vector.get('RL', vd['RL'])
            vd['RC'] = original_vector.get('RC', vd['RC'])
            base_score = item['impact']['baseMetricV2']['cvssV2']['baseScore']
            exploitability_score = item['impact']['baseMetricV2']['exploitabilityScore']
            impact_score = item['impact']['baseMetricV2']['impactScore']
            vector = CVE.dict_to_vector(vd, 2)
        if 'baseMetricV3' in item['impact'] and 'cvssV3' in item['impact']['baseMetricV3']:
            original_vector = CVE.vector_to_dict(cve.vector, 3) if cve.vector is not None else {}
            if original_vector.get('CVSS') not in ['3.0', '3.1']:
                original_vector = {}
            vd = CVE.vector_to_dict(item['impact']['baseMetricV3']['cvssV3']['vectorString'], 3)
            cvss_version = vd.get('CVSS', '3.1')
            vd['E'] = original_vector.get('E', vd['E'])
            vd['RL'] = original_vector.get('RL', vd['RL'])
            vd['RC'] = original_vector.get('RC', vd['RC'])
            base_score = item['impact']['baseMetricV3']['cvssV3']['baseScore']
            exploitability_score = item['impact']['baseMetricV3']['exploitabilityScore']
            impact_score = item['impact']['baseMetricV3']['impactScore']
            vector = CVE.dict_to_vector(vd, 3)

        cve.cvss_version = cvss_version
        cve.vector = vector
        cve.base_score = base_score
        cve.exploitability_score = exploitability_score
        cve.impact_score = impact_score
        cve.published_at = datetime.fromisoformat(item['publishedDate'].replace('T', ' ').replace('Z', ''))
        cve.last_modified = datetime.fromisoformat(item['lastModifiedDate'].replace('T', ' ').replace('Z', ''))
        try:
            cve.persist()
        except Exception as ex:
            logger.exception(ex)
            print(json.dumps(item, default=str))
            break
        for problemtype_data in item['cve']['problemtype']['problemtype_data']:
            for cwe_item in problemtype_data['description']:
                if not cwe_item.get('value').startswith('CWE-'):
                    continue
                cwe = CWE()
                cwe.cwe_id = cwe_item.get('value')
                cwe.add_cve(cve)

        for ref in item['cve']['references']['reference_data']:
            if 'cve.mitre.org' in ref.get('url'):
                continue
            cve_ref = CVEReference(
                cve_id=cve.cve_id,
                url=ref.get('url'),
                name=ref.get('name'),
                source=ref.get('refsource'),
                tags=','.join(ref.get('tags')),
            )
            if not cve_ref.exists(['cve_id', 'url']):
                cve_ref.persist(False)

        for configuration_node in item['configurations']['nodes']:
            for cpe_match in configuration_node['cpe_match']:
                CPE(
                    cve_id=cve.cve_id,
                    cpe=cpe_match.get('cpe23Uri'),
                    version_end_excluding=cpe_match.get('versionEndExcluding'),
                ).persist()

def process_all(start_year :int = 2002):
    year = start_year or 2002
    while year <= datetime.utcnow().year:
        download_cve_file(year)
        year += 1

if __name__ == "__main__":
    process_all()
