#!/usr/bin/env python2
# -*- coding:utf-8 -*-

"""
Send Meteofrance and SLF snow bulletins
---------------------------------------

This script parse Meteofrance and SLF snow bulletins, download images and send
it by email.

Dependencies:
- python-lxml
- python-argparse (needed for python 2.6, included in 2.7)

"""

import argparse
import cookielib
import json
import logging
import logging.handlers
import os
import re
import smtplib
import signal
import subprocess
import sys
import urllib2

from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.utils import formatdate
from lxml.html import tostring, fromstring
from urllib2 import HTTPError

# config

WORK_DIR = "/var/cache/meteofrance/"
SENDER = 'nobody@lists.camptocamp.org'

MF_URL = "http://www.meteofrance.com/"
MF_BASE_URL = (MF_URL +
               "previsions-meteo-montagne/bulletin-avalanches/synthese/d/AV")
MF_REST_URL = MF_URL + "mf3-rpc-portlet/rest/"
MF_STORE = 'meteofrance_store.json'

DEPT_LIST = ["DEPT74", "DEPT73", "DEPT38", "DEPT04", "DEPT05", "DEPT06",
             "DEPT2A", "DEPT2B", "DEPT66", "DEPT31", "DEPT09", "ANDORRE",
             "DEPT64", "DEPT65"]

SLF_URL = "http://www.slf.ch/lawinenbulletin"
SLF_STORE = 'slf_store.json'
SLF_LANGS = ['FR', 'DE', 'IT', 'EN']

TITLE_NIVO = u"neige et avalanches"
TITLE_SYNTH = u"de synthèse hebdomadaire"
CONTENT_NIVO = u"""Le bulletin neige et avalanches est constitué d'images,
celles-ci sont en pièce jointe ou dans la version html de ce mail."""

SUBJECT_TPL = u"Bulletin {bulletin_type} - {dept}"

TXT_TPL = u"""
Bulletin {bulletin_type} - {dept}
=====================================

{content}

-------------------------------------------------------------------------------

Ce bulletin {bulletin_type} est rédigé par {src_name} ({src_url}).
La liste de diffusion est gérée par Camptocamp-association
(http://www.camptocamp.org).

Pour ne plus recevoir de bulletin par email, rendez vous à l'adresse suivante :
http://www.camptocamp.org/users/mailinglists

N'hésitez pas à saisir vos sorties pour rapporter vos observations sur
les conditions nivologiques et l'activité avalancheuse :
http://www.camptocamp.org/outings/wizard
"""

HTML_TPL = u"""
<html>
<head></head>
<body>
  <h1>Bulletin {bulletin_type} - {dept}</h1>
  <p>{content}</p>
  <hr />
  <div>
  <p>Ce bulletin {bulletin_type} est rédigé par
  <a href="{src_url}">{src_name}</a>.<br>
  La liste de diffusion est gérée par
  <a href="http://www.camptocamp.org/">Camptocamp-association</a>.</p>
  <p>Pour ne plus recevoir de bulletin par email, rendez vous à l'adresse suivante&nbsp;:
  <a href="http://www.camptocamp.org/users/mailinglists">http://www.camptocamp.org/users/mailinglists</a></p>
  <p>N'hésitez pas à <a href="http://www.camptocamp.org/outings/wizard">saisir
  vos sorties</a> pour rapporter vos observations sur les conditions
  nivologiques et l'activité avalancheuse.</p>
  </div>
</body>
</html>
"""


