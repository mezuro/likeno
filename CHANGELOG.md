# Revision history for the Likeno gem

Likeno is a library for remote data model access over HTTP

## Unreleased

* Drop Ruby older than 2.2.2 support
* Update README
* Create CONTRIBUTING and HACKING files

## v1.1.0 - 23/03/2016

* Generalize Hash conversion for non Likeno::Entity instances

## v1.0.1 - 23/03/2016

* Fix hash conversion

## v1.0.0 - 23/03/2016

* Add support for custom headers for requests
* Add prefixing support on exists and find methods
* Add new listing method all

## v0.0.1 - 21/03/2016

Imported from KalibroClient (http://github.com/mezuro/kalibro_client)

Features:

* Data model access over HTTP
  * Entity creation with POST
  * Entity updates with POST
  * Entity retrieval with GET
  * Entity deletion with DELETE
  * Methods for reading/writing to and from JSON and JSON arrays
  * Basic validation and error accumulation support
* Handling of basic HTTP errors with corresponding exceptions (in the errors module)
* Helpers for date conversions and parameter generations

---

Likeno.
Copyright (C) 2015-2016 The Mezuro Team

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
