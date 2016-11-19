#!/usr/bin/env python3

"""transform.py: Generate HTML from XCode UI Test reports."""

from lxml import etree
from os import path as p
from distutils import dir_util
import webbrowser
import traceback
import datetime
import fnmatch
import shutil
import sys
import os

R = {   'xsl': 'plist2html.xsl',
        'vendor': [
            'vendor/jquery',
            'vendor/vis',
        ],
        'static': [
            'table.css',
        ],
        # A glob.
        'in': '*_TestSummaries.plist',
        'out': 'index.html',
        'att_in': 'Attachments',
        'att_out': 'Attachments'
    }
S = 'static'
V = 'vendor'

# Create the shared directory structure and populate the dependencies for
# the report markup.
host_dir = p.join(p.expanduser('~'), 'Documents', 'xc-ui-reports')
host_media = p.join(host_dir, R['att_out'])
host_shared = p.join(host_dir, S, '')

os.makedirs(p.dirname(host_media), exist_ok=True)
os.makedirs(p.dirname(host_shared), exist_ok=True)

try:
    for relpath in R[V]:
        shutil.copytree(p.join(sys.path[0], relpath), p.join(host_shared, relpath))
    for relpath in R[S]:
        shutil.copy(p.join(sys.path[0], relpath), host_shared)
except Exception as e:
    print(e)
    pass


try:
    test_src = sys.argv[1]
    src_media = p.join(test_src, R['att_in'])

    # Copy screenshots to the shared media directory.
    try:
        dir_util.copy_tree(src_media, host_media, update=True)
    except Exception as e:
        print(e)
        pass

    # Setup source and destination paths.
    in_xslt = p.join(sys.path[0], R['xsl'])
    in_plist = ''

    for f in os.listdir(test_src):
        if fnmatch.fnmatch(f, R['in']):
            in_plist = p.join(test_src, f)

    out_html = p.join(host_dir, datetime.datetime.utcnow().strftime('%d%m%H%M%S'), R['out'])

    # Cleanup a bit...
    plist = etree.parse(in_plist)
    dead_keys = ['LocalComputer', 'TestObjectClass', 'TestIdentifier', 'FormatVersion']
    for k in dead_keys:
        l = plist.xpath('//key[text() = "{0}"]'.format(k))
        for noise in l:
            noise.getnext().getparent().remove(noise.getnext())
            noise.getparent().remove(noise)

    # ...before transforming the plist to HTML.
    transform = etree.XSLT(etree.parse(in_xslt))
    transformed = transform(plist, attachments=etree.XSLT.strparam(host_media))

    os.makedirs(p.dirname(out_html), exist_ok=True)
    with open(out_html, 'w') as f:
        print(etree.tostring(transformed, pretty_print=True, encoding='unicode'), file=f)

    webbrowser.open('file://' + os.path.realpath(out_html))

except:
    print('Unexpected error: {0}\n'.format(traceback.format_exc()))
    sys.exit(1)
else:
    sys.exit(0)
