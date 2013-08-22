import json
import sys
import csv
import urllib
import cookielib
import urllib2
from lxml import etree

class Divvy(object):
    def __init__(self):
        self.cookie_jar = cookielib.LWPCookieJar()

    def _post_with_cookie_jar(self, url, params):
        cookie = urllib2.HTTPCookieProcessor(self.cookie_jar)
        opener = urllib2.build_opener(cookie)
        req = urllib2.Request(url, urllib.urlencode(params))
        res = opener.open(req)
        return res

    def _get_with_cookie_jar(self, url):
        cookie = urllib2.HTTPCookieProcessor(self.cookie_jar)
        opener = urllib2.build_opener(cookie)
        req = urllib2.Request(url)
        res = opener.open(req)
        return res

    def login(self, username, password):
        post_data = dict(
            subscriberUsername=username,
            subscriberPassword=password
        )
        html_fl = self._post_with_cookie_jar('https://divvybikes.com/login', post_data)

        parser = etree.HTMLParser()
        tree = etree.parse(html_fl, parser)

        error_box = tree.xpath('//*[@id="content"]/div/div[1]/div')
        if error_box:
            raise Exception(error_box[0].text.strip())

    def get_rides(self):
        html_fl = self._get_with_cookie_jar('https://divvybikes.com/account/trips')

        parser = etree.HTMLParser()
        tree = etree.parse(html_fl, parser)

        table_rows = tree.xpath('//*[@id="content"]/div/table/tbody/tr')
        if table_rows and len(table_rows) == 1 and table_rows[0].xpath('td[@colspan="7"]') and table_rows[0].xpath('td[@colspan="7"]')[0].text.find("any bikes yet"):
            res = []
        else:
            res = []
            for row in table_rows:
                tds = row.xpath('td')

                endstation = tds[3].text
                if endstation == None:
                    endstation = ''

                res.append({
                    "start_station": tds[1].text,
                    "start_time": tds[2].text,
                    "end_station": endstation,
                    "end_time": str(tds[4].text),
                    "duration": tds[5].text,
                })

        return res

if __name__ == "__main__":
    d = Divvy()
    this_username = str(sys.argv[1])
    this_password = str(sys.argv[2])

    d.login(this_username, this_password)

    array = []
    for ride in d.get_rides():
        array.append(ride)
    
    print json.dumps(array)