class Mail(object):
    """
    Create a multipart email template, add text, html and images, and send the
    email.
    """

    def __init__(self, recipient, text, html, subject, encoding='utf8'):
        """Create the message container and add text and html content"""

        self.log = logging.getLogger('MFBot')
        self.msg = MIMEMultipart('related')
        self.msg['From'] = SENDER
        self.msg['To'] = recipient
        self.msg['Date'] = formatdate(localtime=True)
        self.msg['Subject'] = subject
        self.msg.preamble = 'This is a multi-part message in MIME format.'

        # Encapsulate the plain and HTML versions of the message body in an
        # 'alternative' part, so message agents can decide which they want to
        # display.
        msg_alternative = MIMEMultipart('alternative')
        self.msg.attach(msg_alternative)

        # Record the MIME types of both parts - text/plain and text/html.
        msg_alternative.attach(MIMEText(text, 'plain', encoding))

        # According to RFC 2046, the last part of a multipart message, in this
        # case the HTML message, is best and preferred.
        msg_alternative.attach(MIMEText(html, 'html', encoding))

    def attach_image(self, filename):
        """Read the image and attach it to the email."""

        with open(os.path.join(WORK_DIR, filename)) as f:
            img = f.read()

        # Open the files in binary mode. Let the MIMEImage class
        # automatically guess the specific image type.
        msg_image = MIMEImage(img)

        # Define the image's ID as referenced above
        msg_image.add_header('Content-ID', '<{}>'.format(filename))
        self.msg.attach(msg_image)

    def send(self, method='smtp'):
        """Send the message via a SMTP server."""

        if method == 'smtp':
            # sendmail function takes 3 arguments: sender's address,
            # recipient's address and message to send
            s = smtplib.SMTP('localhost')
            s.sendmail(SENDER, self.msg['To'], self.msg.as_string())
            s.quit()
        elif method == 'msmtp':
            p = subprocess.Popen(['msmtp', '-t'], stdin=subprocess.PIPE)
            p.communicate(input=self.msg.as_string())
            if p.returncode != 0:
                self.log.error('Failed to send mail')
        else:
            self.log.warning('Unknown method, no mail sent')


class Bot(object):

    def __init__(self):
        cj = cookielib.CookieJar()
        self.opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
        self.opener.addheaders = [('User-agent', 'MFBot/1.0')]

        self.store = None
        self.log = logging.getLogger('MFBot')

    def get_url(self, url):
        """Download an url."""

        self.log.debug('Downloading %s ...', url)
        try:
            resp = self.opener.open(url)
        except HTTPError as e:
            self.log.error('%s - %s', self.dept, str(e))
            raise

        if resp.getcode() != 200:
            self.log.error('%s - page not available', self.dept)
            return

        return resp

    def get_html(self, url):
        """Download page and load the html."""
        resp = self.get_url(url)
        return fromstring(resp.read().decode('iso-8859-1', 'replace'),
                          base_url=MF_URL)

    def get_json(self, url):
        """Download an url and load the json."""
        resp = self.get_url(url)
        return json.loads(resp.read().decode('utf-8'))

    def open_store(self):
        with open(self.store, 'r') as f:
            data = json.load(f)
        return data

    def save_store(self, data):
        with open(self.store, 'w') as f:
            json.dump(data, f)


