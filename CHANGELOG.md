# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0] - 2025-01-23

### Added
- Comprehensive Minitest test suite
- GitHub Actions CI workflow (Ruby 3.1, 3.2, 3.3)
- Sample SAS fixtures for testing

### Changed
- Renamed default branch from `master` to `main`
- Updated minimum Ruby version to 3.1
- Modernized gemspec with proper metadata URIs
- Updated development dependencies (bundler >= 2.0, rake >= 13.0)
- Fixed typo in DESCRIPTION ("into into" -> "into")

### Removed
- Travis CI configuration (replaced with GitHub Actions)

## [0.0.1] - 2015-09-30

### Added
- Initial release
- CLI tool for converting SAS input statements to YAML
- Support for SAS arrays, loops, and range expressions

[Unreleased]: https://github.com/outcomesinsights/sas2yaml/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/outcomesinsights/sas2yaml/compare/v0.0.1...v0.1.0
[0.0.1]: https://github.com/outcomesinsights/sas2yaml/releases/tag/v0.0.1
