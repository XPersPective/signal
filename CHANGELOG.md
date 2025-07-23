## [2.0.1] - 2025.07.23

* Added `_disposed` flag to Signal class to prevent multiple dispose calls.
* Fixed a potential Future error when calling dispose more than once.

## [2.0.0] - 2025.07.20

* Complete rewrite of the signal package with modern architecture
* Renamed from Channel/BaseState to Signal for better clarity
* Added comprehensive documentation and examples
* Improved async operation handling with setState method
* Enhanced type safety and performance optimization
* Added SignalProvider and SignalBuilder widgets
* Built-in loading states, error handling, and success states
* Streamlined API with better lifecycle management
* Breaking changes: Complete API redesign for better developer experience

## [1.1.6] - 2022.05.24

* basestate added.
* Fixed a non-nullable expression.

## [1.1.0] - 2021.06.25

* Updated the setState method of the BaseState package.
 
## [1.0.0] - 2021.04.25

* migrated to null safety.
* AncestorChannelProvider => ChannelProvider 
* AncestorChannelBuilder => ChannelBuilder 
* AvailableChannelBuilder => deprecated
* OwnChannelBuilder => deprecated

## [0.2.2+1] - 2020.09.12

* Formatting corrected..

## [0.2.2] - 2020.09.12

* Exported "BaseLifeCycle.dart".

## [0.2.1] - 2020.08.13

* Formatting corrected..

## [0.2.0] - 2020.08.13

* BaseLifeCycle added.
* child option added.formatting corrected.
* new example added.

## [0.1.2] - 2020.08.8

* Bad state bug fixed.

## [0.1.1] - 2020.07.15

* Minor bugs and format fixed.

## [0.1.0] - 2020.07.12

* The initState method has been added to the StateChannel class.
* SetState, initState, dispose methods have been added to the BaseState class.
* 'signal' option has been added to wait, doneSucces, doneError methods of BaseState class.

## [0.0.3] - 2020.06.30

* New description added.

## [0.0.2] - 2020.06.30

* New description added.

## [0.0.1] - 2020.06.30

* TODO: Describe initial release.
