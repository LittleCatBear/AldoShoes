# frozen_string_literal: true

class StoreInventoryController < ApplicationController
  def index
    @stores = Store.all
  end
end
