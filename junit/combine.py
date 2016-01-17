#!/usr/bin/env python
"""
Simple script to combine multiple JUnit test results into a single XML file.
"""

import os
import sys
from collections import defaultdict
from xml.etree import cElementTree as ET


def find_all(name, path):
    result = []
    for root, dirs, files in os.walk(path):
        if name in files:
            yield os.path.join(root, name)

def main(path, output, existing="results.xml"):
    rc = 0
    results = defaultdict(int)
    testsuite = ET.Element("testsuite", name="all", package="all")

    for fname in find_all(existing, path):
        tree = ET.parse(fname)
        for element in tree.getiterator("testcase"):
            testsuite.append(element)
            results["tests"] += 1

            for child in element:
                if child.tag == "failure":
                    results["failures"] += 1
                    break
                elif child.tag == "error":
                    results["errors"] += 1
                    break
                elif child.tag == "skipped":
                    results["skipped"] += 1
                    break
    for outcome, count in results.iteritems():
        testsuite.set(outcome, "%d" % count)
    result = ET.Element("testsuites", name="results")
    result.append(testsuite)

    ET.ElementTree(result).write(output, encoding="UTF-8")
    return rc

if __name__ == "__main__":
    rc = main(".", sys.argv[1])
    sys.exit(0)

