# Copyright (c) 2018 Marc Rehmsmeier
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

PREFIX ?= /usr/local
LIBDIR ?= $(PREFIX)/lib
EXTENSIONDIR ?= $(LIBDIR)/password-store/extensions
MANDIR ?= $(PREFIX)/share/man
DESTDIR ?=

install:
	install -d "$(DESTDIR)$(EXTENSIONDIR)"
	install -d "$(DESTDIR)$(MANDIR)/man1"
	install export.bash "$(DESTDIR)$(EXTENSIONDIR)/"
	install -m 644 pass-export.1 "$(DESTDIR)$(MANDIR)/man1/"

uninstall:
	rm "$(DESTDIR)$(EXTENSIONDIR)/export.bash"
	rm "$(DESTDIR)$(MANDIR)/man1/pass-export.1"

test:
	@pass export --version > /dev/null 2>&1 && \
	echo "test passed" || \
	echo "test failed" >&2

.PHONY: install uninstall test

