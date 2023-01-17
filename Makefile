
valida: valida-js valida-ruby bundler-audit brakeman rubocop

valida-js:
	for i in `find app/assets/javascripts/ -name "*js" -or -name "*es6"`; do \
	node -c $$i; \
	done
	for i in `find app/assets/javascripts/ -name "*coffee"`; do \
	coffee -o /tmp/ $$i; \
	done

valida-ruby:
	find . -name "*\.rb" -exec ruby -w -W2 -c {} ';'

instala-gemas:
	grep "([0-9]" Gemfile.lock  | sed -e "s/^ */doas gem install /g;s/ (/ -v /g;s/)//g" > /tmp/i.sh
	doas chmod +x /tmp/i.sh
	doas /tmp/i.sh

erd:
	(cd test/dummy; \
	bundle exec erd)
	mv test/dummy/erd.pdf doc/
	convert doc/erd.pdf doc/erd.png

doc/dependencias.png: doc/dependencias.dot
	dot -Tpng doc/dependencias.dot  > doc/dependencias.png


bundler-audit:
	bin/bundler-audit

brakeman:
	bin/brakeman

rubocop:
	bin/rubocop

c_brakeman:
	bin/brakeman -I

c_rubocop:
	bin/rubocop -a



