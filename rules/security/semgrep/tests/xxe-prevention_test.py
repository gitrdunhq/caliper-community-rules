"""
Semgrep test file for xxe-prevention (KIRBY-SEC-015).

Positive cases are annotated with:  # ruleid: xxe-prevention
Negative cases are annotated with:  # ok: xxe-prevention

Run with:
  semgrep --test rules/security/semgrep/xxe-prevention.yaml \
          rules/security/semgrep/tests/xxe-prevention_test.py
"""

import xml.etree.ElementTree
import xml.sax
import xml.dom.minidom
import defusedxml.ElementTree
import defusedxml.sax
import defusedxml.minidom
import lxml.etree
from lxml import etree

# Stub data for test fixtures — not real content, only used to satisfy name resolution.
xml_bytes = b"<root><item>value</item></root>"
xml_chunks = [b"<root>", b"<item>value</item>", b"</root>"]
handler = xml.sax.ContentHandler()

# ==================== POSITIVE CASES ====================
# These must each trigger the rule exactly once.

# Pattern 1a — etree.parse() on a file path (vulnerable by default, no XXE protection)
# ruleid: xxe-prevention
tree = xml.etree.ElementTree.parse("/uploads/config.xml")

# Pattern 1b — etree.fromstring() with externally supplied XML bytes
# ruleid: xxe-prevention
root = xml.etree.ElementTree.fromstring(xml_bytes)

# Pattern 1c — etree.iterparse() streaming parse on an untrusted file
# ruleid: xxe-prevention
for _event, _elem in xml.etree.ElementTree.iterparse("/uploads/feed.xml"):
    pass

# Pattern 1d — etree.fromstringlist() with untrusted chunked XML
# ruleid: xxe-prevention
root = xml.etree.ElementTree.fromstringlist(xml_chunks)

# Pattern 2a — xml.sax.parse() SAX parser vulnerable to XXE by default
# ruleid: xxe-prevention
xml.sax.parse("/uploads/report.xml", handler)

# Pattern 2b — xml.sax.parseString() with externally supplied XML content
# ruleid: xxe-prevention
xml.sax.parseString(xml_bytes, handler)

# Pattern 3a — minidom.parse() on an untrusted file path
# ruleid: xxe-prevention
doc = xml.dom.minidom.parse("/uploads/data.xml")

# Pattern 3b — minidom.parseString() with untrusted XML bytes
# ruleid: xxe-prevention
doc = xml.dom.minidom.parseString(xml_bytes)

# Pattern 4a — lxml XMLParser with resolve_entities=True (fully qualified, explicit opt-in)
# ruleid: xxe-prevention
parser = lxml.etree.XMLParser(resolve_entities=True)

# Pattern 4b — lxml XMLParser with resolve_entities=True (import-alias form)
# ruleid: xxe-prevention
parser = etree.XMLParser(resolve_entities=True)


# ==================== NEGATIVE CASES ====================
# These must NOT trigger the rule.

# Negative 1 — defusedxml ElementTree parse (safe drop-in replacement)
# ok: xxe-prevention
safe_tree = defusedxml.ElementTree.parse("/uploads/config.xml")

# Negative 2 — defusedxml fromstring (safe drop-in replacement)
# ok: xxe-prevention
safe_root = defusedxml.ElementTree.fromstring(xml_bytes)

# Negative 3 — defusedxml sax.parse (safe drop-in replacement)
# ok: xxe-prevention
defusedxml.sax.parse("/uploads/report.xml", handler)

# Negative 4 — defusedxml minidom.parseString (safe drop-in replacement)
# ok: xxe-prevention
safe_doc = defusedxml.minidom.parseString(xml_bytes)

# Negative 5 — lxml XMLParser with resolve_entities=False (explicit safe configuration)
# ok: xxe-prevention
safe_parser = lxml.etree.XMLParser(resolve_entities=False)

# Negative 6 — lxml XMLParser with resolve_entities=False (import-alias form, safe)
# ok: xxe-prevention
safe_parser2 = etree.XMLParser(resolve_entities=False)

# Negative 7 — lxml XMLParser with unrelated options and no resolve_entities argument
# ok: xxe-prevention
formatting_parser = lxml.etree.XMLParser(remove_blank_text=True, no_network=True)

# Negative 8 — building an ElementTree from in-memory objects (not parsing external input)
# ok: xxe-prevention
new_root = xml.etree.ElementTree.Element("root")
xml.etree.ElementTree.SubElement(new_root, "item")
new_tree = xml.etree.ElementTree.ElementTree(new_root)
