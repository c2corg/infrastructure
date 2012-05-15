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
import smtplib
import urllib2
import sys
import re

from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.utils import formatdate

from lxml import html

# config

BASE_URL = "http://france.meteofrance.com/france/MONTAGNE?MONTAGNE_PORTLET.path=montagnebulletinneige/"
WORK_DIR = "/var/cache/meteofrance/"
SENDER = 'nobody@lists.camptocamp.org'
STORE_NIVO = WORK_DIR + 'meteofrance.json'
STORE_NIVO_TEXT = WORK_DIR + 'meteofrance_text.json'
STORE_SYNTH = WORK_DIR + 'meteofrance_synth.json'
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

----
Ce bulletin {bulletin_type} est rédigé par MétéoFrance ({full_url}).
La liste de diffusion est gérée par Camptocamp-association (http://www.camptocamp.org).

Pour ne plus recevoir de bulletin par email, rendez vous à l'adresse suivante :
http://www.camptocamp.org/users/mailinglists
"""

HTML_TPL = u"""
<html>
<head></head>
<body>
  <h1>Bulletin {bulletin_type} - {dept}</h1>
  <p>{content}</p>
  <div>
  <p>Ce bulletin {bulletin_type} est rédigé par
  <a href="{full_url}">MétéoFrance</a>.<br>
  La liste de diffusion est gérée par
  <a href="http://www.camptocamp.org/">Camptocamp-association</a>.</p>
  <p>Pour ne plus recevoir de bulletin par email, rendez vous à l'adresse suivante&nbsp;:
  <a href="http://www.camptocamp.org/users/mailinglists">
  http://www.camptocamp.org/users/mailinglists</a></p>
  </div>
</body>
</html>
"""


class Mail():
    """
    This class allows to
    - create a multipart email template,
    - add text and html content,
    - attach other parts (e.g. images)
    - send the email
    """
    def __init__(self, recipient, text_content, html_content, subject,
                 encoding='iso-8859-1'):
        "Create the message container and add text and html content"

        self.recipient = recipient

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
        msg_text = MIMEText(text_content, 'plain', encoding)
        msg_alternative.attach(msg_text)

        # According to RFC 2046, the last part of a multipart message, in this
        # case the HTML message, is best and preferred.
        msg_text = MIMEText(html_content, 'html', encoding)
        msg_alternative.attach(msg_text)

    def attach(self, part):
        self.msg.attach(part)

    def send(self, method="smtp"):
        "Send the message via a SMTP server."

        if method == 'smtp':
            # sendmail function takes 3 arguments: sender's address,
            # recipient's address and message to send
            s = smtplib.SMTP('localhost')
            s.sendmail(SENDER, self.recipient, self.msg.as_string())
            s.quit()
        elif method == 'msmtp':
            p = os.popen("msmtp -t", "w")
            p.write(self.msg.as_string())
            # status = p.close()


class MFBot():
    """
    This bot parses Meteofrance's snow bulletin and send an email with the
    extracted content.
    """
    def __init__(self, dept):
        cj = cookielib.CookieJar()
        self.opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
        self.opener.addheaders = [('User-agent', 'MFBot/1.0')]

        self.log = logging.getLogger('MFBot')
        self.dept = dept
        self.url = BASE_URL + dept
        self.status = 1
        self.get_content()

    def get_content(self):
        """
        Download page and extract the interesting part with the
        div #bulletinNeigeMontagne.
        """
        resp = self.opener.open(self.url)
        if resp.getcode() != 200:
            self.status = 0
            self.log.error('%s - page not available', self.dept)
            return

        content = resp.read().decode('iso-8859-1', 'replace')
        page = html.fromstring(content,
                               base_url='http://france.meteofrance.com/')
        self.nivo_content = page.get_element_by_id("bulletinNeigeMontagne")
        self.synth_content = page.cssselect("#bulletinSyntheseMontagne .bulletinText")

    def send_nivo_images(self, recipient, method='smtp'):
        """
        Add images as attachment to the message and reference it in the html part.
        """

        img_list = self.nivo_content.cssselect('img')
        if not img_list:
            self.log.debug("%s nivo images - pas d'images", self.dept)
            return

        # generate the <img> codes for each image
        img_code = '<img src="cid:image{id}"><br>'
        html_content = ""
        for i in range(len(img_list)):
            html_content += img_code.format(id=i + 1)

        bulletin_html = HTML_TPL.format(content=html_content, bulletin_type=TITLE_NIVO,
                                        dept=self.dept, full_url=self.url)
        bulletin_txt = TXT_TPL.format(content=CONTENT_NIVO, bulletin_type=TITLE_NIVO,
                                      dept=self.dept, full_url=self.url)
        subject = SUBJECT_TPL.format(bulletin_type=TITLE_NIVO, dept=self.dept)

        m = Mail(recipient, bulletin_txt, bulletin_html, subject)

        img_src = []

        for i, im in enumerate(img_list):
            im.make_links_absolute()
            src = im.get('src')
            img_src.append(os.path.basename(src))
            resp = self.opener.open(src)

            if resp.getcode() != 200:
                self.log.error('%s - cannot retrieve %s', self.dept, src)
                continue

            # Open the files in binary mode. Let the MIMEImage class
            # automatically guess the specific image type.
            msg_image = MIMEImage(resp.read())

            # Define the image's ID as referenced above
            msg_image.add_header('Content-ID', '<image{id}>'.format(id=i + 1))
            m.attach(msg_image)

        try:
            with open(STORE_NIVO, 'r') as f:
                img_ref = json.load(f)
        except IOError:
            img_ref = {}

        if (self.dept in img_ref and
            len(img_ref[self.dept]) == len(img_src) and
            img_ref[self.dept] == img_src):
            self.log.info('%s nivo images - No change - Nothing to do', self.dept)
        else:
            if (len(img_list) > 0):
                # images changed -> send the mail and store new image names
                self.log.info('%s nivo images - Sending mail', self.dept)
                m.send(method=method)

                img_ref[self.dept] = img_src
                with open(STORE_NIVO, 'w') as f:
                    json.dump(img_ref, f)
            else:
                self.log.info('%s nivo images - No images - Nothing to do', self.dept)

    def send_nivo_text(self, recipient, method='smtp'):
        """
        Send text bulletin when it replaces image bulletin
        """

        nivo_html = html.tostring(self.nivo_content,
                                   encoding='iso-8859-1').decode('utf-8')

        if re.match('.*Pas de bulletin disponible pour ce lieu.*', nivo_html):
            self.log.debug('%s nivo text - pas de bulletin', self.dept)
            return

        nivo_html = nivo_html.replace('<div id="bulletinNeigeMontagne">', '')
        nivo_html = re.sub(r'<a.*?</a>', r'', nivo_html)
        nivo_html = re.sub(r'<h3.*?</h3>', r'', nivo_html)
        nivo_html = re.sub(r'<div.*?</div>', r'', nivo_html)
        nivo_html = nivo_html.replace('</div>', '')
        nivo_html = re.sub(r'<t.*?>', r'', nivo_html)
        nivo_html = re.sub(r'</t.*?>', r'', nivo_html)
        nivo_html = re.sub(r'<!--', r'', nivo_html)
        nivo_html = re.sub(r'-->', r'', nivo_html)
        nivo_html = re.sub(r'(<br\s*/?>\s*){3,}', r'<br>', nivo_html)
        nivo_txt = re.sub(r'<br\s*/?>', r'\n', nivo_html)

        if len(nivo_txt) > 300:
            bulletin_html = HTML_TPL.format(content=nivo_html,
                                            bulletin_type=TITLE_NIVO,
                                            dept=self.dept, full_url=self.url)

            bulletin_txt = TXT_TPL.format(content=nivo_txt,
                                          bulletin_type=TITLE_NIVO,
                                          dept=self.dept, full_url=self.url)

            subject = SUBJECT_TPL.format(bulletin_type=TITLE_NIVO, dept=self.dept)

            m = Mail(recipient, bulletin_txt, bulletin_html, subject)

            try:
                with open(STORE_NIVO_TEXT, 'r') as f:
                    nivo_ref = json.load(f)
            except IOError:
                nivo_ref = {}

            if (self.dept in nivo_ref and
                len(nivo_ref[self.dept]) == len(nivo_txt) and
                nivo_ref[self.dept] == nivo_txt):
                self.log.info('%s nivo text - No change - Nothing to do', self.dept)
            else:
                # text changed -> send the mail and store new text
                self.log.info('%s nivo text - Sending mail', self.dept)
                m.send(method=method)

                nivo_ref[self.dept] = nivo_txt
                with open(STORE_NIVO_TEXT, 'w') as f:
                    json.dump(nivo_ref, f)
        else:
            self.log.info('%s nivo text - Empty text - Nothing to do', self.dept)

    def send_synth_text(self, recipient, method='smtp'):
        """
        Send weekly synthesis.
        """

        if not self.synth_content:
            self.log.debug('%s synth - No content', self.dept)
            return

        synth_html = html.tostring(self.synth_content[0],
                                   encoding='iso-8859-1').decode('utf-8')
        synth_html = synth_html.replace('<div class="onlyText bulletinText">', '')
        synth_html = synth_html.replace('</div>', '')
        synth_txt = re.sub(r'<br\s*/?>', r'\n', synth_html)

        if len(synth_txt) > 300:
            bulletin_html = HTML_TPL.format(content=synth_html,
                                            bulletin_type=TITLE_SYNTH,
                                            dept=self.dept, full_url=self.url)

            bulletin_txt = TXT_TPL.format(content=synth_txt,
                                          bulletin_type=TITLE_SYNTH,
                                          dept=self.dept, full_url=self.url)

            subject = SUBJECT_TPL.format(bulletin_type=TITLE_SYNTH, dept=self.dept)

            m = Mail(recipient, bulletin_txt, bulletin_html, subject)

            try:
                with open(STORE_SYNTH, 'r') as f:
                    synth_ref = json.load(f)
            except IOError:
                synth_ref = {}

            if (self.dept in synth_ref and
                len(synth_ref[self.dept]) == len(synth_txt) and
                synth_ref[self.dept] == synth_txt):
                self.log.info('%s synth - No change - Nothing to do', self.dept)
            else:
                # text changed -> send the mail and store new text
                self.log.info('%s synth - Sending mail', self.dept)
                m.send(method=method)

                synth_ref[self.dept] = synth_txt
                with open(STORE_SYNTH, 'w') as f:
                    json.dump(synth_ref, f)
        else:
            self.log.info('%s synth - Empty text - Nothing to do', self.dept)


def main():
    "Main function with arguments parsing."

    parser = argparse.ArgumentParser(description="Send Meteofrance's snow bulletins.")
    parser.add_argument('-m', '--smtp-method', action='store',
                        dest='smtp_method', default='smtp',
                        help='Method to send mail: `smtp` or `msmtp`.')
    parser.add_argument('-t', '--to', action='store', dest='recipient',
                        help='Recipient of the mail (useful for tests).')
    parser.add_argument('-p', '--print-log', action='store_true')

    args = parser.parse_args()

    # logging config
    logger = logging.getLogger('MFBot')

    if args.print_log:
        handler = logging.StreamHandler(stream=sys.stdout)
    else:
        handler = logging.handlers.SysLogHandler(address='/dev/log')

    formatter = logging.Formatter('%(name)25s - %(levelname)s - %(message)s')
    handler.setFormatter(formatter)

    logger.setLevel(logging.DEBUG)
    logger.addHandler(handler)

    for dept in DEPT_LIST:
        if args.recipient:
            recipient = args.recipient
        else:
            recipient = "meteofrance-%s@lists.camptocamp.org" % dept.replace('DEPT', '')

        bot = MFBot(dept)

        if bot.status:
            bot.send_nivo_images(recipient, method=args.smtp_method)
            bot.send_nivo_text(recipient, method=args.smtp_method)
            bot.send_synth_text(recipient, method=args.smtp_method)


if __name__ == '__main__':
    main()
