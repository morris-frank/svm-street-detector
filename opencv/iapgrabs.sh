#!/bin/bash

for s in seq000{0..4} seq0009 seq0010; do
	python2.7 grabcut.py "$s" &
done

for s in seq0000 seq000{5..9} seq0010; do
	python2.7 grabcut1.py "$s" &
done