class MFBot(Bot):
    """Bot which parses Meteofrance's snow bulletin and send it by email."""

    def __init__(self, dept):
        super(MFBot, self).__init__()
        self.dept = dept
        self.store = os.path.join(WORK_DIR, MF_STORE)
        if not os.path.isfile(self.store):
            self.save_store({'nivo': {}, 'synth': {}, 'images': {}})

    def prepare_mail(self, recipient, html_content, txt_content, **kwargs):
        """Substite strings in the templates and return a Mail object."""

        ctx = {'bulletin_type': '', 'dept': self.dept,
               'src_url': MF_URL, 'src_name': 'MétéoFrance'}
        ctx.update(kwargs)

        bulletin_html = HTML_TPL.format(content=html_content, **ctx)
        bulletin_txt = TXT_TPL.format(content=txt_content, **ctx)
        subject = SUBJECT_TPL.format(**ctx)

        return Mail(recipient, bulletin_txt, bulletin_html, subject)

    def send_nivo_images(self, recipient, method='smtp'):
        """Send bulletin with images extracted by the phantomjs script"""

        dept = self.dept.replace('DEPT', '').lower()

        try:
            subprocess.check_call(['phantomjs', 'meteofrance.js',
                                   '--working-dir=' + WORK_DIR, dept])
        except subprocess.CalledProcessError:
            self.log.error('%s phantomjs script failed.', self.dept)
            return

        with open(os.path.join(WORK_DIR, 'meteofrance.json'), 'r') as f:
            data = json.load(f)

        if dept not in data:
            self.log.error('%s Data not found', self.dept)
            return

        data = data[dept]

        # find all images
        img_list = re.findall(r'mf_OPP.*?\.png', data['content'])

        # generate the <img> codes for each image
        html_content = re.sub(r'(mf_OPP.*?\.png)', r'cid:\1', data['content'])

        data_ref = self.open_store()
        ref = data_ref['images'].get(self.dept)

        if ref and ref == data['content']:
            self.log.info('%s nivo - No change, nothing to do', self.dept)
        else:
            self.log.info('%s nivo - Sending mail', self.dept)
            m = self.prepare_mail(recipient, html_content, CONTENT_NIVO,
                                  bulletin_type=TITLE_NIVO)

            for filename in img_list:
                m.attach_image(filename)

            m.send(method=method)
            data_ref['images'][self.dept] = data['content']
            self.save_store(data_ref)

    def send_nivo_text(self, recipient, method='smtp'):
        """Send text bulletin when it replaces image bulletin."""

        url = MF_REST_URL + "bulletins/lastest/fwfx5/AV" + self.dept
        content = self.get_json(url)['corpsBulletin']

        if re.match('.*Pas de bulletin disponible pour ce lieu.*', content):
            self.log.info('%s nivo text - No bulletin', self.dept)
            return

        if len(content) < 300:
            self.log.info('%s nivo text - Empty text', self.dept)
            return

        data_ref = self.open_store()
        ref = data_ref['nivo'].get(self.dept)

        if ref and ref == content:
            self.log.info('%s nivo text - No change, nothing to do', self.dept)
        else:
            # text changed -> send the mail and store new text
            html_content = content.replace('\n', '<br/>')

            self.log.info('%s nivo text - Sending mail', self.dept)
            mail = self.prepare_mail(recipient, html_content, content,
                                     bulletin_type=TITLE_NIVO)
            mail.send(method=method)

            data_ref['nivo'][self.dept] = content
            self.save_store(data_ref)

    def send_synth_text(self, recipient, method='smtp'):
        """Send weekly synthesis."""

        url = MF_BASE_URL + self.dept
        content = self.get_html(url)
        synth_content = content.cssselect(".mod-body .p-style-2")

        if not synth_content:
            self.log.info('%s synth - No content', self.dept)
            return

        synth_html = tostring(synth_content[0],
                              encoding='iso-8859-1').decode('utf-8')
        synth_html = re.sub('<p class="p-style-2">.*?<br>', '', synth_html)
        synth_html = synth_html.replace('</p>', '')
        synth_txt = re.sub(r'<br\s*/?>', r'\n', synth_html)

        if len(synth_txt) < 300:
            self.log.info('%s synth - Empty text - Nothing to do', self.dept)
            return

        data_ref = self.open_store()
        ref = data_ref['synth'].get(self.dept)

        if ref and ref == synth_txt:
            self.log.info('%s synth - No change, nothing to do', self.dept)
        else:
            # text changed -> send the mail and store new text
            self.log.info('%s synth - Sending mail', self.dept)
            m = self.prepare_mail(recipient, synth_html, synth_txt,
                                  bulletin_type=TITLE_SYNTH, src_url=url)
            m.send(method=method)
            data_ref['synth'][self.dept] = synth_txt
            self.save_store(data_ref)


