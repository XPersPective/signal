# [3.0.1] - 2025-08-04

- Documentation and README improvements

## [3.0.0] - 2025-08-03

### Breaking Changes
* Major version release with enhanced architecture
* Improved Stream-based reactivity system
* Modernized API design for better developer experience
* Enhanced type safety and performance optimizations

### Added
* Production-ready signal system with comprehensive features
* Advanced debugging and monitoring capabilities
* Complete documentation and examples for pub.dev
* Professional-grade state management solution
* Enhanced error handling and lifecycle management

### Improved
* Signal provider architecture with better performance
* Memory management and disposal patterns
* Developer experience with cleaner API
* Documentation quality and completeness

### Fixed
* All known issues from previous versions
* Performance bottlenecks in signal updates
* Memory leaks in complex signal hierarchies

## [2.0.1] - 2025-07-22

### Added
* MultiSignalProvider for managing multiple signals efficiently
* signalItem<S> factory function for cleaner signal setup syntax
* SignalFactory typedef for improved type safety
* Comprehensive debug system with SignalDebugConfig and SignalDebugRegistry
* Debug panels and logging for development tools
* Performance monitoring and state tracking capabilities
* Professional documentation with modern examples

### Improved
* Stream-based reactivity architecture for better performance
* Widget discovery using findAncestorWidgetOfExactType for Stream integration
* Proper naming conventions following Dart lowerCamelCase standards
* Enhanced error handling and state management
* Memory management and disposal lifecycle
* Complete API documentation and usage examples

### Fixed
* Disposal flag to prevent multiple dispose calls
* Potential Future errors during disposal
* Widget tree integration issues with Stream-based updates
* Memory leaks in parent-child signal relationships

## [2.0.0] - 2025-07-20

* Complete rewrite of the signal package with modern architecture
* Renamed from Channel/BaseState to Signal for better clarity
* Added comprehensive documentation and examples
* Improved async operation handling with setState method
* Enhanced type safety and performance optimization
* Added SignalProvider and SignalBuilder widgets
* Built-in loading states, error handling, and success states
* Streamlined API with better lifecycle management
* Breaking changes: Complete API redesign for better developer experience

## [1.1.6] - 2022-05-24

* basestate added.
* Fixed a non-nullable expression.

## [1.1.0] - 2021-06-25

* Updated the setState method of the BaseState package.
 
## [1.0.0] - 2021-04-25

* migrated to null safety.
* AncestorChannelProvider => ChannelProvider 
* AncestorChannelBuilder => ChannelBuilder 
* AvailableChannelBuilder => deprecated
* OwnChannelBuilder => deprecated

## [0.2.2+1] - 2020-09-12

* Formatting corrected.

## [0.2.2] - 2020-09-12

* Exported "BaseLifeCycle.dart".

## [0.2.1] - 2020-08-13

* Formatting corrected.

## [0.2.0] - 2020-08-13

* BaseLifeCycle added.
* child option added.formatting corrected.
* new example added.

## [0.1.2] - 2020-08-08

* Bad state bug fixed.

## [0.1.1] - 2020-07-15

* Minor bugs and format fixed.

## [0.1.0] - 2020-07-12

* The initState method has been added to the StateChannel class.
* SetState, initState, dispose methods have been added to the BaseState class.
* 'signal' option has been added to wait, doneSucces, doneError methods of BaseState class.

## [0.0.3] - 2020-06-30

* New description added.

## [0.0.2] - 2020-06-30

* New description added.

## [0.0.1] - 2020-06-30

* TODO: Describe initial release.
