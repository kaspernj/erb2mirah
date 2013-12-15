package org.kaspernj.mirah.erb2mirah

import java.util.HashMap
import mirah.stdlib.File
import mirah.stdlib.Dir

#This class can be used to convert a hole directory to ".mirah"-files which can be mapped to a webserver (like Busa!).
class FolderConverter
  #Takes various named arguments: 'path', 'package' and 'pre_path'.
  def initialize(args:HashMap)
    #Check for invalid arguments.
    args_allowed = ["debug", "path", "path_to", "package", "pre_path"]
    args.keySet.each do |key|
      raise "Invalid key: '#{key}'." if !args_allowed.contains(key)
    end
    
    #Parse arguments.
    path = String(args["path"])
    raise "Invalid path: '#{path}'." if path == nil or !File.exists?(path)
    
    path_to = String(args["path_to"])
    raise "Invalid 'path_to': '#{path_to}'." if path_to == nil
    
    package_str = String(args["package"])
    pre_path = String(args["pre_path"])
    @debug = Boolean.valueOf(String(args["debug"]))
    debug_val = @debug
    debug "Pre-path: '#{pre_path}'."
    
    #Parse given path.
    inst = self
    regex_ext = /\.mirah\.erb$/
    
    Dir.foreach(path) do |file|
      if file.equals(".") or file.equals("..")
        #Ignore.
        inst.debug "Skipping because dots: '#{file}'."
      else
        fn = "#{path}/#{file}"
        raise "Doesnt exist: '#{fn}'." if !File.exists?(fn)
        
        if File.directory?(fn)
          path_to_folder = "#{path_to}/#{file}"
          Dir.mkdir(path_to_folder) if !File.exists?(path_to_folder)
          
          inst.debug "Found another dir: '#{fn}'."
          
          FolderConverter.new(
            "path" => fn,
            "path_to" => path_to_folder,
            "package" => package_str,
            "pre_path" => pre_path,
            "debug" => args["debug"]
          )
        else
          match_ext = regex_ext.matcher(fn)
          
          if match_ext.find
            inst.debug "Converting: '#{fn}'."
            
            erb = Erb2mirah.new(
              "fpath" => fn,
              "package" => package_str,
              "pre_path" => pre_path
            )
            erb.debug_enable if debug_val == Boolean.TRUE
            erb.convert
            
            inst.debug "Saving to path: '#{path_to}'."
            erb.save_to_path(path_to)
          else
            inst.debug "Skipping because invalid ext: '#{fn}'."
          end
        end
      end
    end
  end
  
  def debug(str:String)
    puts str if @debug == Boolean.TRUE
  end
end