
install:
	bundle update
	python3 -m pip install -r requirements.txt

all: search clone copy filter calc summary

clean:
	rm -rf repos.txt
	rm -rf summary.csv
	rm -rf clones
	rm -rf copies

search:
	ruby find-repos.rb | tee repos.txt

clone:
	while read line; do \
		p="clones/$${line}"; \
		if [ -e "$${p}" ]; then \
			echo "$${p} already here"; \
		else \
			mkdir -p "$${p}"; \
			git clone --depth=1 "https://github.com/$${line}" "$${p}"; \
		fi \
	done < repos.txt

copy:
	for d in $$(find clones -depth 2 -type directory); do \
		p=$${d/clones/copies}; \
		echo "$${p}"; \
		if [ -e "$${p}" ]; then \
			echo "$${p} already here"; \
		else \
			mkdir -p "$${p}"; \
			cp -R "$${d}"/* "$${p}"; \
		fi \
	done

filter:
	find copies -type file -not -name '*.java' -exec rm {} \;
	find copies -type file -name '*Test.java' -exec rm {} \;

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

