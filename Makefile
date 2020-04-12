# The MIT License (MIT)
#
# Copyright (c) 2020 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

all: install search clone copy filter calc summary draw article

install:
	bundle update
	python3 -m pip install -r requirements.txt

clean:
	rm -rf *.tex
	rm -rf repos.txt
	rm -rf summary.csv
	rm -rf clones
	rm -rf copies
	cd paper; latexmk -c

search:
	ruby find-repos.rb | tee repos.txt

clone:
	while read line; do \
		p="clones/$${line}"; \
		if [ -e "$${p}/.git" ]; then \
			echo "$${p} already here"; \
		else \
			mkdir -p "$${p}"; \
			git clone --depth=1 "https://github.com/$${line}" "$${p}"; \
		fi \
	done < repos.txt

copy:
	for d in $$(find clones -depth 2 -type directory); do \
		p=$${d/clones/copies}; \
		if [ -e "$${p}/.git" ]; then \
			echo "$${p} already here"; \
		else \
			echo "Copying $${p}..."; \
			mkdir -p "$${p}"; \
			cp -R "$${d}"/* "$${p}"; \
		fi \
	done

filter:
	find copies -type file -not -name '*.java' -exec rm "{}" \;
	find copies -type file -name '*Test.java' -exec rm "{}" \;
	find copies -type file -name 'package-info.java' -exec rm "{}" \;

uncalc:
	find copies -type file -name '*.java.m' -exec rm "{}" \;

calc:
	for f in $$(find copies -type file -name '*.java'); do \
		p="$${f}.m"; \
		if [ ! -e "$${p}" ]; then \
			python3 calc.py "$${f}" > "$${p}" || rm "$${f}"; \
		fi \
	done

summary:
	rm -rf summary.csv
	for f in $$(find copies -type file -name '*.java.m'); do \
		cat "$${f}" >> summary.csv; \
	done
	echo "There are $$(wc -l < summary.csv) Java classes measured"

draw: summary.csv
	ruby draw.rb --max-ncss=1000 --circle-size=8 --summary=summary.csv > paper/ncss.tex
	echo "\\\def\\\thetotaljavafiles{$$(wc -l < summary.csv)}" > paper/total.tex
	echo "\\\def\\\thetotalrepos{$$(find clones -depth 2 -type directory | wc -l)}" >> paper/total.tex
	echo "\\\def\\\thelargestncss{$$(cat summary.csv | awk  -F ',' '{print $$1}' | sort -n -r | head -1)}" >> paper/total.tex
	echo "\\\def\\\thebelowhundred{$$(cat summary.csv | awk  -F ',' '{ if ($$1 <= 100) { print } }' | wc -l)}" >> paper/total.tex

article: paper/ncss.tex paper/total.tex
	cd paper; latexmk -pdf article
