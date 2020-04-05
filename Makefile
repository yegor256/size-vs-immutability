
install:
	bundle update
	python3 -m pip install -r requirements.txt

all: repos.txt clone filter

clean:
	rm -rf repos.txt

repos.txt:
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

filter:
	for d in $$(find clones -depth 2 -type directory); do \
		p=$${d/clones/filtered}; \
		echo "$${p}"; \
		if [ -e "$${p}" ]; then \
			echo "$${p} already here"; \
		else \
			mkdir -p "$${p}"; \
			cp -R "$${d}"/* "$${p}"; \
			find "$${p}" -type file -not -name '*.java' -exec rm {} \; ; \
		fi \
	done

metrics:
	for f in $$(find filtered -type file -name '*.java'); do \
		p="$${f}.m"; \
		if [ ! -e "$${p}" ]; then \
			python3 -m calc.py > "$${p}"; \
		fi \
	done

