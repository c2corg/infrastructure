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
import os
import smtplib
import urllib2

from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.utils import formatdate

from lxml import html
from lxml.html.clean import Cleaner

# config

BASE_URL = "http://france.meteofrance.com/france/MONTAGNE?MONTAGNE_PORTLET.path=montagnebulletinneige/"
WORK_DIR = "/var/cache/meteofrance/"
LOGFILE = WORK_DIR + 'meteofrance.log'
SENDER = 'nobody@lists.camptocamp.org'
STORE = WORK_DIR + 'meteofrance.json'
DEPT_LIST = ["DEPT74", "DEPT73", "DEPT38", "DEPT04", "DEPT05", "DEPT06",
             "DEPT2A", "DEPT2B", "DEPT66", "DEPT31", "DEPT09", "ANDORRE",
             "DEPT64", "DEPT65"]

TXT_TPL = u"""
Le bulletin neige et avalanche est constitué d'images, celles-ci sont en pièce
jointe ou dans la version html de ce mail.

--
Ce bulletin d'avalanche est rédigé par MétéoFrance (http://www.meteo.fr/).
La liste de diffusion est gérée par Camptocamp-association (http://www.camptocamp.org).

Pour ne plus recevoir de bulletin par email, rendez vous à l'adresse suivante:
http://www.camptocamp.org/users/mailinglists
"""

HTML_TPL = u"""
<html>
<head></head>
<body>
  <h1>Bulletin neige et avalanche - {dept}</h1>
  <p>{content}</p>
  <div>
  <p>Ce bulletin d'avalanche est rédigé par
  <a href="http://www.meteo.fr/">MétéoFrance</a>.<br>
  La liste de diffusion est gérée par
  <a href="http://www.camptocamp.org/">Camptocamp-association</a>.</p>
  <p>Pour ne plus recevoir de bulletin par email, rendez vous à l'adresse suivante:
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
    def __init__(self, recipient, text_content, html_content, add_subject='',
                 encoding='iso-8859-1'):
        "Create the message container and add text and html content"

        self.recipient = recipient

        self.msg = MIMEMultipart('related')
        self.msg['From'] = SENDER
        self.msg['To'] = recipient
        self.msg['Date'] = formatdate(localtime=True)
        self.msg.preamble = 'This is a multi-part message in MIME format.'

        if add_subject:
            self.msg['Subject'] = "Bulletin neige et avalanche - " + add_subject
        else:
            self.msg['Subject'] = "Bulletin neige et avalanche"

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
            logging.error('%s - page not available', self.dept)
            return

        content = resp.read().decode('iso-8859-1', 'replace')
        page = html.fromstring(content,
                               base_url='http://france.meteofrance.com/')
        self.content = page.get_element_by_id("bulletinNeigeMontagne")

    def send_full_html(self, recipient, method='smtp'):
        """
        Send the full html code after fixing relative urls and cleaning up
        useless html code for area & maps.
        """

        self.content.make_links_absolute()
        bulletin_html = html.tostring(self.content,
                                      encoding='iso-8859-1').decode('utf-8')
        bulletin_txt = html.tostring(self.content, method='text',
                                     encoding='iso-8859-1').decode('utf-8')

        cleaner = Cleaner(style=True, safe_attrs_only=True,
                          remove_tags=['area', 'map'])
        bulletin_html = cleaner.clean_html(bulletin_html)

        m = Mail(recipient, bulletin_txt, bulletin_html, add_subject=self.dept)
        m.send(method=method)

    def send_images(self, recipient, method='smtp'):
        """
        Add images as attachment to the message and reference it in the html part.
        """

        img_list = self.content.cssselect('img')

        # generate the <img> codes for each image
        img_code = '<img src="cid:image{id}"><br>'
        html_content = ""
        for i in range(len(img_list)):
            html_content += img_code.format(id=i + 1)

        bulletin_html = HTML_TPL.format(content=html_content, dept=self.dept)

        m = Mail(recipient, TXT_TPL, bulletin_html, add_subject=self.dept)

        img_src = []

        for i, im in enumerate(img_list):
            im.make_links_absolute()
            src = im.get('src')
            img_src.append(os.path.basename(src))
            resp = self.opener.open(src)

            if resp.getcode() != 200:
                logging.error('%s - cannot retrieve %s', self.dept, src)
                continue

            # Open the files in binary mode. Let the MIMEImage class
            # automatically guess the specific image type.
            msg_image = MIMEImage(resp.read())

            # Define the image's ID as referenced above
            msg_image.add_header('Content-ID', '<image{id}>'.format(id=i + 1))
            m.attach(msg_image)

        try:
            with open(STORE, 'r') as f:
                img_ref = json.load(f)
        except IOError:
            img_ref = {}

        if (self.dept in img_ref and
            len(img_ref[self.dept]) == len(img_src) and
            img_ref[self.dept] == img_src):
            logging.info('%s - Nothing to do', self.dept)
        else:
            # images changed -> send the mail and store new image names
            logging.info('%s - Sending mail', self.dept)
            m.send(method=method)

            img_ref[self.dept] = img_src
            with open(STORE, 'w') as f:
                json.dump(img_ref, f)


def main():
    "Main function with arguments parsing."

    parser = argparse.ArgumentParser(description="Send Meteofrance's snow bulletins.")
    parser.add_argument('-m', '--smtp-method', action='store',
                        dest='smtp_method', default='smtp',
                        help='Method to send mail: `smtp` or `msmtp`.')
    parser.add_argument('-t', '--to', action='store', dest='recipient',
                        help='Recipient of the mail (useful for tests).')
    args = parser.parse_args()

    logging.basicConfig(filename=LOGFILE, level=logging.DEBUG,
                        format='%(asctime)s - %(levelname)s - %(message)s')

    for dept in DEPT_LIST:
        if args.recipient:
            recipient = args.recipient
        else:
            recipient = "meteofrance-%s@lists.camptocamp.org" % dept.replace('DEPT', '')

        bot = MFBot(dept)

        if bot.status:
            bot.send_images(recipient, method=args.smtp_method)


if __name__ == '__main__':
    main()
