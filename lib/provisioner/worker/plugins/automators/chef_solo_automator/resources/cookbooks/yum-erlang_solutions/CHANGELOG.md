# yum-erlang_solutions Cookbook CHANGELOG
This file is used to list changes made in each version of the yum-erlang_solutions cookbook.

## 1.0.0 (2016-09-06)
- Testing updates
- Resolve foodcritic warnings
- Add chef_version metadata
- Remove support for Chef 11

## v0.3.1 (2015-12-01)
- Removed an attribute case statement that caused the cookbook to fail on RHEL 7.X releases

## v0.3.0 (2015-12-01)
- Added dependency on yum-epel
- Added integration testing in Travis with kitchen-dokken

## v0.2.4 (2015-11-23)
- Fix setting bool false property values

## v0.2.3 (2015-10-28)
- Fixing Chef 13 nil property deprecation warnings

## v0.2.2 (2014-09-22)
- Add default['yum']['erlang_solutions']['managed'] attribute to control if the repository is managed. Defaults to true.
- Updated Test Kitchen config to 3.X format
- Add source_url and issues_url metadata
- Add supported platforms to metadata
- Update yum cookbook requirement from ~3.0 to ~3.2
- Update Chefspec format to 4.X
- Add contributing, testing, and maintainers docs
- Update cookbook name references in several places that were from the incorrect cookbook
- Update and add development dependencies in the Gemfile
- Add cookbook version and Travis CI badges to the readme
- Update requirements section in the Readme
- Add additional platforms to the Kitchen CI config
- Add Chef standard .rubocop config
- Add Chef standard chefignore and gitgnore files

## v0.2.0 (2014-02-14)
- Updated test harness

## v0.1.4
- Added CHANGELOG

## v0.1.0
- Initial release
