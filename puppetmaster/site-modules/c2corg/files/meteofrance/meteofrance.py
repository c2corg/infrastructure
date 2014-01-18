#!/usr/bin/env python2
# -*- coding:utf-8 -*-

"""
Send Meteofrance's snow bulletins
---------------------------------

This script parse Meteofrance's snow bulletins, download images and send it by
email.

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

MF_URL = "http://www.meteofrance.com/"
BASE_URL = MF_URL + "previsions-meteo-montagne/bulletin-avalanches/synthese/d/AV"
REST_URL = MF_URL + "mf3-rpc-portlet/rest/"
WORK_DIR = "/var/cache/meteofrance/"
SENDER = 'nobody@lists.camptocamp.org'
STORE_NIVO = 'meteofrance_nivo.json'
STORE_NIVO_TEXT = 'meteofrance_text.json'
STORE_SYNTH = 'meteofrance_synth.json'
DEPT_LIST = ["DEPT74", "DEPT73", "DEPT38", "DEPT04", "DEPT05", "DEPT06",
             "DEPT2A", "DEPT2B", "DEPT66", "DEPT31", "DEPT09", "ANDORRE",
             "DEPT64", "DEPT65"]

TITLE_NIVO = u"neige et avalanches"
TITLE_SYNTH = u"de synthèse hebdomadaire"
CONTENT_NIVO = u"""Le bulletin neige et avalanches est constitué d'images,
celles-ci sont en pièce jointe ou dans la version html de ce mail."""

SUBJECT_TPL = u"Bulletin {bulletin_type} - {dept}"

TXT_TPL = u"""
Bulletin {bulletin_type} - {dept}
=====================================

{content}

--------------------------------------------------------------------------------

Ce bulletin {bulletin_type} est rédigé par MétéoFrance ({full_url}).
La liste de diffusion est gérée par Camptocamp-association (http://www.camptocamp.org).

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
  <a href="{full_url}">MétéoFrance</a>.<br>
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
    This class allows to
    - create a multipart email template,
    - add text and html content,
    - attach other parts (e.g. images)
    - send the email
    """
    def __init__(self, recipient, text, html, subject, encoding='utf8'):
        "Create the message container and add text and html content"

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
        with open(filename) as f:
            img = f.read()

        # Open the files in binary mode. Let the MIMEImage class
        # automatically guess the specific image type.
        msg_image = MIMEImage(img)

        # Define the image's ID as referenced above
        msg_image.add_header('Content-ID', '<{}>'.format(filename))
        self.msg.attach(msg_image)

    def send(self, method='smtp'):
        "Send the message via a SMTP server."

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


class MFBot(object):
    """Bot which parses Meteofrance's snow bulletin and send it by email."""

    def __init__(self, dept):
        cj = cookielib.CookieJar()
        self.opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
        self.opener.addheaders = [('User-agent', 'MFBot/1.0')]

        self.log = logging.getLogger('MFBot')
        self.dept = dept

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

    def prepare_mail(self, recipient, html_content, txt_content, **kwargs):
        """Substite strings in the templates and return a Mail object."""

        ctx = {'bulletin_type': '', 'dept': self.dept, 'full_url': MF_URL}
        ctx.update(kwargs)

        bulletin_html = HTML_TPL.format(content=html_content, **ctx)
        bulletin_txt = TXT_TPL.format(content=txt_content, **ctx)
        subject = SUBJECT_TPL.format(**ctx)

        return Mail(recipient, bulletin_txt, bulletin_html, subject)

    def send_nivo_images(self, recipient, method='smtp'):
        """
        Add images as attachment to the message and reference it in the html
        part.
        """

        dept = self.dept.replace('DEPT', '').lower()

        try:
            subprocess.check_call(['phantomjs', 'meteofrance.js', '--working-dir=' + WORK_DIR + ' ' + dept])
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

        try:
            with open(os.path.join(WORK_DIR, STORE_NIVO), 'r') as f:
                data_ref = json.load(f)
        except IOError:
            data_ref = {}

        ref = data_ref.get(self.dept)
        if ref and ref == data['content']:
            self.log.info('%s nivo - No change, nothing to do', self.dept)
        else:
            self.log.info('%s nivo - Sending mail', self.dept)
            m = self.prepare_mail(recipient, html_content, CONTENT_NIVO,
                                  bulletin_type=TITLE_NIVO)

            for filename in img_list:
                m.attach_image(filename)

            m.send(method=method)
            data_ref[self.dept] = data['content']

            with open(os.path.join(WORK_DIR, STORE_NIVO), 'w') as f:
                json.dump(data_ref, f)

    def send_nivo_text(self, recipient, method='smtp'):
        """Send text bulletin when it replaces image bulletin."""

        url = REST_URL + "bulletins/lastest/fwfx5/AV" + self.dept
        content = self.get_json(url)['corpsBulletin']

        if re.match('.*Pas de bulletin disponible pour ce lieu.*', content):
            self.log.info('%s nivo text - No bulletin', self.dept)
            return

        if len(content) < 300:
            self.log.info('%s nivo text - Empty text', self.dept)
            return

        try:
            with open(os.path.join(WORK_DIR, STORE_NIVO_TEXT), 'r') as f:
                nivo_ref = json.load(f)
        except IOError:
            nivo_ref = {}

        if nivo_ref.get(self.dept, '') == content:
            self.log.info('%s nivo text - No change, nothing to do', self.dept)
        else:
            # text changed -> send the mail and store new text
            content_html = content.replace('\n', '<br/>')

            self.log.info('%s nivo text - Sending mail', self.dept)
            mail = self.prepare_mail(recipient, content_html, content,
                                     bulletin_type=TITLE_NIVO)
            mail.send(method=method)

            nivo_ref[self.dept] = content
            with open(os.path.join(WORK_DIR, STORE_NIVO_TEXT), 'w') as f:
                json.dump(nivo_ref, f)

    def send_synth_text(self, recipient, method='smtp'):
        """Send weekly synthesis."""

        url = BASE_URL + self.dept
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

        try:
            with open(os.path.join(WORK_DIR, STORE_SYNTH), 'r') as f:
                synth_ref = json.load(f)
        except IOError:
            synth_ref = {}

        if (self.dept in synth_ref and
                len(synth_ref[self.dept]) == len(synth_txt) and
                synth_ref[self.dept] == synth_txt):
            self.log.info('%s synth - No change, nothing to do', self.dept)
        else:
            # text changed -> send the mail and store new text
            self.log.info('%s synth - Sending mail', self.dept)
            m = self.prepare_mail(recipient, synth_html, synth_txt,
                                  bulletin_type=TITLE_SYNTH, full_url=url)
            m.send(method=method)

            synth_ref[self.dept] = synth_txt
            with open(os.path.join(WORK_DIR, STORE_SYNTH), 'w') as f:
                json.dump(synth_ref, f)


def main():
    "Main function with arguments parsing."

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

    for dept in DEPT_LIST:
        recipient = args.recipient or \
            "meteofrance-%s@lists.camptocamp.org" % dept.replace('DEPT', '')

        bot = MFBot(dept)

        for bulletin_type in ('nivo_images', 'nivo_text', 'synth_text'):
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
