go () {
  pulp build -O -m $1 | ./node_modules/.bin/uglifyjs > docs/_static/$2
  gzip -9 -c docs/_static/$2 > docs/_static/$2.gz
}

go Examples.Basic.Counter examplesBasicCounter.js
go Examples.Basic.Animation examplesBasicAnimation.js
