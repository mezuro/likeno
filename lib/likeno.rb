# This file is part of Likeno. Copyright (C) 2013-2016 The Mezuro Team

# Likeno is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Likeno is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public License
# along with Likeno.  If not, see <http://www.gnu.org/licenses/>.

require 'yaml'
require 'logger'
require 'likeno/entity'

module Likeno
  @config = {}

  # Configure through hash
  def self.configure(opts = {})
    @config = Hash[opts.map { |name, address| [name.to_sym, address] }]
  end

  # Configure through yaml file
  def self.configure_with(path_to_yaml_file)
    begin
      @config = Psych.load_file path_to_yaml_file
    rescue Errno::ENOENT
      raise Errno::ENOENT, "YAML configuration file couldn't be found."
    rescue Psych::Exception
      raise Psych::Exception, 'YAML configuration file contains invalid syntax.'
    end

    configure(@config)
  end

  def self.config
    @config
  end
end
