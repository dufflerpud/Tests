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
# Makefile to create American Board of Family Medicine

PDFDIR=src
ABFM_DESTDIR=/home/chris/public_html/abfm_test
#ABFM_DESTDIR=$(DESTDIR)

VPATH += $(PDFDIR)

ALL_TESTS = $(shell ls $(PDFDIR))
ALL_HTMLS = $(foreach T,$(ALL_TESTS),$(ABFM_DESTDIR)/$(T).html)
ALL_ATLAS_YEARS = $(shell ls $(PDFDIR)/*/*Atlas* | sed -e "s+$(PDFDIR)/++" -e "s+/.*++")
ALL_JPEGS = $(foreach J,$(ALL_ATLAS_YEARS),$(ABFM_DESTDIR)/$(J)-1.jpg)
ALLDESTS += $(ALL_HTMLS) $(ALL_JPEGS)

#ALLDESTS += $(foreach F,$(wildcard *IteMultChoice.pdf),$(ABFM_DESTDIR)/$(F:IteMultChoice.pdf=.html)) $(foreach F,$(wildcard *IteAtlas.pdf),$(ABFM_DESTDIR)/$(F:IteAtlas.pdf=-1.jpg))

TOP=$(shell echo $(CURDIR) | sed -e 's+/Tests/.*+/Tests+')
include $(TOP)/src/Makefile.tests

$(ABFM_DESTDIR)/%.html:	%.xml.todel
	@[ -d $(ABFM_DESTDIR) ] || mkdir -p $(ABFM_DESTDIR)
	$(XML_TO_QUIZ) < $< > $@

%.xml.todel:		abfm.pl $(PDFDIR)/%/exam.pdf $(PDFDIR)/%/answers.pdf
	./$^ $@
	@cp $@ $@.save

# OK, this would be *SO* much simpler if pdfimages produced files that
# ended with ...-1.jpg instead of ...-000.jpg.  It would also be simpler
# if the 2009 Atlas didn't have 2 images each associated with figures 4 and 9.
# If both had been true, this rule could have been:
#	pdfimages -j $< `echo $@ | sed -e 's+-1.jpg++'`
# Instead, we get:
$(ABFM_DESTDIR)/%-1.jpg:	$(PDFDIR)/%/Atlas.pdf
	rm -f tmpgrph-*
	pdfimages -j $< tmpgrph
	if [ "$<" = "$(PDFDIR)/2009/Atlas.pdf" ] ; then \
	    pnmcat -lr tmpgrph-003.ppm tmpgrph-004.ppm > tmpgrph-003a.ppm; \
	    pnmcat -lr tmpgrph-009.ppm tmpgrph-010.ppm > tmpgrph-009a.ppm; \
	    rm -f tmpgrph-003.ppm tmpgrph-004.ppm tmpgrph-009.ppm tmpgrph-010.ppm; \
	fi
	n=1; \
	    for f in tmpgrph-*; do \
	        d=`echo $@ | sed -e "s/-1.jpg/-$$n.jpg/"`; \
		case "$$f" in \
		    *.jpg)		mv $$f $$d		;; \
		    *.ppm|*.pnm)	pnmtojpeg $$f > $$d	;; \
		esac; \
		n=`expr $$n + 1`; \
	    done
	rm -f tmpgrph-*
