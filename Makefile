# Makefile for running local jekyll site

help:
	@echo Run site locally
	@echo make run

install:
	bundle install

update:
	bundle update

run:
	bundle exec jekyll serve

.PHONY: help install update run
