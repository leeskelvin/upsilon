#!/usr/bin/env python3

import os
import sys
import tempfile
import pandas as pd
import urllib.request

pdfdir = os.path.expanduser('~/Dropbox/professional/archive')   # PDF dir
bibdir = os.path.expanduser('~/software/upsilon/bib')           # bibtex dir
reader = '/usr/bin/evince'                                      # PDF reader
exiftool = '/usr/bin/exiftool'                                  # mod PDF title
file = '/usr/bin/file'                                          # mime types
bibfile = bibdir + '/bibtex.bib'                                # bibtex file

mirror = "http://adsabs.harvard.edu"
# mirror = "http://ukads.nottingham.ac.uk"
# mirror = "http://ads.nao.ac.jp"

bld = '\033[1m'
nrm = '\033[0m'

raw_args = sys.argv[1:]
args = []
for arg in raw_args:
    if arg[0] == '-':
        args.extend([f'-{x}' for x in arg[1:]])
    else:
        args.append(arg)
args.sort(reverse=True)

# usage when rebuilding bib file from scratch
# CL install privoxy tor
# CL add 'forward-socks4a / localhost:9050' to '/etc/privoxy/config'
# CL service tor start
# CL service privoxy start
# CL pip3 install pysocks
# import socks
# import socket
# socks.set_default_proxy(socks.SOCKS5, "localhost", 9050)
# socket.socket = socks.socksocket
# CL service tor stop
# CL service privoxy stop


def bibread(bibfile):
    with open(bibfile) as f:
        bibdat = [x for x in f.readlines() if x != '\n']
    if bibdat[-1][-1:] != '\n':
        bibdat[-1] += '\n'
    rows = [i for i, x in enumerate(bibdat) if '@' in x] + [len(bibdat)+1]
    refs, years, titles, bibentries = [], [], [], []
    for first, last in zip(rows[:-1], rows[1:]):
        bibentry = ''.join(bibdat[first:last])
        ref = bibentry.split('{')[1].split('\n')[0].strip(',"{}')
        year = int(bibentry.split('year = ')[1].split('\n')[0].strip(',"{}'))
        title = bibentry.split('title = ')[1].split('\n')[0].strip(',"{}')
        refs.append(ref)
        years.append(year)
        titles.append(title)
        bibentries.append(bibentry)
    df = pd.DataFrame(dict(ref=refs, year=years, title=titles,
                           bibentry=bibentries))
    # abc ref sort disabled here for speed, enabled for writing instead
    # df = df.iloc[df.ref.str.lower().argsort()]
    # df.reset_index(inplace=True, drop=True)
    return df


def bibwrite(df, bibfile):
    df = df.iloc[df.ref.str.lower().argsort()]
    df.reset_index(inplace=True, drop=True)
    with open(bibfile, 'w') as f:
        for bibentry in df['bibentry']:
            f.write(bibentry + '\n')


try:
    df = bibread(bibfile)
except Exception:
    raise


if len(args) == 0 or '-h' in args:
    print('')
    print('Usage: bib [INPUT] [arg]')
    print('')
    print('Arguments:')
    print('')
    print('bib -a   (print full paper titles, no truncation)')
    print('bib -b   (include full bibtex entries in search)')
    print('bib -f   (run PDF title get/set routine over all PDFs)')
    print('bib -h   (show help file)')
    print('bib -o   (open first matching search entry in PDF reader)')
    print('bib -r   (reverse order)')
    print('bib -u   (update bibliography from ADS / local bibtex.txt file)')
    print('bib -y   (order by year)')
    print('')
    print(f'Bibliography contains {bld}{len(df)}{nrm} entries.')
    print('')
elif not os.path.exists(pdfdir) and ('-u' in args or '-f' in args
                                     or '-o' in args):
    raise FileNotFoundError(f'Cannot locate PDF directory: {pdfdir}')