class SLFBot(Bot):
    """Bot which parses SLF's snow bulletin and send it by email."""

    def __init__(self):
        super(SLFBot, self).__init__()
        self.store = os.path.join(WORK_DIR, SLF_STORE)
        if not os.path.isfile(self.store):
            self.save_store({})

    def prepare_mail(self, recipient, html_content, txt_content, **kwargs):
        """Substite strings in the templates and return a Mail object."""

        ctx = {'bulletin_type': '', 'dept': '',
               'src_url': SLF_URL, 'src_name': 'SLF'}
        ctx.update(kwargs)

        bulletin_html = HTML_TPL.format(content=html_content, **ctx)
        bulletin_txt = TXT_TPL.format(content=txt_content, **ctx)
        subject = SUBJECT_TPL.format(**ctx)

        return Mail(recipient, bulletin_txt, bulletin_html, subject)

    def send(self, lang, recipient, method='smtp'):
        """Send bulletin with images extracted by the phantomjs script"""

        if lang not in SLF_LANGS:
            return

        try:
            subprocess.check_call(['phantomjs', 'slf.js',
                                   '--working-dir=' + WORK_DIR, lang])
        except subprocess.CalledProcessError:
            self.log.error('%s phantomjs slf.js script failed.', lang)
            return

        with open(os.path.join(WORK_DIR, 'slf.json'), 'r') as f:
            data = json.load(f)

        if lang not in data:
            self.log.error('%s Data not found', lang)
            return

        data = data[lang]

        # find all images
        img_list = re.findall(r'slf_.*?\.png', data['content'])

        # generate the <img> codes for each image
        html_content = re.sub(r'(slf_.*?\.png)', r'cid:\1', data['content'])

        data_ref = self.open_store()
        ref = data_ref.get(lang)

        if ref and ref == data['content']:
            self.log.info('%s nivo - No change, nothing to do', lang)
        else:
            self.log.info('%s nivo - Sending mail', lang)
            m = self.prepare_mail(recipient, html_content, CONTENT_NIVO,
                                  bulletin_type=TITLE_NIVO, dept=lang)

            for filename in img_list:
                m.attach_image(filename)

            m.send(method=method)
            data_ref[lang] = data['content']
            self.save_store(data_ref)


def main():
    """Main function with arguments parsing."""

    parser = argparse.ArgumentParser(
        description="Send Meteofrance's snow bulletins.")
    parser.add_argument('-m', '--smtp-method', action='store',
                        dest='smtp_method', default='smtp',
                        help='Method to send mail: `smtp` or `msmtp`.')
    parser.add_argument('-t', '--to', action='store', dest='recipient',
                        help='Recipient of the mail (useful for tests).')
    parser.add_argument('-d', '--debug', action='store_true',
                        help="Debug mode: print logs, set WORK_DIR to cwd.")
    args = parser.parse_args()

    # logging config
    logger = logging.getLogger('MFBot')

    if args.debug:
        global WORK_DIR
        WORK_DIR = '.'
        handler = logging.StreamHandler(stream=sys.stdout)
    else:
        handler = logging.handlers.SysLogHandler(address='/dev/log')

    formatter = logging.Formatter(
        '%(name)s[%(process)d]: %(levelname)s - %(message)s')
    handler.setFormatter(formatter)

    logger.setLevel(logging.DEBUG)
    logger.addHandler(handler)

    bot = SLFBot()
    for lang in SLF_LANGS:
        try:
            bot.send(lang, args.recipient, method=args.smtp_method)
        except Exception:
            logger.error("Unexpected error: %s" % sys.exc_info()[1])

    return
    for dept in DEPT_LIST:
        recipient = args.recipient or \
            "meteofrance-%s@lists.camptocamp.org" % dept.replace('DEPT', '')

        bot = MFBot(dept)

        # 'nivo_text', -> deactivated until it replaces the images bulletin
        for bulletin_type in ('nivo_images', 'synth_text'):
            func = getattr(bot, 'send_' + bulletin_type)

            try:
                func(recipient, method=args.smtp_method)
            except HTTPError:
                pass
            except Exception:
                logger.error("Unexpected error: %s" % sys.exc_info()[1])


def signal_handler(signal, frame):
    sys.exit('Ctrl-C pressed, aborting.')


if __name__ == '__main__':
    signal.signal(signal.SIGINT, signal_handler)
    main()
