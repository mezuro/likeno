# Likeno

[![Build Status](https://travis-ci.org/mezuro/likeno.png?branch=master)](https://travis-ci.org/mezuro/likeno)
[![Code Climate](https://codeclimate.com/github/mezuro/likeno.png)](https://codeclimate.com/github/mezuro/likeno)
[![Test Coverage](https://codeclimate.com/github/mezuro/likeno/badges/coverage.svg)](https://codeclimate.com/github/mezuro/likeno)

Likeno is the Mezuro Team's take on RESTful APIs integration with Rails applications. It tries to mimic ActiveRecord's API.

Basically back in 2013, the Mezuro team was getting started with micro services. In order to keep the code clean and following Rails' standards we looked at [active_resource](https://github.com/rails/activeresource) and it proved to not fulfill our requirements about nested objects and [her](https://github.com/remiprev/her) which also has failed the same way. With those frustations in mind we started coding all the CRUD requests using `faraday_middleware` but still giving flexibility for custom requests whenever necessary. Likeno is the final product of this.


It's name come from the fact that by itself Likeno has no purpose at all. It only lives associated to another softwares, providing them with the necessary methods for RESTful APIs. So we can say that Likeno has a symbiosis relation with other applications. This leads us to lichens which are a good symbiosis example. As the Mezuro project has lots of Esperanto words, we finally get to Likeno: is the Esperanto word for lichen.

To know how to contribute, please refer to the [CONTRIBUTING](CONTRIBUTING.md) and [HACKING](HACKING.md) files, respectively.

## Installation

Add this line to your application's Gemfile:

    gem 'likeno'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install likeno

## Usage

Likeno provides default actions for communicating with Rails applications following the scaffold routes. All communication is assumed to use JSON. Specially have a look at the methods from `Likeno::Entity`:

* C `create`
* R `find` (retrieve)
* U `update`
* D `destroy`

Additionally we provide other useful methods:

* `save` and `save!`
* `to_hash`
* `==`


We hope to make available soon a full documentation on RDoc that will make easier to understand all this.

A good example on how to get everything from Likeno should be KalibroClient (https://github.com/mezuro/kalibro_client). So, have a look there for some examples.

### Custom Requests

Likeno allows the creation of custom requests. For example:

```ruby
class MyClass
  def my_custom_request(...)
    action = 'my_action'
    params = {}
    method = :get
    prefix = ''
    Likeno::Entity.request(action, params, method, prefix) # The path used will be '/my_classes/my_action'
  end
end
```

It returns a `hash` with the response body.

## Versioning

Likeno follows the [semantic versioning](http://semver.org/) policy.

### License

Copyright (c) 2013-2016 The [Author](AUTHORS) developers.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

### Authors

Please see the `likeno.gemspec` file with the authors.

### Acknowledgments

The authors have been supported by organizations:

University of São Paulo (USP)
FLOSS Competence Center
http://ccsl.ime.usp.br

Brazilian National Research Council (CNPQ)
http://www.cnpq.br/

University of Brasilia (UnB)
Faculdade UnB Gama
https://fga.unb.br/
https://softwarepublico.gov.br/social/
