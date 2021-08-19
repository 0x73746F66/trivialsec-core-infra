import glob
import logging
import csv
import pathlib
from trivialsec.models.cwe import CWE
from trivialsec.models.cve import CVE


logger = logging.getLogger(__name__)
logging.basicConfig(
    format='%(asctime)s - %(name)s - [%(levelname)s] %(message)s',
    level=logging.INFO
)
DATAFILE_DIR = 'datafiles/cwe'

def current_and_next(items):
    for item, next_item in zip(items, items[1:]):
        yield item, next_item

def process_csv(filename :str):
    cwe_file = pathlib.Path(filename)
    if not cwe_file.is_file():
        logger.info(filename)
        return

    cr = csv.DictReader(cwe_file.read_text().splitlines(), delimiter=',')
    my_list = list(cr)
    for row in my_list:
        desc = []
        for desc_field in ['Description', 'Extended Description']:
            if row.get(desc_field):
                desc.append(row.get(desc_field))
        notes = row.get('Notes')
        if notes.startswith('::'):
            for current, next_item in current_and_next(notes.split(':')):
                if current == 'NOTE':
                    desc.append(next_item.strip())
        background_details = row.get('Background Details')
        if background_details.startswith('::'):
            desc.append(background_details.split('::')[1])

        alternate_terms = row.get('Alternate Terms')
        if alternate_terms.startswith('::'):
            for current, next_item in current_and_next(alternate_terms.split(':')):
                if current == 'DESCRIPTION':
                    desc.append(next_item.strip())

        introduced = []
        mode_introduced = row.get('Modes Of Introduction')
        if mode_introduced.startswith(':'):
            for current, next_item in current_and_next(mode_introduced.split(':')):
                if current == 'PHASE':
                    introduced.append(f'During {next_item.strip()};')
                if current == 'NOTE':
                    introduced.append(next_item.strip())

        impact = []
        common_consequences = row.get('Common Consequences')
        if common_consequences.startswith('::'):
            for current, next_item in current_and_next(common_consequences.split(':')):
                if current == 'IMPACT' and 'other' not in next_item.lower():
                    impact.append(next_item.strip())
                if current == 'NOTE':
                    impact.append(next_item.strip())
            if not impact:
                for current, next_item in current_and_next(common_consequences.split(':')):
                    if current == 'SCOPE':
                        impact.append(next_item.strip())

        detection = []
        detection_methods = row.get('Detection Methods')
        if detection_methods.startswith('::'):
            for current, next_item in current_and_next(detection_methods.split(':')):
                if current == 'DESCRIPTION':
                    detection.append(next_item.strip())

        mitigation = []
        potential_mitigations = row.get('Potential Mitigations')
        if potential_mitigations.startswith('::'):
            for current, next_item in current_and_next(potential_mitigations.split(':')):
                if current == 'DESCRIPTION':
                    mitigation.append(next_item.strip())

        platform = []
        platform_windows = False
        platform_macos = False
        platform_unix = False
        platform_language = []
        applicable_platforms = row.get('Applicable Platforms')
        if 'windows' in applicable_platforms.lower():
            platform_windows = True
        if 'macos' in applicable_platforms.lower():
            platform_macos = True
        if 'unix' in applicable_platforms.lower():
            platform_unix = True

        if applicable_platforms.startswith(':'):
            for current, next_item in current_and_next(applicable_platforms.split(':')):
                if 'independent' in next_item.lower():
                    continue
                if current in ['TECHNOLOGY CLASS', 'TECHNOLOGY NAME'] and ' IP' not in next_item and 'other' not in next_item.lower():
                    platform.append(next_item.strip())
                if current in ['LANGUAGE NAME', 'LANGUAGE CLASS'] and 'other' not in next_item.lower() and 'interpreted' not in next_item.lower():
                    platform_language.append(next_item.strip())

        cves = set()
        observed_examples = row.get('Observed Examples')
        if observed_examples.startswith('::'):
            for current, next_item in current_and_next(observed_examples.split(':')):
                if current == 'REFERENCE':
                    cves.add(CVE(cve_id=next_item.strip()))

        cwe = CWE(
            cwe_id=f"CWE-{row.get('CWE-ID')}",
            name=row.get('Name'),
            description='\n'.join(desc),
            status=row.get('Status'),
            introduced=None if not introduced else '\n'.join(introduced).replace(';\n', '; '),
            detection=None if not detection else '\n'.join(detection),
            impact=None if not impact else '\n'.join(impact),
            mitigation=None if not mitigation else '\n'.join(mitigation),
            platform=None if not platform else ','.join(platform),
            platform_windows=platform_windows,
            platform_macos=platform_macos,
            platform_unix=platform_unix,
            platform_language=None if not platform_language else ','.join(platform_language),
        )
        cwe.persist()
        logger.info(cwe.cwe_id)
        for cve in cves:
            cwe.add_cve(cve)
            logger.info(cve.cve_id)

if __name__ == "__main__":
    for pathname in glob.glob(f"{DATAFILE_DIR}/*.csv"):
        process_csv(pathname)
