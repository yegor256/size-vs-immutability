
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
	for d in $$(find . -depth 3 -type directory); do \
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

# metrics.csv:
# 	while read line; do ./parse.sh "$${parts[0]}"; \
# 	done < repos.txt

