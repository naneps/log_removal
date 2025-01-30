# Changelog

## [1.1.2] - 2025-01-30
### Added
- **New Feature**: Added support for removing logs using custom function names without requiring manual regex input.
- **New Feature**: Added input validation to ensure user-provided log names are valid.


## [1.1.0] 2025-01-27
### Added
- Add documentation for codebase.
- Add support for selecting specific log patterns to remove.

### Change
- Updated README with detailed instructions on how to use the CLI tool.
- Added a section on how to run the program and select log patterns.
  

## [1.1.0] 2025-01-26
### Added
- Support for selecting specific log patterns to remove.
- Improved user interface with clearer instructions and options.
- Enhanced error handling and validation for user inputs.
- Display of processing status and completion message.
- Option to view the cleaned files and logs removed after processing.
- Support for custom regular expressions to remove logs.
- Updated README with detailed instructions on how to use the CLI tool.
  
### Changed
- Refactored codebase for better modularity and readability.
- Improved performance and efficiency of log removal operations.

## [1.0.0+1] 2025-01-25

  
### Changed
- Updated README with detailed instructions on how to use the CLI tool.

## [1.0.0] - 2025-01-25
### Added
- Initial release of `log_removal` CLI tool.
- Feature to remove unwanted logs from Dart and Flutter projects based on predefined or custom patterns.
- Support for selecting specific files, folders, or entire projects for log cleanup.
- Interactive CLI interface for selecting log patterns and file paths.
- Support for multi-pattern selection and custom regular expressions.
  
### Changed
- Initial setup with basic log removal functionality for common log patterns like `print`, `debugPrint`, and `logger.*`.