elif '-u' in args:
    all_files = os.listdir(pdfdir)
    pdfs = sorted([x for x in all_files if '.pdf' in x])
    refs, pdf_codes = zip(*[x.split('::') for x in pdfs])
    codes = [x[:-4] for x in pdf_codes]
    findreplace = {'&amp;': '&',
                   '&#34;': '"',
                   '\\\\&lt;': '<',
                   '\\\\&gt;': '>',
                   '\\\\&le;': '<=',
                   '\\\\&ge;': '>=',
                   '%26': '&',
                   '&#39;': "'"}

    df2 = pd.DataFrame(dict(ref=refs,
                            year=[-9999]*len(refs),
                            title=['']*len(refs),
                            bibentry=['']*len(refs),
                            code=codes,))
    df2 = df2.iloc[df2.ref.str.lower().argsort()]
    df2.reset_index(inplace=True, drop=True)
    for index, row in df2.iterrows():
        if row['ref'] in df['ref'].to_list():
            old_index = df.index[df['ref'] == row['ref']].tolist()[0]
            df2.at[index, 'year'] = df.at[old_index, 'year']
            df2.at[index, 'title'] = df.at[old_index, 'title']
            df2.at[index, 'bibentry'] = df.at[old_index, 'bibentry']

    for index, row in df2.iterrows():
        print(f'{index} : {row.ref} ', end='', flush=True)
        if row.year == -9999 and row.code != 'LSK':
            biburl = mirror + '/abs/' + row.code + '/exportcitation'
            bibresponse = urllib.request.urlopen(biburl)
            bibhttp = []
            for line in bibresponse:
                bibhttp.append(line.decode("utf-8"))
            l0 = [i for i, x in enumerate(bibhttp)
                  if 'readonly=\"\">@' in x][0] + 1
            l1 = [i for i, x in enumerate(bibhttp)
                  if 'adsnote' in x][0] + 2
            bibtype = bibhttp[l0 - 1].split('"">@')[1].split('{')[0]
            bibref = '@'+bibtype.upper()+'{'+row.ref+',\n'
            bibentry = ''.join(bibhttp[l0:l1])
            for key in findreplace:
                bibentry = bibentry.replace(key, findreplace[key])
            if 'BOOK' in bibtype and len(bibentry.split('publisher =')) == 1:
                publisher = input('publisher: ')
                bibref += '    publisher = {' + publisher + '},\n'
            if 'BOOK' in bibtype and len(bibentry.split('editor =')) == 2:
                bibentry = bibentry.replace('editor =', '  note =')
            temp_year = bibentry.split('year = ')[1].split('\n')[0]
            temp_title = bibentry.split('title = ')[1].split('\n')[0]
            df2.at[index, 'year'] = int(temp_year.strip(',"{}'))
            df2.at[index, 'title'] = temp_title.strip(',"{}')
            df2.at[index, 'bibentry'] = bibref + bibentry
            df2 = df2.astype({'year': int})
            pdfpath = f'{pdfdir}/{row.ref}::{row.code}.pdf'
            exifsetcmd = (f'{exiftool} -title="{row.ref}" '
                          f'-overwrite_original_in_place '
                          f'-preserve -quiet -m "{pdfpath}"')
            titleset = os.popen(exifsetcmd).read().strip('\n')
        print('\x1b[2K', end='\r')

    bibwrite(df2, bibfile)
    print((f'Bibliography contains {bld}{len(df2)}{nrm} entries '
           f'({bld}{len(df2) - len(df):+d}{nrm} change)'))
elif '-f' in args:
    all_files = os.listdir(pdfdir)
    pdfs = sorted([x for x in all_files if '.pdf' in x])
    refs, pdf_codes = zip(*[x.split('::') for x in pdfs])

    for index, (ref, pdf) in enumerate(zip(refs, pdfs)):
        print(f'{index} : {ref} ', end='', flush=True)
        pdfpath = pdfdir + '/' + pdf
        filetype = os.popen(f'{file} --mime-type -b "{pdfpath}"').read()
        if 'application/pdf' in filetype:
            titleline = os.popen(f'{exiftool} -title "{pdfpath}"').read()
            if ref + '\n' not in titleline:
                exifsetcmd = (f'{exiftool} -title="{ref}" '
                              f'-overwrite_original_in_place '
                              f'-preserve -quiet -m "{pdfpath}"')
                titleset = os.popen(exifsetcmd).read().strip('\n')
        print('\x1b[2K', end='\r')
else:
    if '-y' in args:
        df = df.iloc[df.year.argsort()]
        # df.reset_index(inplace=True, drop=True)
    if '-r' in args:
        df = df.iloc[::-1]
        # df.reset_index(inplace=True, drop=True)

    if '-a' not in args:
        linetruncon = os.system('tput rmam')
    tmp = tempfile.NamedTemporaryFile(mode='w+')
    for ref, tit, be in zip(df.ref, df.title, df.bibentry):
        # extra spaces required at end of line before \n to enable grepping
        # not sure why this is the case, but issue verified during testing
        if '-b' in args:
            be = be.replace('\n', '')
            tmp.write(f'{bld}{ref:14s}{nrm} {tit} {be}  \n\n')
        else:
            tmp.write(f'{bld}{ref:14s}{nrm} {tit}  \n')
    catcmd = f'grep --color=auto --ignore-case "{args[0]}" {tmp.name}'
    if '-a' in args and '-b' in args:
        catcmd += ' -A 1'
    print('')
    catstat = os.system(catcmd)
    if catstat == 0 and '-a' not in args and '-b' not in args:
        print('')
    if '-o' in args:
        catout = os.popen(catcmd).read()
        matchref = catout.split(bld)[1].split(nrm)[0].strip()
        all_files = os.listdir(pdfdir)
        pdfs = sorted([x for x in all_files if '.pdf' in x])
        matchpdf = pdfdir + '/' + [x for x in pdfs if matchref+'::' in x][0]
        readercmd = f'{reader} "{matchpdf}" &'
        readerout = os.system(readercmd)
    tmp.close()
    linetruncoff = os.system('tput smam')
