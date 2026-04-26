#!/bin/bash

# ruleid: sbom-from-environment
cyclonedx-py environment

# ruleid: sbom-from-environment
cyclonedx-py environment --output-format json

# ruleid: sbom-from-environment
python -m cyclonedx_py environment

# ruleid: sbom-from-environment
python -m cyclonedx_py environment --output-format json --output sbom.json

# ok: sbom-from-environment
cyclonedx-py requirements requirements.txt

# ok: sbom-from-environment
python -m cyclonedx_py requirements requirements.txt
