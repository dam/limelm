# limelm

A Ruby API wrapper for the LimeLM API. LimeLM is a powerfull Licence and Online Activation Manager. For more information, see: http://wyday.com/limelm/

Documentation for the LimeLM API can be found here: https://wyday.com/limelm/help/api/

## Setup

	gem install limelm

Or with bundler,

```ruby
gem "limelm"
```	

Before using the library, you must initialize it with your LimeLM API key. If you're using Rails, put this code in an initializer:

```ruby
LimeLm.configure(api_key: 'YOUR_API_KEY')
```

If you are working with an unique version of a Product, you can set it during the configuration: 

```ruby
LimeLm.configure(api_key: 'YOUR_API_KEY', version_id: 'YOUR_PRODUCT_VERSION_ID')
```

## Usage example

Find all the keys that matching a specific product version (cf. version_id parameter) and a specific user via its registered email:

```ruby 
LimeLm::Key.find('imberdis.damien@gmail.com', version_id: '1')
```

## API endpoints not developed yet
* [deactivate a specific activation](https://wyday.com/limelm/help/api/limelm.pkey.deactivate/)
* [manual offline activation of a key](https://wyday.com/limelm/help/api/limelm.pkey.manualActivation/)
* [manual offline deactivation of a key](https://wyday.com/limelm/help/api/limelm.pkey.manualDeactivation/)
* [trial extension CRUD operation](https://wyday.com/limelm/help/api/)
* [Gets the activity of a product version between a date range](https://wyday.com/limelm/help/api/limelm.pkey.activity/)
* [Remove a tag from all product keys](https://wyday.com/limelm/help/api/limelm.tag.delete/)

## Contribute to limelm
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

### Testing

All tests can be run by the command `rake spec`. By default, all the API requests are mocked by web fixtures. 

As LimeLM not providing yet a demo environment, you will need to use your own product version to implement new functionalities:

* create a conf.yml file under the project root directory that will containes your personal `api_ key` and `version_id`.
* nether share that file via your source control tool.
* write new test (cf. other tests as examples on how to use VCR for mocking the HTTP requests), launch them with the command `rake spec MODE=live`.
* Once VCR generated the fixtures, anonymize them (replace every api_key, version_id, key ids and values by fake data).


## Disclaimer

This project and the code therein was not created by and is not supported by WyDay, Inc or any of its affiliates.

## Copyright

Copyright (c) 2015 Damien Imberdis. See LICENSE.txt for
further details.

