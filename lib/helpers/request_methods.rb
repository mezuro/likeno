# This file is part of KalibroClient
# Copyright (C) 2013  it's respectives authors (please see the AUTHORS file)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

module RequestMethods
  def save_params
    {instance_class_name.underscore.to_sym => self.to_hash}
  end

  def save_action
    ""
  end

  def save_prefix
    ""
  end

  def destroy_action
    ":id"
  end
  alias_method :update_action, :destroy_action

  def destroy_params
    {id: self.id}
  end

  def destroy_prefix
    ""
  end

  def update_params
    {instance_class_name.underscore.to_sym => self.to_hash, :id => self.id}
  end

  def update_prefix
    ""
  end

  module ClassMethods
    def exists_action
      ":id/exists"
    end

    def id_params(id)
      {id: id}
    end

    def find_action
      ":id"
    end
  end
end
