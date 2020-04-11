# Makefile for running local jekyll site

help:
	@echo Run site locally
	@echo make run
	@echo make install
	@echo make update

install:
	bundle install

update:
	bundle update

run:
	bundle exec jekyll serve --drafts

.PHONY: help install update run
