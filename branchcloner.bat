@echo off
cd %~dp0
if defined RUBY_HOME set RUBY_BIN=%RUBY_HOME%\bin\
%RUBY_BIN%ruby branchcloner.rb %*