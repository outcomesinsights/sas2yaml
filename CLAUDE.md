# sas2yaml

> Ruby gem that converts SAS INPUT statements into YAML/JSON/CSV/SQL describing fixed-width file layouts.

## Status

- **Active**
- Last meaningful work: 2026-02

## Tech Stack

- Language: Ruby (>= 3.2)
- Framework: Rake, Bundler, Minitest
- Key dependencies: csv, logger (bundled gems)

## Purpose

Parses SAS INPUT statements (used to define fixed-width file layouts) and extracts field metadata including column position, length, and type. Originally developed to decipher SEER Medicare SAS input statement files. Works by translating SAS code into executable Ruby code via eval.

## Key Entry Points

- `exe/sas2yaml` - CLI executable
- `Sas2Yaml.parse(file_path)` - Parse a SAS file and return a Layout object
- `Sas2Yaml.parse_string(sas_content)` - Parse SAS content from a string
- `SasProcessor` - Translates SAS code to Ruby code
- `Sassifier` - Evals the generated Ruby to extract field definitions
- `Layout` - Represents parsed fields with validation and output formatting

## Commands

```bash
bundle install                          # Install dependencies
bundle exec rake test                   # Run tests
bundle exec sas2yaml file.sas           # Convert SAS to YAML (default)
bundle exec sas2yaml -f json file.sas   # Convert to JSON
bundle exec sas2yaml -f csv file.sas    # Convert to CSV
bundle exec sas2yaml -f sql file.sas    # Generate CREATE TABLE SQL
```

## Relationships

- **Depends on**: None
- **Feeds into**: Likely used by other projects processing SEER Medicare or similar fixed-width healthcare data files

## Domain Concepts

- **INPUT statement**: SAS syntax defining how to read fixed-width data files
- **Field/Column**: A data element with name, position, length, and type
- **Format string**: SAS type notation like `$char2.` (2-char string), `10.` (integer), `15.2` (decimal)
- **LRECL**: Logical record length - total bytes per record in fixed-width file
