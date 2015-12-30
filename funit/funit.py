#!/usr/bin/env python
"""
Generic FuseSoC + VUnit test runner...

Based on Olof's demo: https://github.com/olofk/fusesoc_vunit_demo
"""

from collections import OrderedDict
import sys
import os
import os.path

from fusesoc.config import Config
from fusesoc.coremanager import CoreManager, DependencyError
from vunit import VUnit

def main():

    # VUnit steals the command line args so we use an environment variable
    # to determine which core we're picking up
    toplevel = os.getenv("CORE", "")
    if not toplevel:
        sys.stderr.write("Need to provide CORE environment variable")
        sys.exit(1)

    # Create VUnit instance by parsing command line arguments
    vu = VUnit.from_argv()

    #Create singleton instances for core manager and configuration handler
    #Configuration manager is not needed in this example
    cm = CoreManager()

    # Assume we're running in the same directory containing the cores
    cm.add_cores_root(".")

    #Get the sorted list of dependencies starting from the top-level core
    try:
        cores = cm.get_depends(toplevel)
    except DependencyError as e:
        print("'{}' or any of its dependencies requires '{}', but this core was not found".format(top_core, e.value))
        sys.exit(2)

    #Iterate over cores, filesets and files and add all relevant sources files to vunit
    incdirs = set()
    src_files = []

    #'usage' is a list of tags to look for in the filesets.
    # Only look at filesets where any of these tags are present
    usage = ['sim']
    for core_name in cores:
        core = cm.get_core(core_name)
        core.setup()
        basepath = core.files_root
        for fs in core.file_sets:
            if (set(fs.usage) & set(usage)) and ((core_name == toplevel) or not fs.private):
                for file in fs.file:
                    if file.is_include_file:
                        #TODO: incdirs not used right now
                        incdirs.add(os.path.join(basepath, os.path.dirname(file.name)))
                    else:
                        try:
                            vu.library(file.logical_name)
                        except KeyError:
                            vu.add_library(file.logical_name)
                        vu.add_source_file(os.path.join(basepath, file.name), file.logical_name)
    # Run vunit function
    vu.main()


if __name__ == "__main__":
    main()
