# Copyright (C) 2012-2014 Zammad Foundation, http://zammad-foundation.org/

class UserAccessTokenController < ApplicationController
  before_action { authentication_check(permission: 'user_preferences.access_token') }

  def index
    tokens = Token.where(action: 'api', persistent: true, user_id: current_user.id).order('updated_at DESC, label ASC')
    token_list = []
    tokens.each { |token|
      attributes = token.attributes
      attributes.delete('persistent')
      attributes.delete('name')
      token_list.push attributes
    }
    local_permissions = current_user.permissions
    local_permissions_new = {}
    local_permissions.each { |key, _value|
      keys = Object.const_get('Permission').with_parents(key)
      keys.each { |local_key|
        next if local_permissions_new[local_key]
        local_permissions_new[local_key] = false
      }
    }
    permissions = []
    Permission.all.order(:name).each { |permission|
      next if !local_permissions_new.key?(permission.name)
      permissions.push permission
    }

    render json: {
      tokens: token_list,
      permissions: permissions,
    }, status: :ok
  end

  def create
    if Setting.get('api_token_access') == false
      raise Exceptions::UnprocessableEntity, 'API token access disabled!'
    end
    if params[:label].empty?
      raise Exceptions::UnprocessableEntity, 'Need label!'
    end
    token = Token.create(
      action:      'api',
      label:       params[:label],
      persistent:  true,
      user_id:     current_user.id,
      preferences: {
        permission: params[:permission]
      }
    )
    render json: {
      name: token.name,
    }, status: :ok
  end

  def destroy
    token = Token.find_by(action: 'api', user_id: current_user.id, id: params[:id])
    raise Exceptions::UnprocessableEntity, 'Unable to find api token!' if !token
    token.destroy
    render json: {}, status: :ok
  end

end