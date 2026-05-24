#
#indx#	Makefile - (VERY brief explanation of what this file is/does)
#@HDR@	$Id$
#@HDR@
#@HDR@	Copyright (c) 2024-2026 Christopher Caldwell (Christopher.M.Caldwell0@gmail.com)
#@HDR@
#@HDR@	Permission is hereby granted, free of charge, to any person
#@HDR@	obtaining a copy of this software and associated documentation
#@HDR@	files (the "Software"), to deal in the Software without
#@HDR@	restriction, including without limitation the rights to use,
#@HDR@	copy, modify, merge, publish, distribute, sublicense, and/or
#@HDR@	sell copies of the Software, and to permit persons to whom
#@HDR@	the Software is furnished to do so, subject to the following
#@HDR@	conditions:
#@HDR@	
#@HDR@	The above copyright notice and this permission notice shall be
#@HDR@	included in all copies or substantial portions of the Software.
#@HDR@	
#@HDR@	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
#@HDR@	KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
#@HDR@	WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
#@HDR@	AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
#@HDR@	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
#@HDR@	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#@HDR@	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
#@HDR@	OTHER DEALINGS IN THE SOFTWARE.
#
#hist#	2026-05-24 - Christopher.M.Caldwell0@gmail.com - Created
########################################################################
#doc#	(Less brief explanation of what this file is/does)
########################################################################
TOP=$(shell echo $(CURDIR) | sed -e 's+/Tests/.*+/Tests+')
include $(TOP)/src/Makefile.tests

DUSTINS_APPS=Sectionals Acronyms Azimuth Phonetics Headings FAR_91
AIRPLANE_PNM=$(TOP)/src/graphics/airplane.pnm
DUSTINS_CSS=$(TOP)/src/Dustins.css
Xs=75 76 77 78 79 80 81 82 83 84
Ys=200 201 202 203 204 205 206 207 208

setup_dustin:
	for app in $(DUSTINS_APPS) ; do \
	    name=`expr $$app | tr _ ' '` ; \
	    echo "setcolor black;" > $$app.cmds ; \
	    for x in $(Xs) ; do \
	        for y in $(Ys) ; do \
		    echo "setpos $$x $$y; setcolor black; text_here 80 0 \"$$name\";" ; \
		done ; \
	    done >> $$app.cmds ; \
	    ppmdraw -scriptfile=$$app.cmds < $(AIRPLANE_PNM) > $$app.pnm ; \
	    rm -f $$app.css; \
	    ln $(DUSTINS_CSS) $$app.css ; \
	done
	echo end

