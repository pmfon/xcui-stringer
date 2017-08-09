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


try:
    test_src = sys.argv[1]
    report_dst = p.join(p.expanduser('~'), 'Documents', 'xcui-stringer')
    if len(sys.argv) > 2:
        report_dst = sys.argv[2]

    # Create the directory structure and copy resources for the report markup.
    host_media = p.join(report_dst, R['att_out'])
    host_shared = p.join(report_dst, 'static', '')
    os.makedirs(p.dirname(host_media), exist_ok=True)
    os.makedirs(p.dirname(host_shared), exist_ok=True)
    try:
        for relpath in R['vendor']:
            shutil.copytree(p.join(sys.path[0], relpath), p.join(host_shared, relpath))
        for relpath in R['static']:
            shutil.copy(p.join(sys.path[0], relpath), host_shared)
    except Exception as e:
        print(e)
        pass

    # Copy the screenshots from the XCUI test logs.
    src_media = p.join(test_src, R['att_in'])
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

    out_html = p.join(report_dst, datetime.datetime.utcnow().strftime('%y%m%dT%H%M%SZ'), R['out'])

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

    print('Writing {0}...'.format(os.path.realpath(out_html)))
    os.makedirs(p.dirname(out_html), exist_ok=True)
    with open(out_html, 'w') as f:
        print(etree.tostring(transformed, pretty_print=True, encoding='unicode'), file=f)

    # webbrowser.open('file://' + os.path.realpath(out_html))
except:
    print('Unexpected error: {0}\n'.format(traceback.format_exc()))
    print('Usage: transform.py <test logs dir> [<output dir>]')
    sys.exit(1)
else:
    sys.exit(0)
