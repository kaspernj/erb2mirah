package org.kaspernj.mirah.erb2mirah

import mirah.stdlib.Hash

interface connectOutputInterface do
  def run(str:String):void; end
end

class Page
  #Connects the given block to handle the output of the page.
  def connect_output(blk:connectOutputInterface):void
    @connect_output_blk = blk
  end
  
  #Writes the given string to the content.
  def write(str:String):void
    puts "Sending to block: '#{str}'."
    @connect_output_blk.run(str)
  end
  
  #Prints a string as a whole line (with line-end in the end).
  def puts(str:String):void
    self.write(str)
    self.write("\n")
  end
  
  #Alias for 'write'.
  def print(str:String):void
    self.write(str)
  end
  
  #Imports another class-page just like with PHP's "require".
  def import(pkg:String, name:String)
    classname = Erb2mirah.classname_for_path(name)
    fullname = "#{pkg}.#{classname}"
    
    begin
      clazz = Class.forName(fullname)
    rescue ClassNotFoundException
      raise "Class for page could not be found: '#{fullname}'."
    end
    
    page = Page(InstanceLoader.load(clazz))
    self.connect_output(page)
    page.run_code
  end
  
  #Because of some bug in Mirah, this needs to be in a method for itself.
  def connect_output(page:Page)
    raise "Page was null." if page == nil
    
    inst = self
    page.connect_output do |str|
      inst.write(str)
    end
  end
  
  #This is a method that should be overwritten and contain the actual code for generating a page.
  def run_code
    raise "This method should be overwritten."
  end
  
  def _get=(newget:Hash)
    @get = newget
  end
  
  def _post=(newpost:Hash)
    @post = newpost
  end
  
  def _meta=(newmeta:Hash)
    @meta = newmeta
  end
  
  def _cookie=(newcookie:Hash)
    @cookie = newcookie
  end
  
  def _get
    return @get
  end
  
  def _post
    return @post
  end
  
  def _meta
    return @meta
  end
  
  def _cookie
    return @cookie
  end
end