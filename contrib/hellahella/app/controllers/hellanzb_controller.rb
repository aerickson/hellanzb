class HellanzbController < ApplicationController
  before_filter :authorize, :defaults
  before_filter :load_queue, :except => :status
  before_filter :load_status, :except => :update_order
  
  require 'xmlrpc/client'
  
  def index
  end
  
  def status
    render :partial => "status", :locals => { :status => @status }
  end
  
  def update_order
    index = 0
    params[:nzb].each do |nzbId|
      if nzbId != @queue[index]["id"].to_s
        server.call('move', nzbId, index)
      end
      index += 1
    end
    load_queue
    @message = "Queue updated"
    render :partial => "queue_items", 
           :locals => { :queue => @queue, :message => "Queue updated" }
  end
  
  def toggle_download
    if @status["is_paused"]
      server.call('continue')
    else
      server.call('pause')
    end
  end
  
  private
  def load_queue
    @queue = server.call('list')
  end
  def load_status
    @status = server.call("status")
  end
  def server()
    @server ||= XMLRPC::Client.new(@hnzb_server, "/", @hnzb_port, nil, nil, "hellanzb", @hnzb_password)
  end
end
