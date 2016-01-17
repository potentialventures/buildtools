#!/usr/bin/env python
"""
Simple script to combine multiple JUnit test results into a single XML file.
"""

import os
import sys
from xml.etree import cElementTree as ET


def find_all(name, path):
    result = []
    for root, dirs, files in os.walk(path):
        if name in files:
            yield os.path.join(root, name)

def main(path, output, existing="results.xml"):
    rc = 0
    testsuite = ET.Element("testsuite", name="all", package="all", tests="0")

    for fname in find_all(existing, path):
        tree = ET.parse(fname)
        for element in tree.getiterator("testcase"):
            testsuite.append(element)

            for child in element:
                if child.tag in ["failure", "error"]:
                    sys.stderr.write("FAILURE: %s.%s\n" %
                                     (element.attrib["classname"],
                                      element.attrib["name"]))
                    rc = 1

    result = ET.Element("testsuites", name="results")
    result.append(testsuite)

    ET.ElementTree(result).write(output, encoding="UTF-8")
    return rc

if __name__ == "__main__":
    rc = main(".", sys.argv[1])
    sys.exit(0)

