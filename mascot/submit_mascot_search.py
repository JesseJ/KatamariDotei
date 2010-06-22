#!/usr/bin/env python

import urllib
import urllib2
import cookielib
import mimetools, mimetypes
import os, stat
from cStringIO import StringIO
import os.path
from optparse import OptionParser
import sys
#import subprocess
import yaml

class Callable:
    """
    Support class used in construction of the post form string.
    """
    def __init__(self, anycallable):
        self.__call__ = anycallable

class MultipartPostHandler(urllib2.BaseHandler):
    """
    Support class used in construction of the post form string.
    ####
    # 02/2006 Will Holcomb <wholcomb@gmail.com>
    # 
    # This library is free software; you can redistribute it and/or
    # modify it under the terms of the GNU Lesser General Public
    # License as published by the Free Software Foundation; either
    # version 2.1 of the License, or (at your option) any later version.
    # 
    # This library is distributed in the hope that it will be useful,
    # but WITHOUT ANY WARRANTY; without even the implied warranty of
    # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    # Lesser General Public License for more details.
    #
    # 7/26/07 Slightly modified by Brian Schneider  
    # in order to support unicode files ( multipart_encode function )
    # 
    # Further modified by Rob Abernathy to include support for multiple selections in the multipart form data selection fields.
    # And correct format for radio buttons and check boxes.
    """
    handler_order = urllib2.HTTPHandler.handler_order - 10 # needs to run first

    def http_request(self, request):
        data = request.get_data()
        if data is not None and type(data) != str:
            v_files = []
            v_vars = []
            try:
                 for(key, value) in data.items():
                     if type(value) == file:
                         v_files.append((key, value))
                     else:
                         v_vars.append((key, value))
            except TypeError:
                systype, value, traceback = sys.exc_info()
                raise TypeError, "not a valid non-string sequence or mapping object", traceback

            if len(v_files) == 0:
                data = urllib.urlencode(v_vars, True)
            else:
                boundary, data = self.multipart_encode(v_vars, v_files)

                contenttype = 'multipart/form-data; boundary=%s' % boundary
                #if(request.has_header('Content-Type')
                #   and request.get_header('Content-Type').find('multipart/form-data') != 0):
                #    print "Replacing %s with %s" % (request.get_header('content-type'), 'multipart/form-data')
                request.add_unredirected_header('Content-Type', contenttype)

            request.add_data(data)
        
        return request

    def multipart_encode(vars, files, boundary = None, buf = None):
        if boundary is None:
            boundary = mimetools.choose_boundary()
        if buf is None:
            buf = StringIO()
        for(key, value) in vars:
            if type(value) == type([]):
                for vs in value:
                    buf.write('--%s\r\n' % boundary)
                    buf.write('Content-Disposition: form-data; name="%s"' % key)
                    buf.write('\r\n\r\n' + str(vs) + '\r\n')
            else:
                buf.write('--%s\r\n' % boundary)
                buf.write('Content-Disposition: form-data; name="%s"' % key)
                buf.write('\r\n\r\n' + str(value) + '\r\n')
        for(key, fd) in files:
            file_size = os.fstat(fd.fileno())[stat.ST_SIZE]
            filename = fd.name.split('/')[-1]
            contenttype = mimetypes.guess_type(filename)[0] or 'application/octet-stream'
            buf.write('--%s\r\n' % boundary)
            buf.write('Content-Disposition: form-data; name="%s"; filename="%s"\r\n' % (key, filename))
            buf.write('Content-Type: %s\r\n' % contenttype)
            fd.seek(0)
            buf.write('\r\n' + fd.read() + '\r\n')

        buf.write('--' + boundary + '--\r\n\r\n')
        buf = buf.getvalue()

        return boundary, buf

    multipart_encode = Callable(multipart_encode)

    https_request = http_request

