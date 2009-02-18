require File.dirname(__FILE__) + '/../../../../test/test_helper'

ActionView::Base.send :include, ActionView::Helpers::NestedLayoutsHelper

class TestController < ActionController::Base
  layout 'inner'
  
  def deep_layout
    render :action => "deep_layout", :layout => 'deep'
  end
  
  def shared_data
    @data1 = '123'
    @data2 = 'abc'
    render :action => "shared_data", :layout => 'shared_data_inner'

    #render :template => 'layouts/shared_data_inner'
  end
  
  def instance_passing
    render :action => "instance_passing", :layout => 'instance_inner'
    #render :template => 'layouts/instance_inner'
  end
  
  def content_for_passing
    render :action => "content_for_passing", :layout => 'content_for_inner'
    #render :template => 'layouts/content_for_inner'
  end

  def inline_layout
    @inline_layout = '<outer><%= yield %></outer>'
    render  :action => "inline_layout", :layout => "inline_inner"
    #render :action => @inline_layout, :layout => 'inline_inner'
   # render :template => 'layouts/inline_inner'
  end

  def simple
  end
end

TestController.view_paths = File.dirname(__FILE__) + '/fixtures'
#ActionController::Base.ignore_missing_templates = false
ActionController::Routing::Routes.draw do |map|
  map.connect '/:controller/:action'
end

class NestedLayoutsTest < Test::Unit::TestCase
  def setup
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @controller = TestController.new
  end
  
  def test_simple_outer_layout
    get :simple
    assert_equal "<outer><inner>simple</inner></outer>", @response.body
  end
  
  def test_deep_layout
    get :deep_layout
    assert_equal "<outer><inner><deep>deep layout</deep></inner></outer>", @response.body
  end
  
  def test_shared_data_is_available_to_all_layouts
    get :shared_data
    assert_equal "123<shared outer>abc<shared inner>assigns</shared inner></shared outer>", @response.body
  end
  
  def test_data_passing_to_outer_layout_through_instance_variables
    get :instance_passing
    assert_equal "<outer data_before='123' data_inside='456'><inner>instance passing</inner></outer>", @response.body
  end
  
  def test_data_passing_to_outer_layout_through_content_for
    get :content_for_passing
    assert_equal "<outer data_before='123' data_inside='456'><inner>content_for passing</inner></outer>", @response.body
  end

  def test_inline_layout
    get :inline_layout
    assert_equal "<outer><inner>data</inner></outer>", @response.body
  end
end
