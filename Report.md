#Report

It took me a approximately a day and a half to develop app and write unit tests plus report.

##Key points
* App is developed using MVVM + Coordinator pattern 
* Support as low as iOS 9.0. There are no higher version of iOS used. Wider audience available.
* App supports dynamic types
* No external frameworks/libraries used 
* JSON format is used to store selected currency pair between app launch
* Unit tests focused on view models, since it's where primary business logic located (100% coverage for view models)

##Known limitations
* Localization. Currently all strings are hardcoded. Appropriate localization approach should be selected
* Proper errors reporting. At this point there is no value to show user why rates are not available (either no network issues, or wrong currency provide and "Wrong currency pair: XXXGBP" received, etc)
* Currency name and flags hardcoded. Would be nice to names into localization and flags to download some external service
