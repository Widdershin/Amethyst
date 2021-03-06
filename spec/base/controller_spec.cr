require "./spec_helper"

describe IndexController do

  headers           = HTTP::Headers.new
  headers["Accept"] = ["text/plain"]
  base_request      = HTTP::Request.new("GET", "/", headers, "Test")
  request           = Http::Request.new(base_request)
  response     = Http::Response.new(200, "Ok")
  controller        = IndexController.new
  controller.set_env(request, response)

  it "instantiates properly" do
    controller.actions_hash.should be_a Hash
    controller.actions_hash.length.should eq 2
  end

  it "actions method captures actions properly" do
    controller.actions_hash["hello"].should eq ->controller.hello
    #controller.actions_hash["bye"].should be_a Proc
  end

  it "actions return HTTP::Response" do
    response = controller.call_action("bye")
    response.should be_a Http::Response
    response.status.should eq 200
    response.body.should eq "Bye"
  end

  it "Formatter html method renders view if html/text' presented in 'Accept' header" do
    headers           = HTTP::Headers.new
    headers["Accept"] = ["text/html"]
    base_request = HTTP::Request.new("GET", "/", headers, "Test")
    request      = Http::Request.new(base_request)
    response     = Http::Response.new(404, "Not found")
    view_controller =  ViewController.new
    view_controller.set_env(request, response)
    view_controller.call_action "hello"
    response.body.should eq "Hello, Andrew"
  end

  it "raises exception if action not found" do
    base_request = HTTP::Request.new("GET", "/", headers, "Test")
    request      = Http::Request.new(base_request)
    response     = Http::Response.new(404, "Not found")
    view_controller =  ViewController.new
    view_controller.set_env(request, response)
    expect_raises ControllerActionNotFound do
      view_controller.call_action "hell"
    end
  end

  it "Formatter html method yields only if 'html/text' presented in 'Accept' header" do
    headers           = HTTP::Headers.new
    headers["Accept"] = ["text/plain"]
    base_request = HTTP::Request.new("GET", "/", headers, "Test")
    request      = Http::Request.new(base_request)
    response     = Http::Response.new(404, "Not found")
    view_controller =  ViewController.new
    view_controller.set_env(request, response)
    expect_raises HttpBadRequest do
      view_controller.call_action "hello"
    end
  end

  it "redirects with 'redirect_to' method" do
    headers           = HTTP::Headers.new
    headers["Accept"] = ["text/html"]
    base_request = HTTP::Request.new("GET", "/", headers, "Test")
    request      = Http::Request.new(base_request)
    response     = Http::Response.new(404, "Not found")
    view_controller =  ViewController.new
    view_controller.set_env(request, response)
    view_controller.call_action "redirect"
    response.status.should eq 303
  end
end