def parse_options():
    # Command line options
    parser_ = OptionParser()

    parser_.add_option("-i", "--input_mgf", dest = "path_", default = '__Missing__', 
                       help = "Path to the input mgf file.")

    parser_.add_option("-c", "--config", dest = "config_", default = '__Missing__', 
                       help = "Path to configuration file.")

    parser_.add_option("-f", "--flip", action="store_true", dest="do_flip_", default=False,
                                        help="Use the flip database defined in the configuration file.")

    (options_, args_) = parser_.parse_args()

    if options_.path_ == '__Missing__':
        print "Error: You must specify the path to the input file."
        print "Use the -h or --help option."
        print "Aborting"
        exit()

    if options_.config_ == '__Missing__':
        print "Error: You must specify the path to the configuration file."
        print "Use the -h or --help option."
        print "Aborting"
        exit()

    return (options_.path_, options_.config_, options_.do_flip_)

def parse_config_file(cf_path, params, post_data, do_flip):
    """
    cf_path is the path to the config file. 
    params is a dictionary of parameter to feed the programs below.
    post_data is the data that will be added to the HTTP POST from the config file.
    """
    params['config_file'] = yaml.load(file(cf_path, 'r'))
    if 'Mascot' in params['config_file']:
        m_params = params['config_file']['Mascot']
        params['URL'] = m_params['URL']
        post_data['INTERMEDIATE'] = m_params['INTERMEDIATE']
        post_data['FORMVER'] = m_params['FORMVER']
        post_data['SEARCH'] = m_params['SEARCH']
        post_data['PEA'] = m_params['PEA']
        post_data['REPTYPE'] = m_params['REPTYPE']
        post_data['ErrTolRepeat'] = m_params['ErrTolRepeat']
        post_data['SHOWALLMODS'] = m_params['SHOWALLMODS']
        post_data['USERNAME'] = m_params['USERNAME']
        post_data['USEREMAIL'] = m_params['USEREMAIL']
        post_data['COM'] = m_params['COM']
        if do_flip:
            post_data['DB'] = m_params['Flip_DB']
        else:
            post_data['DB'] = m_params['DB']
        post_data['TAXONOMY'] = m_params['TAXONOMY']
        post_data['CLE'] = m_params['CLE']
        post_data['PFA'] = m_params['PFA']
        post_data['MODS'] = m_params['MODS']
        post_data['IT_MODS'] = m_params['IT_MODS']
        post_data['QUANTITATION'] = m_params['QUANTITATION']
        post_data['TOL'] = m_params['TOL']
        post_data['TOLU'] = m_params['TOLU']
        post_data['PEP_ISOTOPE_ERROR'] = m_params['PEP_ISOTOPE_ERROR']
        post_data['ITOL'] = m_params['ITOL']
        post_data['ITOLU'] = m_params['ITOLU']
        post_data['CHARGE'] = m_params['CHARGE']
        post_data['MASS'] = m_params['MASS']
        post_data['FORMAT'] = m_params['FORMAT']
        post_data['PRECURSOR'] = m_params['PRECURSOR']
        post_data['INSTRUMENT'] = m_params['INSTRUMENT']
        post_data['ERRORTOLERANT'] = m_params['ERRORTOLERANT']
        post_data['DECOY'] = m_params['DECOY']
        post_data['REPORT'] = m_params['REPORT']

def main():
    """
    If succesful, the routine returns 0 and prints the data file path to standard out.
    If not succesful, the entire html from mascot is printed and 1 is returned
    """
    (mgf, config, do_flip) = parse_options()

    params = {}
    post_data = {}
    parse_config_file(config, params, post_data, do_flip)

    cookies = cookielib.CookieJar()

    opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cookies), MultipartPostHandler)

    post_data ['FILE'] = open(mgf, "rb")

    f = opener.open(params['URL'], post_data)

    result = f.read()

    # Parse the results HTML to get errors or the path to the completed dat file.
    # The path from Mascot is returned in results in the form
    # <A HREF="../cgi/master_results.pl?file=../data/20090504/F041704.dat">Click here to see Search Report</A>

    have_dat_file = False
    dat_string = ''
    start_index = result.rfind('<A HREF=\"../cgi/master_results.pl?file=') + 39
    end_index = -1
    if start_index >= 0:
        end_index = result.find('\">', start_index)
        if end_index >= 0:
            dat_string = result[start_index:end_index]
            have_dat_file = True

    if have_dat_file:
        print dat_string
        return 0
    else:
        print result
        return 1

if __name__ == "__main__":
    return_val = main()
    sys.exit(return_val)
